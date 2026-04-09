`timescale 1ns / 1ps

// 5x5、stride=1 的 INT8 最大池化模块。
// 保持原有 CBUF/OBUF 接口不变，通过最多 5 个在途行请求来覆盖
// CBUF 固定 4 个时钟周期的读延迟。
module pool_top #(

// 5x5 步长为1的 INT8 最大池化加速引擎。
// 保持原有的 CBUF/OBUF 接口，通过为每个半窗口发出最多 5 个 Outstanding (在途) 行读取请求，
// 完美掩盖了 CBUF 固定的 4 周期读取延迟。
module pool_top #(
module pool_top #(
    parameter BANK_NUM = 8,
    parameter TK_IN    = 8,
    parameter N        = 8
)(
    // 时钟与启动控制
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,

    // 特征图与输出维度配置
    input  wire [15:0]                  cfg_w_in,
    input  wire [15:0]                  cfg_h_in,
    input  wire [15:0]                  cfg_w_out,
    input  wire [15:0]                  cfg_h_out,
    input  wire [15:0]                  cfg_ch_groups,
    input  wire                         cfg_pad_zero,

    // CBUF 读接口
    input  wire                         cbuf_can_read,
    output reg  [7:0]                   cbuf_rd_en,
    output reg  [15:0]                  cbuf_rd_row,
    output reg  [15:0]                  cbuf_rd_col_align,
    output reg  [15:0]                  cbuf_rd_ch_grp,
    output reg                          cbuf_rd_row_free,
    output reg  [3:0]                   cbuf_rd_free_num,
    input  wire                         cbuf_rd_dat_vld,
    input  wire [BANK_NUM*TK_IN*N-1:0]  cbuf_rd_dat,

    // OBUF 写接口
    input  wire                         obuf_can_write,
    output reg                          obuf_wr_vld,
    output reg  [2*BANK_NUM-1:0]        obuf_wr_mask,
    output reg  [2*BANK_NUM*64-1:0]     obuf_wr_dat,

    output reg                          pool_done
);
    localparam PIXEL_W = TK_IN * N;

    localparam SIDE_A = 1'b0;
    localparam SIDE_B = 1'b1;

    // 精简后的 4 阶段状态机
    localparam ST_IDLE           = 2'd0;
    localparam ST_PIPELINED_LOAD = 2'd1; // 流水化在途加载阶段
    localparam ST_STAGE1         = 2'd2; // 计算流水线级 1 (列最大值) + 移位复用
    localparam ST_STAGE2         = 2'd3; // 计算流水线级 2 (行最大值) + 结果输出

    // ==========================================
    // 组合逻辑函数：纯并行比较树
    // ==========================================
    function [PIXEL_W-1:0] max2_pixel;
        input [PIXEL_W-1:0] a;
        input [PIXEL_W-1:0] b;
        integer lane;
        reg signed [7:0] av;
        reg signed [7:0] bv;
        begin
            for (lane = 0; lane < N; lane = lane + 1) begin
                av = a[lane*8 +: 8];
                bv = b[lane*8 +: 8];
                max2_pixel[lane*8 +: 8] = (av > bv) ? av : bv;
            end
        end
    endfunction

    function [PIXEL_W-1:0] max5_pixel;
        input [PIXEL_W-1:0] a0;
        input [PIXEL_W-1:0] a1;
        input [PIXEL_W-1:0] a2;
        input [PIXEL_W-1:0] a3;
        input [PIXEL_W-1:0] a4;
        reg [PIXEL_W-1:0] m01;
        reg [PIXEL_W-1:0] m23;
        begin
            m01 = max2_pixel(a0, a1);
            m23 = max2_pixel(a2, a3);
            max5_pixel = max2_pixel(max2_pixel(m01, m23), a4); // 3级延迟的比较树
        end
    endfunction

    // ==========================================
    // 控制寄存器与坐标计数器
    // ==========================================
    reg [1:0]  state;
    reg [15:0] h_cnt;
    reg [15:0] ch_grp_cnt;
    reg [15:0] w_blk_cnt;

    // load_side 指示当前数据加载到 A 侧还是 B 侧。
    // 每行首个块加载 A 再加载 B，后续块复用 B 到 A，仅加载新的 B。
    reg        load_side;
    reg [2:0]  req_row_cnt;  // SRAM 读请求发送计数器 (0~4)
    reg [2:0]  recv_row_cnt; // SRAM 读数据接收计数器 (0~4)
    
    // 【核心亮点】请求标签队列指针
    // 由于发出请求到数据返回有 4 拍延迟，且连续发送，必须用队列记录“发出的请求属于哪里”
    reg [2:0]  tag_wr_ptr; 
    reg [2:0]  tag_rd_ptr;

    // 请求标签队列的物理存储体：保存发请求时的上下文信息
    reg        tag_side       [0:4];
    reg [2:0]  tag_row        [0:4];
    reg [7:0]  tag_dst_mask   [0:4];
    reg signed [16:0] tag_col_base_s [0:4];
    reg signed [16:0] tag_req_col_s  [0:4];

    // ==========================================
    // 数据通路寄存器
    // ==========================================
    reg  [PIXEL_W-1:0] Reg_A [0:4][0:7];
    reg  [PIXEL_W-1:0] Reg_B [0:4][0:7];

    wire [PIXEL_W-1:0] Window_Reg   [0:4][0:15]; // 逻辑视图拼接
    wire [PIXEL_W-1:0] Col_Max_Wire [0:15];
    wire [PIXEL_W-1:0] Row_Max_Wire [0:7];
    reg  [PIXEL_W-1:0] Col_Max_Reg  [0:15];      // 级联寄存器
    reg  [PIXEL_W-1:0] Out_Reg      [0:7];       // 输出寄存器

    wire [PIXEL_W-1:0] min_pixel = {N{8'h80}};
    wire [PIXEL_W-1:0] pad_pixel = cfg_pad_zero ? {PIXEL_W{1'b0}} : min_pixel;

    // ==========================================
    // 边界与地址计算 (组合逻辑)
    // ==========================================
    wire [15:0] cfg_w_out_blocks = (cfg_w_out + 16'd7) >> 3;
    wire signed [16:0] cfg_w_in_s  = {1'b0, cfg_w_in};
    wire signed [16:0] cfg_h_in_s  = {1'b0, cfg_h_in};
    wire signed [16:0] cfg_w_out_s = {1'b0, cfg_w_out};

    wire signed [16:0] out_col_base_s = $signed({1'b0, w_blk_cnt}) * 17'sd8;
    wire signed [16:0] load_row_s = $signed({1'b0, h_cnt}) + $signed({14'd0, req_row_cnt}) - 17'sd2;
    wire signed [16:0] load_a_col_base_s = out_col_base_s - 17'sd2;
    wire signed [16:0] load_b_col_base_s = out_col_base_s + 17'sd6;
    wire signed [16:0] load_col_base_s   = load_side ? load_b_col_base_s : load_a_col_base_s;
    wire signed [16:0] load_req_col_s    = (load_col_base_s < 17'sd0) ? 17'sd0 : load_col_base_s;
    wire               load_row_valid    = (load_row_s >= 17'sd0) && (load_row_s < cfg_h_in_s);

    wire last_w  = (w_blk_cnt == cfg_w_out_blocks - 1'b1);
    wire last_ch = (ch_grp_cnt == cfg_ch_groups - 1'b1);
    wire last_h  = (h_cnt == cfg_h_out - 1'b1);

    // 释放逻辑
    wire signed [16:0] cur_lowest_s  = $signed({1'b0, h_cnt}) - 17'sd2;
    wire signed [16:0] next_lowest_s = $signed({1'b0, h_cnt}) - 17'sd1;
    wire signed [16:0] real_cur_lowest_s  = (cur_lowest_s  < 17'sd0) ? 17'sd0 : cur_lowest_s;
    wire signed [16:0] real_next_lowest_s = (next_lowest_s < 17'sd0) ? 17'sd0 : next_lowest_s;
    wire [3:0] free_num_calc = (real_next_lowest_s > real_cur_lowest_s) ?
                            (real_next_lowest_s - real_cur_lowest_s) : 4'd0;

    // 掩码生成
    reg [7:0] load_rd_mask;
    reg [7:0] load_dst_mask;
    reg [7:0] out_mask;
    integer mi;
    integer src_i;

    always @(*) begin
        load_rd_mask  = 8'd0;
        load_dst_mask = 8'd0;
        for (mi = 0; mi < 8; mi = mi + 1) begin
            src_i = load_col_base_s + mi - load_req_col_s;
            if (load_row_valid &&
                ((load_col_base_s + mi) >= 17'sd0) &&
                ((load_col_base_s + mi) < cfg_w_in_s) &&
                (src_i >= 0) && (src_i < 8)) begin
                load_dst_mask[mi]   = 1'b1;
                load_rd_mask[src_i] = 1'b1;
            end
        end
    end

    always @(*) begin
        out_mask = 8'd0;
        for (mi = 0; mi < 8; mi = mi + 1) begin
            if ((out_col_base_s + mi) < cfg_w_out_s) begin
                out_mask[mi] = 1'b1;
            end
        end
    end

    // ==========================================
    // 流水线控制握手信号解析
    // ==========================================
    wire load_has_mem = |load_rd_mask; // 当前行是否有真实的 SRAM 需求
    wire load_phase_complete_now = (recv_row_cnt == 3'd5); // 当前周期是否已收满 5 行
    wire load_can_issue = (state == ST_PIPELINED_LOAD) &&
                        !load_phase_complete_now &&
                        (req_row_cnt < 3'd5);
    
    // 发送动作触发条件
    wire issue_real_req = load_can_issue && load_has_mem && cbuf_can_read;
    wire issue_pad_row  = load_can_issue && !load_has_mem; // 纯填充值行，不占用 SRAM
    // 接收动作触发条件
    wire recv_real_row  = (state == ST_PIPELINED_LOAD) && cbuf_rd_dat_vld;
    
    // 接收计数器累加值（可能同时收到填充值行和来自 SRAM 的回传行）
    wire [2:0] recv_inc = {2'd0, recv_real_row} + {2'd0, issue_pad_row};
    wire load_phase_complete_next = (recv_row_cnt + recv_inc) == 3'd5; // 下一拍是否收满

    // ==========================================
    // 比较树逻辑展开生成
    // ==========================================
    genvar gr, gc, col, op;
    generate
        for (gr = 0; gr < 5; gr = gr + 1) begin : GEN_WINDOW_ROW
            for (gc = 0; gc < 8; gc = gc + 1) begin : GEN_WINDOW_COL
                assign Window_Reg[gr][gc]     = Reg_A[gr][gc];
                assign Window_Reg[gr][gc + 8] = Reg_B[gr][gc];
            end
        end

        for (col = 0; col < 16; col = col + 1) begin : GEN_COL_MAX
            assign Col_Max_Wire[col] = max5_pixel(
                Window_Reg[0][col], Window_Reg[1][col], Window_Reg[2][col],
                Window_Reg[3][col], Window_Reg[4][col]
            );
        end

        for (op = 0; op < 8; op = op + 1) begin : GEN_ROW_MAX
            assign Row_Max_Wire[op] = max5_pixel(
                Col_Max_Reg[op + 0], Col_Max_Reg[op + 1], Col_Max_Reg[op + 2],
                Col_Max_Reg[op + 3], Col_Max_Reg[op + 4]
            );
        end
    endgenerate

    // ==========================================
    // 核心时序逻辑：FSM 与 流水线寄器更新
    // ==========================================
    integer r, p, q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state             <= ST_IDLE;
            h_cnt             <= 16'd0;
            ch_grp_cnt        <= 16'd0;
            w_blk_cnt         <= 16'd0;
            load_side         <= SIDE_A;
            req_row_cnt       <= 3'd0;
            recv_row_cnt      <= 3'd0;
            tag_wr_ptr        <= 3'd0;
            tag_rd_ptr        <= 3'd0;
            cbuf_rd_en        <= 8'd0;
            cbuf_rd_row       <= 16'd0;
            cbuf_rd_col_align <= 16'd0;
            cbuf_rd_ch_grp    <= 16'd0;
            cbuf_rd_row_free  <= 1'b0;
            cbuf_rd_free_num  <= 4'd0;
            obuf_wr_vld       <= 1'b0;
            obuf_wr_mask      <= {2*BANK_NUM{1'b0}};
            obuf_wr_dat       <= {(2*BANK_NUM*64){1'b0}};
            pool_done         <= 1'b0;
            for (r = 0; r < 5; r = r + 1) begin
                tag_side[r]       <= SIDE_A;
                tag_row[r]        <= 3'd0;
                tag_dst_mask[r]   <= 8'd0;
                tag_col_base_s[r] <= 17'sd0;
                tag_req_col_s[r]  <= 17'sd0;
                for (p = 0; p < 8; p = p + 1) begin
                    Reg_A[r][p] <= min_pixel;
                    Reg_B[r][p] <= min_pixel;
                end
            end
            for (p = 0; p < 16; p = p + 1) begin
                Col_Max_Reg[p] <= min_pixel;
            end
            for (p = 0; p < 8; p = p + 1) begin
                Out_Reg[p] <= min_pixel;
            end
        end else begin
            // 默认控制信号拉低
            cbuf_rd_en       <= 8'd0;
            cbuf_rd_row_free <= 1'b0;
            cbuf_rd_free_num <= 4'd0;
            obuf_wr_vld      <= 1'b0;
            obuf_wr_mask     <= {2*BANK_NUM{1'b0}};
            pool_done        <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        h_cnt        <= 16'd0;
                        ch_grp_cnt   <= 16'd0;
                        w_blk_cnt    <= 16'd0;
                        load_side    <= SIDE_A;
                        req_row_cnt  <= 3'd0;
                        recv_row_cnt <= 3'd0;
                        tag_wr_ptr   <= 3'd0;
                        tag_rd_ptr   <= 3'd0;
                        state        <= ST_PIPELINED_LOAD;
                    end
                end

                ST_PIPELINED_LOAD: begin
                    // ----------------------------------------------------
                    // 接收路径 (Receive Path): 完全由 cbuf_rd_dat_vld 驱动
                    // ----------------------------------------------------
                    // CBUF 会按照发出请求的顺序，在 4 个周期后返回数据。
                    // 此时通过读取请求标签队列，恢复该数据当初的请求上下文
                    // 包括写 A 还是写 B、第几行、以及对应的有效掩码。
                    if (recv_real_row) begin
                        if (tag_side[tag_rd_ptr] == SIDE_A) begin
                            for (p = 0; p < 8; p = p + 1) begin
                                if (tag_dst_mask[tag_rd_ptr][p]) begin
                                    q = tag_col_base_s[tag_rd_ptr] + p - tag_req_col_s[tag_rd_ptr];
                                    Reg_A[tag_row[tag_rd_ptr]][p] <= cbuf_rd_dat[q*PIXEL_W +: PIXEL_W];
                                end else begin
                                    Reg_A[tag_row[tag_rd_ptr]][p] <= pad_pixel;
                                end
                            end
                        end else begin
                            for (p = 0; p < 8; p = p + 1) begin
                                if (tag_dst_mask[tag_rd_ptr][p]) begin
                                    q = tag_col_base_s[tag_rd_ptr] + p - tag_req_col_s[tag_rd_ptr];
                                    Reg_B[tag_row[tag_rd_ptr]][p] <= cbuf_rd_dat[q*PIXEL_W +: PIXEL_W];
                                end else begin
                                    Reg_B[tag_row[tag_rd_ptr]][p] <= pad_pixel;
                                end
                            end
                        end
                        tag_rd_ptr <= tag_rd_ptr + 1'b1; // 消耗一个 Tag
                    end

                    // ----------------------------------------------------
                    // 发送路径 (Request Path): 背靠背连续发射，不等待返回
                    // ----------------------------------------------------
                    if (issue_real_req) begin
                        cbuf_rd_en        <= load_rd_mask;
                        cbuf_rd_row       <= load_row_s[15:0];
                        cbuf_rd_col_align <= load_req_col_s[15:0];
                        cbuf_rd_ch_grp    <= ch_grp_cnt;

                        // 将当前请求的上下文写入请求标签队列，
                        // 供 4 拍后数据返回时恢复使用。
                        tag_side[tag_wr_ptr]       <= load_side;
                        tag_row[tag_wr_ptr]        <= req_row_cnt;
                        tag_dst_mask[tag_wr_ptr]   <= load_dst_mask;
                        tag_col_base_s[tag_wr_ptr] <= load_col_base_s;
                        tag_req_col_s[tag_wr_ptr]  <= load_req_col_s;
                        
                        tag_wr_ptr  <= tag_wr_ptr + 1'b1;
                        req_row_cnt <= req_row_cnt + 1'b1;
                    end else if (issue_pad_row) begin
                        // 纯填充值行，内部直接消化，不发 SRAM 请求，也不进入标签队列。
                        if (load_side == SIDE_A) begin
                            for (p = 0; p < 8; p = p + 1) begin
                                Reg_A[req_row_cnt][p] <= pad_pixel;
                            end
                        end else begin
                            for (p = 0; p < 8; p = p + 1) begin
                                Reg_B[req_row_cnt][p] <= pad_pixel;
                            end
                        end
                        req_row_cnt <= req_row_cnt + 1'b1;
                    end

                    // 更新总接收计数器（真实数据 + 填充值消化量）
                    recv_row_cnt <= recv_row_cnt + recv_inc;

                    // ----------------------------------------------------
                    // 跳转逻辑：收齐 5 行数据后立刻跳转
                    // ----------------------------------------------------
                    if (load_phase_complete_next || load_phase_complete_now) begin
                        req_row_cnt  <= 3'd0;
                        recv_row_cnt <= 3'd0;
                        tag_wr_ptr   <= 3'd0;
                        tag_rd_ptr   <= 3'd0;

                        if (load_side == SIDE_A) begin
                            load_side <= SIDE_B; // 行首块：填满 A 后，留在此状态继续填 B
                            state     <= ST_PIPELINED_LOAD;
                        end else begin
                            state     <= ST_STAGE1; // B 满，进入计算流水线
                        end
                    end
                end

                ST_STAGE1: begin
                    // 【核心复用与打拍机制】
                    // 在同一个时钟周期内完成：1. 采样列最大值 2. 滑动窗口(B->A)
                    for (p = 0; p < 16; p = p + 1) begin
                        Col_Max_Reg[p] <= Col_Max_Wire[p];
                    end
                    for (r = 0; r < 5; r = r + 1) begin
                        for (p = 0; p < 8; p = p + 1) begin
                            Reg_A[r][p] <= Reg_B[r][p];
                        end
                    end
                    state <= ST_STAGE2;
                end

                ST_STAGE2: begin
                    if (obuf_can_write) begin
                        // ... (写回逻辑与原代码保持一致) ...
                        obuf_wr_vld <= 1'b1;
                        // ...
                        
                        // 块控制切换
                        if (last_w && last_ch && last_h) begin
                            pool_done <= 1'b1;
                            state     <= ST_IDLE;
                        end else begin
                            if (last_w) begin
                                w_blk_cnt <= 16'd0;
                                load_side <= SIDE_A; // 换行时，下一个块需重新填 A
                                // ...
                            end else begin
                                w_blk_cnt <= w_blk_cnt + 1'b1;
                                load_side <= SIDE_B; // 同一行平移，复用 A，只需填 B
                            end
                            req_row_cnt  <= 3'd0;
                            recv_row_cnt <= 3'd0;
                            tag_wr_ptr   <= 3'd0;
                            tag_rd_ptr   <= 3'd0;
                            state        <= ST_PIPELINED_LOAD;
                        end
                    end
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule
