`timescale 1ns / 1ps

// 2D Max Pooling 硬件加速模块
// 核心架构: 5x5 池化核, 步长 1, 8 像素空间并行, 2 级流水线设计
module pool_top #(
    parameter BANK_NUM = 8,
    parameter TK_IN    = 8,
    parameter N        = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,

    // 特征图维度配置
    input  wire [15:0]                  cfg_w_in,
    input  wire [15:0]                  cfg_h_in,
    input  wire [15:0]                  cfg_w_out,
    input  wire [15:0]                  cfg_h_out,
    input  wire [15:0]                  cfg_ch_groups,
    input  wire                         cfg_pad_zero, // Padding策略：1为补0，0为补极小值

    // 环形缓冲区 (CBUF) 读取接口 (SRAM 侧)
    input  wire                         cbuf_can_read,
    output reg  [7:0]                   cbuf_rd_en,
    output reg  [15:0]                  cbuf_rd_row,
    output reg  [15:0]                  cbuf_rd_col_align,
    output reg  [15:0]                  cbuf_rd_ch_grp,
    output reg                          cbuf_rd_row_free,
    output reg  [3:0]                   cbuf_rd_free_num,
    input  wire                         cbuf_rd_dat_vld,
    input  wire [BANK_NUM*TK_IN*N-1:0]  cbuf_rd_dat,

    // 输出缓冲区写入接口
    input  wire                         obuf_can_write,
    output reg                          obuf_wr_vld,
    output reg  [2*BANK_NUM-1:0]        obuf_wr_mask,
    output reg  [2*BANK_NUM*64-1:0]     obuf_wr_dat,

    output reg                          pool_done
);
    // 每次处理一个像素包含的所有通道的位宽 (8 * 8 = 64 bit)
    localparam PIXEL_W = TK_IN * N;

    // 移位寄存器左右侧标识
    localparam SIDE_A = 1'b0;
    localparam SIDE_B = 1'b1;

    // 状态机定义
    localparam ST_IDLE        = 3'd0;
    localparam ST_BLOCK_START = 3'd1; // 启动新像素块
    localparam ST_ISSUE       = 3'd2; // 发送5行数据的读取请求
    localparam ST_WAIT_DATA   = 3'd3; // 接收SRAM数据
    localparam ST_STAGE1      = 3'd4; // 流水线级1：保存列最大值，移位复用
    localparam ST_STAGE2      = 3'd5; // 流水线级2：计算行最大值并输出

    // ==========================================
    // 组合逻辑函数：并行通道最大值比较树
    // ==========================================
    // 比较 2 个 PIXEL_W 宽度的向量 (拆分为 N 个 8-bit INT8 独立比较)
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

    // 比较 5 个 PIXEL_W 宽度的向量 (构成 5 输入比较树)
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
            max5_pixel = max2_pixel(max2_pixel(m01, m23), a4);
        end
    endfunction

    // ==========================================
    // 核心寄存器与变量定义
    // ==========================================
    reg [2:0]  state;
    reg [15:0] h_cnt;
    reg [15:0] ch_grp_cnt;
    reg [15:0] w_blk_cnt;
    reg        load_side;     // 指示当前 SRAM 数据应加载到 SIDE_A 还是 SIDE_B
    reg [2:0]  load_row_cnt;  // 当前加载窗口的行计数 (0~4)

    // 发起 SRAM 读请求时的现场保存，用于数据返回时的对齐
    reg        saved_load_side;
    reg [2:0]  saved_load_row;
    reg [7:0]  saved_dst_mask;
    reg signed [16:0] saved_col_base_s;
    reg signed [16:0] saved_req_col_s;

    // 二维滑动窗口寄存器阵列 (物理存储)
    reg  [PIXEL_W-1:0] Reg_A [0:4][0:7]; // 历史复用段
    reg  [PIXEL_W-1:0] Reg_B [0:4][0:7]; // 新取数据段
    
    // 组合逻辑视图：水平拼接 Reg_A 和 Reg_B，提供 16 列的连续视野
    wire [PIXEL_W-1:0] Window_Reg [0:4][0:15];
    
    // 流水线计算网络连线与寄存器
    wire [PIXEL_W-1:0] Col_Max_Wire [0:15]; // Stage 1 组合逻辑输出
    wire [PIXEL_W-1:0] Row_Max_Wire [0:7];  // Stage 2 组合逻辑输出
    reg  [PIXEL_W-1:0] Col_Max_Reg [0:15];  // Stage 1 流水线锁存器
    reg  [PIXEL_W-1:0] Out_Reg [0:7];       // 最终输出锁存器

    // Padding 常量定义
    wire [PIXEL_W-1:0] min_pixel = {N{8'h80}}; // INT8 极小值 -128
    wire [PIXEL_W-1:0] pad_pixel = cfg_pad_zero ? {PIXEL_W{1'b0}} : min_pixel;

    // ==========================================
    // 坐标计算与边界检查
    // ==========================================
    wire [15:0] cfg_w_out_blocks = (cfg_w_out + 16'd7) >> 3;
    wire signed [16:0] cfg_w_in_s  = {1'b0, cfg_w_in};
    wire signed [16:0] cfg_h_in_s  = {1'b0, cfg_h_in};
    wire signed [16:0] cfg_w_out_s = {1'b0, cfg_w_out};
    
    // 基础坐标计算
    wire signed [16:0] out_col_base_s = $signed({1'b0, w_blk_cnt}) * 17'sd8;
    wire signed [16:0] load_row_s = $signed({1'b0, h_cnt}) + $signed({14'd0, load_row_cnt}) - 17'sd2;
    wire signed [16:0] load_a_col_base_s = out_col_base_s - 17'sd2; // A段对应左偏移2
    wire signed [16:0] load_b_col_base_s = out_col_base_s + 17'sd6; // B段对应右偏移6
    wire signed [16:0] load_col_base_s = load_side ? load_b_col_base_s : load_a_col_base_s;
    wire signed [16:0] load_req_col_s = (load_col_base_s < 0) ? 17'sd0 : load_col_base_s;
    wire load_row_valid = (load_row_s >= 0) && (load_row_s < cfg_h_in_s);

    wire last_w  = (w_blk_cnt == cfg_w_out_blocks - 1'b1);
    wire last_ch = (ch_grp_cnt == cfg_ch_groups - 1'b1);
    wire last_h  = (h_cnt == cfg_h_out - 1'b1);

    // 行缓存释放计算
    wire signed [16:0] cur_lowest_s  = $signed({1'b0, h_cnt}) - 17'sd2;
    wire signed [16:0] next_lowest_s = $signed({1'b0, h_cnt}) - 17'sd1;
    wire signed [16:0] real_cur_lowest_s  = (cur_lowest_s  < 0) ? 17'sd0 : cur_lowest_s;
    wire signed [16:0] real_next_lowest_s = (next_lowest_s < 0) ? 17'sd0 : next_lowest_s;
    wire [3:0] free_num_calc = (real_next_lowest_s > real_cur_lowest_s) ?
                            (real_next_lowest_s - real_cur_lowest_s) : 4'd0;

    // ==========================================
    // 掩码生成逻辑 (组合逻辑)
    // ==========================================
    reg [7:0] load_rd_mask;  // 请求掩码：指示哪些列需要从 SRAM 读
    reg [7:0] load_dst_mask; // 目标掩码：指示 Reg_A/B 的哪些位置应接纳 SRAM 数据
    reg [7:0] out_mask;
    integer mi;
    integer src_i;

    always @(*) begin
        load_rd_mask  = 8'd0;
        load_dst_mask = 8'd0;
        for (mi = 0; mi < 8; mi = mi + 1) begin
            src_i = load_col_base_s + mi - load_req_col_s;
            if (load_row_valid &&
                ((load_col_base_s + mi) >= 0) &&
                ((load_col_base_s + mi) < cfg_w_in_s) &&
                (src_i >= 0) && (src_i < 8)) begin
                load_dst_mask[mi] = 1'b1;
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
    // 组合逻辑比较树展开 (Pipeline 计算核心)
    // ==========================================
    genvar gr, gc, col, op;
    generate
        // 1. 拼接 Reg_A 和 Reg_B 成为 16 列连续窗口
        for (gr = 0; gr < 5; gr = gr + 1) begin : GEN_WINDOW_ROW
            for (gc = 0; gc < 8; gc = gc + 1) begin : GEN_WINDOW_COL
                assign Window_Reg[gr][gc]     = Reg_A[gr][gc];
                assign Window_Reg[gr][gc + 8] = Reg_B[gr][gc];
            end
        end
        
        // 2. STAGE 1: 求 16 个垂直列各自的 5 行最大值
        for (col = 0; col < 16; col = col + 1) begin : GEN_COL_MAX
            assign Col_Max_Wire[col] = max5_pixel(
                Window_Reg[0][col],
                Window_Reg[1][col],
                Window_Reg[2][col],
                Window_Reg[3][col],
                Window_Reg[4][col]
            );
        end
        
        // 3. STAGE 2: 水平滑窗，求 8 个并行像素各自的 5 列最大值
        for (op = 0; op < 8; op = op + 1) begin : GEN_ROW_MAX
            assign Row_Max_Wire[op] = max5_pixel(
                Col_Max_Reg[op + 0],
                Col_Max_Reg[op + 1],
                Col_Max_Reg[op + 2],
                Col_Max_Reg[op + 3],
                Col_Max_Reg[op + 4]
            );
        end
    endgenerate

    // ==========================================
    // 时序逻辑：FSM 与 数据搬移控制
    // ==========================================
    integer r, p, q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state              <= ST_IDLE;
            h_cnt              <= 16'd0;
            ch_grp_cnt         <= 16'd0;
            w_blk_cnt          <= 16'd0;
            load_side          <= SIDE_A;
            load_row_cnt       <= 3'd0;
            saved_load_side    <= SIDE_A;
            saved_load_row     <= 3'd0;
            saved_dst_mask     <= 8'd0;
            saved_col_base_s   <= 17'sd0;
            saved_req_col_s    <= 17'sd0;
            cbuf_rd_en         <= 8'd0;
            cbuf_rd_row        <= 16'd0;
            cbuf_rd_col_align  <= 16'd0;
            cbuf_rd_ch_grp     <= 16'd0;
            cbuf_rd_row_free   <= 1'b0;
            cbuf_rd_free_num   <= 4'd0;
            obuf_wr_vld        <= 1'b0;
            obuf_wr_mask       <= 16'd0;
            obuf_wr_dat        <= {(2*BANK_NUM*64){1'b0}};
            pool_done          <= 1'b0;

            for (r = 0; r < 5; r = r + 1) begin
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
            cbuf_rd_en       <= 8'd0;
            cbuf_rd_row_free <= 1'b0;
            cbuf_rd_free_num <= 4'd0;
            obuf_wr_vld      <= 1'b0;
            obuf_wr_mask     <= 16'd0;
            pool_done        <= 1'b0;

            case (state)
                ST_IDLE: begin
                    if (start) begin
                        h_cnt        <= 16'd0;
                        ch_grp_cnt   <= 16'd0;
                        w_blk_cnt    <= 16'd0;
                        load_side    <= SIDE_A;
                        load_row_cnt <= 3'd0;
                        state        <= ST_BLOCK_START;
                    end
                end

                ST_BLOCK_START: begin
                    // 新行的首个块需要加载SIDE_A，后续只加载SIDE_B进行滑窗复用
                    load_side    <= (w_blk_cnt == 16'd0) ? SIDE_A : SIDE_B;
                    load_row_cnt <= 3'd0;
                    state        <= ST_ISSUE;
                end

                ST_ISSUE: begin
                    if (|load_rd_mask) begin
                        if (cbuf_can_read) begin
                            cbuf_rd_en        <= load_rd_mask;
                            cbuf_rd_row       <= load_row_s[15:0];
                            cbuf_rd_col_align <= load_req_col_s[15:0];
                            cbuf_rd_ch_grp    <= ch_grp_cnt;
                            saved_load_side   <= load_side;
                            saved_load_row    <= load_row_cnt;
                            saved_dst_mask    <= load_dst_mask;
                            saved_col_base_s  <= load_col_base_s;
                            saved_req_col_s   <= load_req_col_s;
                            state             <= ST_WAIT_DATA;
                        end
                    end else begin
                        // 越界区不发请求，直接做 Padding 处理
                        if (load_side == SIDE_A) begin
                            for (p = 0; p < 8; p = p + 1) begin
                                Reg_A[load_row_cnt][p] <= pad_pixel;
                            end
                        end else begin
                            for (p = 0; p < 8; p = p + 1) begin
                                Reg_B[load_row_cnt][p] <= pad_pixel;
                            end
                        end

                        // 控制 5 行读取的循环结束条件
                        if (load_row_cnt == 3'd4) begin
                            if (load_side == SIDE_A) begin
                                load_side    <= SIDE_B;
                                load_row_cnt <= 3'd0;
                            end else begin
                                state <= ST_STAGE1; // B侧填满，进入流水计算
                            end
                        end else begin
                            load_row_cnt <= load_row_cnt + 1'b1;
                        end
                    end
                end

                ST_WAIT_DATA: begin
                    if (cbuf_rd_dat_vld) begin
                        // 将 SRAM 返回的数据依掩码条件写入 Window Reg
                        if (saved_load_side == SIDE_A) begin
                            for (p = 0; p < 8; p = p + 1) begin
                                if (saved_dst_mask[p]) begin
                                    q = saved_col_base_s + p - saved_req_col_s;
                                    Reg_A[saved_load_row][p] <= cbuf_rd_dat[q*PIXEL_W +: PIXEL_W];
                                end else begin
                                    Reg_A[saved_load_row][p] <= pad_pixel;
                                end
                            end
                        end else begin
                            for (p = 0; p < 8; p = p + 1) begin
                                if (saved_dst_mask[p]) begin
                                    q = saved_col_base_s + p - saved_req_col_s;
                                    Reg_B[saved_load_row][p] <= cbuf_rd_dat[q*PIXEL_W +: PIXEL_W];
                                end else begin
                                    Reg_B[saved_load_row][p] <= pad_pixel;
                                end
                            end
                        end

                        if (load_row_cnt == 3'd4) begin
                            if (load_side == SIDE_A) begin
                                load_side    <= SIDE_B;
                                load_row_cnt <= 3'd0;
                                state        <= ST_ISSUE;
                            end else begin
                                state <= ST_STAGE1;
                            end
                        end else begin
                            load_row_cnt <= load_row_cnt + 1'b1;
                            state        <= ST_ISSUE;
                        end
                    end
                end

                ST_STAGE1: begin
                    // 【核心流水线打拍与移位机制】
                    // 1. 将当前16列比较树结果锁存
                    for (p = 0; p < 16; p = p + 1) begin
                        Col_Max_Reg[p] <= Col_Max_Wire[p];
                    end
                    // 2. 将右侧最新块推入左侧历史块，实现滑窗复用，彻底摒弃旧块
                    for (r = 0; r < 5; r = r + 1) begin
                        for (p = 0; p < 8; p = p + 1) begin
                            Reg_A[r][p] <= Reg_B[r][p];
                        end
                    end
                    state <= ST_STAGE2;
                end

                ST_STAGE2: begin
                    if (obuf_can_write) begin
                        obuf_wr_vld <= 1'b1;
                        obuf_wr_dat <= {(2*BANK_NUM*64){1'b0}};

                        // 最终输出打拍
                        for (p = 0; p < 8; p = p + 1) begin
                            Out_Reg[p] <= Row_Max_Wire[p];
                        end

                        // 交错打包写入 SRAM
                        if (ch_grp_cnt[0] == 1'b0) begin
                            obuf_wr_mask[7:0]  <= out_mask;
                            obuf_wr_mask[15:8] <= 8'd0;
                            for (p = 0; p < 8; p = p + 1) begin
                                obuf_wr_dat[p*64 +: 64] <= Row_Max_Wire[p];
                            end
                        end else begin
                            obuf_wr_mask[7:0]  <= 8'd0;
                            obuf_wr_mask[15:8] <= out_mask;
                            for (p = 0; p < 8; p = p + 1) begin
                                obuf_wr_dat[BANK_NUM*64 + p*64 +: 64] <= Row_Max_Wire[p];
                            end
                        end

                        // 生命周期管理：行完成释放判断
                        if (last_w && last_ch && (free_num_calc != 4'd0)) begin
                            cbuf_rd_row_free <= 1'b1;
                            cbuf_rd_free_num <= free_num_calc;
                        end

                        // 边界跳转与多维度循环累加控制
                        if (last_w && last_ch && last_h) begin
                            pool_done <= 1'b1;
                            state     <= ST_IDLE;
                        end else begin
                            if (last_w) begin
                                w_blk_cnt <= 16'd0;
                                if (last_ch) begin
                                    ch_grp_cnt <= 16'd0;
                                    h_cnt      <= h_cnt + 1'b1;
                                end else begin
                                    ch_grp_cnt <= ch_grp_cnt + 1'b1;
                                end
                            end else begin
                                w_blk_cnt <= w_blk_cnt + 1'b1;
                            end
                            state <= ST_BLOCK_START;
                        end
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule