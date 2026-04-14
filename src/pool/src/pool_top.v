`timescale 1ns / 1ps

// 5x5 步长为1的 INT8 最大池化加速引擎。
// 保持原有的 CBUF/OBUF 接口，通过为每个半窗口发出最多 5 个 Outstanding (在途) 行读取请求，
// 完美掩盖了 CBUF 固定的 4 周期读取延迟。


// ============================================================================
// 新版 pool_top
// 采用 next-state 写法，避免同一个寄存器在一个时钟周期内被多次赋值。
// ============================================================================
// ============================================================================
// 新版 pool_top
// 采用 next-state 写法，保证每个寄存器在时序块里只更新一次，
// 从而消除综合时 “set/reset 同优先级” 一类告警。
// ============================================================================
module pool_top #(
    parameter BANK_NUM = 8,
    parameter TK_IN    = 8,
    parameter N        = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,

    input  wire [15:0]                  cfg_w_in,
    input  wire [15:0]                  cfg_h_in,
    input  wire [15:0]                  cfg_w_out,
    input  wire [15:0]                  cfg_h_out,
    input  wire [15:0]                  cfg_ch_groups,
    input  wire                         cfg_pad_zero,

    input  wire                         cbuf_can_read,
    output reg  [7:0]                   cbuf_rd_en,
    output reg  [15:0]                  cbuf_rd_row,
    output reg  [15:0]                  cbuf_rd_col_align,
    output reg  [15:0]                  cbuf_rd_ch_grp,
    output reg                          cbuf_rd_row_free,
    output reg  [3:0]                   cbuf_rd_free_num,
    input  wire                         cbuf_rd_dat_vld,
    input  wire [BANK_NUM*TK_IN*N-1:0]  cbuf_rd_dat,

    input  wire                         obuf_can_write,
    output reg                          obuf_wr_vld,
    output reg  [2*BANK_NUM-1:0]        obuf_wr_mask,
    output reg  [2*BANK_NUM*64-1:0]     obuf_wr_dat,

    output reg                          pool_done
);
    localparam PIXEL_W = TK_IN * N;

    localparam SIDE_A = 1'b0;
    localparam SIDE_B = 1'b1;

    localparam LD_IDLE = 1'b0;
    localparam LD_RUN  = 1'b1;

    localparam CP_IDLE   = 2'd0;
    localparam CP_STAGE1 = 2'd1;
    localparam CP_STAGE2 = 2'd2;

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
            max5_pixel = max2_pixel(max2_pixel(m01, m23), a4);
        end
    endfunction

    // 当前正在计算的块坐标
    reg [15:0] h_cnt;
    reg [15:0] ch_grp_cnt;
    reg [15:0] w_blk_cnt;

    // load 子状态机：独立负责装载 SIDE_A / SIDE_B
    reg        load_state;
    reg        load_side;
    reg [15:0] load_h_cnt;
    reg [15:0] load_ch_grp_cnt;
    reg [15:0] load_w_blk_cnt;

    // compute 子状态机：独立负责当前块的两级计算
    reg [1:0]  compute_state;

    // 当前块左右半窗是否已准备完毕
    reg        side_a_ready;
    reg        side_b_ready;

    // load outstanding 请求管理
    reg [2:0]  req_row_cnt;
    reg [2:0]  recv_row_cnt;
    reg [2:0]  tag_wr_ptr;
    reg [2:0]  tag_rd_ptr;

    reg        tag_side       [0:4];
    reg [2:0]  tag_row        [0:4];
    reg [7:0]  tag_dst_mask   [0:4];
    reg signed [16:0] tag_col_base_s [0:4];
    reg signed [16:0] tag_req_col_s  [0:4];

    reg  [PIXEL_W-1:0] Reg_A [0:4][0:7];
    reg  [PIXEL_W-1:0] Reg_B [0:4][0:7];
    reg  [PIXEL_W-1:0] Col_Max_Reg [0:11];

    wire [PIXEL_W-1:0] Window_Reg   [0:4][0:15];
    wire [PIXEL_W-1:0] Col_Max_Wire [0:15];
    wire [PIXEL_W-1:0] Row_Max_Wire [0:7];

    wire [PIXEL_W-1:0] min_pixel = {N{8'h80}};
    wire [PIXEL_W-1:0] pad_pixel = cfg_pad_zero ? {PIXEL_W{1'b0}} : min_pixel;

    wire [15:0] cfg_w_out_blocks = (cfg_w_out + 16'd7) >> 3;
    wire signed [16:0] cfg_w_in_s  = {1'b0, cfg_w_in};
    wire signed [16:0] cfg_h_in_s  = {1'b0, cfg_h_in};
    wire signed [16:0] cfg_w_out_s = {1'b0, cfg_w_out};

    wire signed [16:0] out_col_base_s    = $signed({1'b0, w_blk_cnt}) * 17'sd8;

    // load 引擎根据独立的 load_* 坐标计算当前待装载的半窗。
    wire signed [16:0] load_out_col_base_s = $signed({1'b0, load_w_blk_cnt}) * 17'sd8;
    wire signed [16:0] load_row_s          = $signed({1'b0, load_h_cnt}) + $signed({14'd0, req_row_cnt}) - 17'sd2;
    wire signed [16:0] load_a_col_base_s   = load_out_col_base_s - 17'sd2;
    wire signed [16:0] load_b_col_base_s   = load_out_col_base_s + 17'sd6;
    wire signed [16:0] load_col_base_s   = load_side ? load_b_col_base_s : load_a_col_base_s;
    wire signed [16:0] load_req_col_s    = (load_col_base_s < 17'sd0) ? 17'sd0 : load_col_base_s;
    wire               load_row_valid    = (load_row_s >= 17'sd0) && (load_row_s < cfg_h_in_s);

    wire last_w  = (w_blk_cnt  == cfg_w_out_blocks - 1'b1);
    wire last_ch = (ch_grp_cnt == cfg_ch_groups   - 1'b1);
    wire last_h  = (h_cnt      == cfg_h_out       - 1'b1);

    wire signed [16:0] cur_lowest_s       = $signed({1'b0, h_cnt}) - 17'sd2;
    wire signed [16:0] next_lowest_s      = $signed({1'b0, h_cnt}) - 17'sd1;
    wire signed [16:0] real_cur_lowest_s  = (cur_lowest_s  < 17'sd0) ? 17'sd0 : cur_lowest_s;
    wire signed [16:0] real_next_lowest_s = (next_lowest_s < 17'sd0) ? 17'sd0 : next_lowest_s;
    wire [3:0] free_num_calc = (real_next_lowest_s > real_cur_lowest_s) ?
                               (real_next_lowest_s - real_cur_lowest_s) : 4'd0;

    reg [7:0] load_rd_mask;
    reg [7:0] load_dst_mask;
    reg [7:0] out_mask;
    integer mi;
    integer src_i;

    // 统一组合 next-state，时序块只负责寄存，避免同拍多次写同一寄存器。
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

    wire load_has_mem             = |load_rd_mask;
    wire load_phase_complete_now  = (recv_row_cnt == 3'd5);
    wire load_can_issue           = (load_state == LD_RUN) &&
                                    !load_phase_complete_now &&
                                    (req_row_cnt < 3'd5);
    wire issue_real_req           = load_can_issue && load_has_mem && cbuf_can_read;
    wire issue_pad_row            = load_can_issue && !load_has_mem;
    wire recv_real_row            = (load_state == LD_RUN) && cbuf_rd_dat_vld;
    wire [2:0] recv_inc           = {2'd0, recv_real_row} + {2'd0, issue_pad_row};
    wire load_phase_complete_next = (recv_row_cnt + recv_inc) == 3'd5;

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

    reg  [15:0] h_cnt_n;
    reg  [15:0] ch_grp_cnt_n;
    reg  [15:0] w_blk_cnt_n;
    reg         load_state_n;
    reg         load_side_n;
    reg  [15:0] load_h_cnt_n;
    reg  [15:0] load_ch_grp_cnt_n;
    reg  [15:0] load_w_blk_cnt_n;
    reg  [1:0]  compute_state_n;
    reg         side_a_ready_n;
    reg         side_b_ready_n;
    reg  [2:0]  req_row_cnt_n;
    reg  [2:0]  recv_row_cnt_n;
    reg  [2:0]  tag_wr_ptr_n;
    reg  [2:0]  tag_rd_ptr_n;

    reg         tag_side_n       [0:4];
    reg  [2:0]  tag_row_n        [0:4];
    reg  [7:0]  tag_dst_mask_n   [0:4];
    reg signed [16:0] tag_col_base_s_n [0:4];
    reg signed [16:0] tag_req_col_s_n  [0:4];

    reg  [PIXEL_W-1:0] Reg_A_n [0:4][0:7];
    reg  [PIXEL_W-1:0] Reg_B_n [0:4][0:7];
    reg  [PIXEL_W-1:0] Col_Max_Reg_n [0:11];

    reg  [7:0]                   cbuf_rd_en_n;
    reg  [15:0]                  cbuf_rd_row_n;
    reg  [15:0]                  cbuf_rd_col_align_n;
    reg  [15:0]                  cbuf_rd_ch_grp_n;
    reg                          cbuf_rd_row_free_n;
    reg  [3:0]                   cbuf_rd_free_num_n;
    reg                          obuf_wr_vld_n;
    reg  [2*BANK_NUM-1:0]        obuf_wr_mask_n;
    reg  [2*BANK_NUM*64-1:0]     obuf_wr_dat_n;
    reg                          pool_done_n;

    integer r, p, q;
    integer tr, tc, tp;

    always @(*) begin
        h_cnt_n             = h_cnt;
        ch_grp_cnt_n        = ch_grp_cnt;
        w_blk_cnt_n         = w_blk_cnt;
        load_state_n        = load_state;
        load_side_n         = load_side;
        load_h_cnt_n        = load_h_cnt;
        load_ch_grp_cnt_n   = load_ch_grp_cnt;
        load_w_blk_cnt_n    = load_w_blk_cnt;
        compute_state_n     = compute_state;
        side_a_ready_n      = side_a_ready;
        side_b_ready_n      = side_b_ready;
        req_row_cnt_n       = req_row_cnt;
        recv_row_cnt_n      = recv_row_cnt;
        tag_wr_ptr_n        = tag_wr_ptr;
        tag_rd_ptr_n        = tag_rd_ptr;

        cbuf_rd_en_n        = 8'd0;
        cbuf_rd_row_n       = cbuf_rd_row;
        cbuf_rd_col_align_n = cbuf_rd_col_align;
        cbuf_rd_ch_grp_n    = cbuf_rd_ch_grp;
        cbuf_rd_row_free_n  = 1'b0;
        cbuf_rd_free_num_n  = 4'd0;
        obuf_wr_vld_n       = 1'b0;
        obuf_wr_mask_n      = {2*BANK_NUM{1'b0}};
        obuf_wr_dat_n       = obuf_wr_dat;
        pool_done_n         = 1'b0;

        for (tr = 0; tr < 5; tr = tr + 1) begin
            tag_side_n[tr]       = tag_side[tr];
            tag_row_n[tr]        = tag_row[tr];
            tag_dst_mask_n[tr]   = tag_dst_mask[tr];
            tag_col_base_s_n[tr] = tag_col_base_s[tr];
            tag_req_col_s_n[tr]  = tag_req_col_s[tr];
        end

        for (tr = 0; tr < 5; tr = tr + 1) begin
            for (tc = 0; tc < 8; tc = tc + 1) begin
                Reg_A_n[tr][tc] = Reg_A[tr][tc];
                Reg_B_n[tr][tc] = Reg_B[tr][tc];
            end
        end

        for (tp = 0; tp < 12; tp = tp + 1) begin
            Col_Max_Reg_n[tp] = Col_Max_Reg[tp];
        end

        if (start) begin
            h_cnt_n           = 16'd0;
            ch_grp_cnt_n      = 16'd0;
            w_blk_cnt_n       = 16'd0;
            load_state_n      = LD_RUN;
            load_side_n       = SIDE_A;
            load_h_cnt_n      = 16'd0;
            load_ch_grp_cnt_n = 16'd0;
            load_w_blk_cnt_n  = 16'd0;
            compute_state_n   = CP_IDLE;
            side_a_ready_n    = 1'b0;
            side_b_ready_n    = 1'b0;
            req_row_cnt_n     = 3'd0;
            recv_row_cnt_n    = 3'd0;
            tag_wr_ptr_n      = 3'd0;
            tag_rd_ptr_n      = 3'd0;
        end else begin
            // load 子状态机：先消费返回，再继续发起下一拍请求。
            if (recv_real_row) begin
                if (tag_side[tag_rd_ptr] == SIDE_A) begin
                    for (p = 0; p < 8; p = p + 1) begin
                        if (tag_dst_mask[tag_rd_ptr][p]) begin
                            q = tag_col_base_s[tag_rd_ptr] + p - tag_req_col_s[tag_rd_ptr];
                            Reg_A_n[tag_row[tag_rd_ptr]][p] = cbuf_rd_dat[q*PIXEL_W +: PIXEL_W];
                        end else begin
                            Reg_A_n[tag_row[tag_rd_ptr]][p] = pad_pixel;
                        end
                    end
                end else begin
                    for (p = 0; p < 8; p = p + 1) begin
                        if (tag_dst_mask[tag_rd_ptr][p]) begin
                            q = tag_col_base_s[tag_rd_ptr] + p - tag_req_col_s[tag_rd_ptr];
                            Reg_B_n[tag_row[tag_rd_ptr]][p] = cbuf_rd_dat[q*PIXEL_W +: PIXEL_W];
                        end else begin
                            Reg_B_n[tag_row[tag_rd_ptr]][p] = pad_pixel;
                        end
                    end
                end
                tag_rd_ptr_n = tag_rd_ptr + 1'b1;
            end

            if (load_state == LD_RUN) begin
                if (issue_real_req) begin
                    cbuf_rd_en_n        = load_rd_mask;
                    cbuf_rd_row_n       = load_row_s[15:0];
                    cbuf_rd_col_align_n = load_req_col_s[15:0];
                    cbuf_rd_ch_grp_n    = load_ch_grp_cnt;

                    tag_side_n[tag_wr_ptr]       = load_side;
                    tag_row_n[tag_wr_ptr]        = req_row_cnt;
                    tag_dst_mask_n[tag_wr_ptr]   = load_dst_mask;
                    tag_col_base_s_n[tag_wr_ptr] = load_col_base_s;
                    tag_req_col_s_n[tag_wr_ptr]  = load_req_col_s;

                    tag_wr_ptr_n  = tag_wr_ptr + 1'b1;
                    req_row_cnt_n = req_row_cnt + 1'b1;
                end else if (issue_pad_row) begin
                    if (load_side == SIDE_A) begin
                        for (p = 0; p < 8; p = p + 1) begin
                            Reg_A_n[req_row_cnt][p] = pad_pixel;
                        end
                    end else begin
                        for (p = 0; p < 8; p = p + 1) begin
                            Reg_B_n[req_row_cnt][p] = pad_pixel;
                        end
                    end
                    req_row_cnt_n = req_row_cnt + 1'b1;
                end

                recv_row_cnt_n = recv_row_cnt + recv_inc;

                if (load_phase_complete_next || load_phase_complete_now) begin
                    load_state_n   = LD_IDLE;
                    req_row_cnt_n  = 3'd0;
                    recv_row_cnt_n = 3'd0;
                    tag_wr_ptr_n   = 3'd0;
                    tag_rd_ptr_n   = 3'd0;

                    if (load_side == SIDE_A) begin
                        side_a_ready_n = 1'b1;
                    end else begin
                        side_b_ready_n = 1'b1;
                    end
                end
            end

            case (compute_state)
                CP_IDLE: begin
                    if ((load_state_n == LD_IDLE) && !side_a_ready_n) begin
                        load_state_n      = LD_RUN;
                        load_side_n       = SIDE_A;
                        load_h_cnt_n      = h_cnt;
                        load_ch_grp_cnt_n = ch_grp_cnt;
                        load_w_blk_cnt_n  = w_blk_cnt;
                        req_row_cnt_n     = 3'd0;
                        recv_row_cnt_n    = 3'd0;
                        tag_wr_ptr_n      = 3'd0;
                        tag_rd_ptr_n      = 3'd0;
                    end else if ((load_state_n == LD_IDLE) && side_a_ready_n && !side_b_ready_n) begin
                        load_state_n      = LD_RUN;
                        load_side_n       = SIDE_B;
                        load_h_cnt_n      = h_cnt;
                        load_ch_grp_cnt_n = ch_grp_cnt;
                        load_w_blk_cnt_n  = w_blk_cnt;
                        req_row_cnt_n     = 3'd0;
                        recv_row_cnt_n    = 3'd0;
                        tag_wr_ptr_n      = 3'd0;
                        tag_rd_ptr_n      = 3'd0;
                    end

                    if (side_a_ready_n && side_b_ready_n) begin
                        compute_state_n = CP_STAGE1;
                    end
                end

                CP_STAGE1: begin
                    // 第一级流水：
                    // 1. 对当前块进行列方向最大值比较
                    // 2. 将旧 Reg_B 平移到 Reg_A，供下一块复用
                    for (p = 0; p < 12; p = p + 1) begin
                        Col_Max_Reg_n[p] = Col_Max_Wire[p];
                    end
                    for (r = 0; r < 5; r = r + 1) begin
                        for (p = 0; p < 8; p = p + 1) begin
                            Reg_A_n[r][p] = Reg_B[r][p];
                        end
                    end

                    if (!last_w) begin
                        side_a_ready_n = 1'b1;
                        side_b_ready_n = 1'b0;

                        // 在计算当前块的同时，并行预取下一块的 SIDE_B。
                        if (load_state_n == LD_IDLE) begin
                            load_state_n      = LD_RUN;
                            load_side_n       = SIDE_B;
                            load_h_cnt_n      = h_cnt;
                            load_ch_grp_cnt_n = ch_grp_cnt;
                            load_w_blk_cnt_n  = w_blk_cnt + 1'b1;
                            req_row_cnt_n     = 3'd0;
                            recv_row_cnt_n    = 3'd0;
                            tag_wr_ptr_n      = 3'd0;
                            tag_rd_ptr_n      = 3'd0;
                        end
                    end else begin
                        side_a_ready_n = 1'b0;
                        side_b_ready_n = 1'b0;
                    end

                    compute_state_n = CP_STAGE2;
                end

                CP_STAGE2: begin
                    if (obuf_can_write) begin
                        obuf_wr_vld_n = 1'b1;
                        obuf_wr_dat_n = {(2*BANK_NUM*64){1'b0}};

                        if (ch_grp_cnt[0] == 1'b0) begin
                            obuf_wr_mask_n[7:0]  = out_mask;
                            obuf_wr_mask_n[15:8] = 8'd0;
                            for (p = 0; p < 8; p = p + 1) begin
                                obuf_wr_dat_n[p*64 +: 64] = Row_Max_Wire[p];
                            end
                        end else begin
                            obuf_wr_mask_n[7:0]  = 8'd0;
                            obuf_wr_mask_n[15:8] = out_mask;
                            for (p = 0; p < 8; p = p + 1) begin
                                obuf_wr_dat_n[BANK_NUM*64 + p*64 +: 64] = Row_Max_Wire[p];
                            end
                        end

                        if (last_w && last_ch && (free_num_calc != 4'd0)) begin
                            cbuf_rd_row_free_n = 1'b1;
                            cbuf_rd_free_num_n = free_num_calc;
                        end

                        if (last_w && last_ch && last_h) begin
                            pool_done_n      = 1'b1;
                            compute_state_n  = CP_IDLE;
                            side_a_ready_n   = 1'b0;
                            side_b_ready_n   = 1'b0;
                            load_state_n     = LD_IDLE;
                        end else if (last_w) begin
                            w_blk_cnt_n      = 16'd0;
                            compute_state_n  = CP_IDLE;
                            side_a_ready_n   = 1'b0;
                            side_b_ready_n   = 1'b0;

                            if (last_ch) begin
                                ch_grp_cnt_n = 16'd0;
                                h_cnt_n      = h_cnt + 1'b1;
                            end else begin
                                ch_grp_cnt_n = ch_grp_cnt + 1'b1;
                            end
                        end else begin
                            w_blk_cnt_n      = w_blk_cnt + 1'b1;
                            compute_state_n  = side_b_ready_n ? CP_STAGE1 : CP_IDLE;
                        end
                    end
                end

                default: begin
                    compute_state_n = CP_IDLE;
                end
            endcase

            // 若本拍 load 恰好完成并且当前窗口已经齐备，则下一拍直接启动计算。
            if ((compute_state_n == CP_IDLE) && side_a_ready_n && side_b_ready_n) begin
                compute_state_n = CP_STAGE1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt             <= 16'd0;
            ch_grp_cnt        <= 16'd0;
            w_blk_cnt         <= 16'd0;
            load_state        <= LD_IDLE;
            load_side         <= SIDE_A;
            load_h_cnt        <= 16'd0;
            load_ch_grp_cnt   <= 16'd0;
            load_w_blk_cnt    <= 16'd0;
            compute_state     <= CP_IDLE;
            side_a_ready      <= 1'b0;
            side_b_ready      <= 1'b0;
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

            for (tr = 0; tr < 5; tr = tr + 1) begin
                tag_side[tr]       <= SIDE_A;
                tag_row[tr]        <= 3'd0;
                tag_dst_mask[tr]   <= 8'd0;
                tag_col_base_s[tr] <= 17'sd0;
                tag_req_col_s[tr]  <= 17'sd0;
            end

            for (tr = 0; tr < 5; tr = tr + 1) begin
                for (tc = 0; tc < 8; tc = tc + 1) begin
                    Reg_A[tr][tc] <= {PIXEL_W{1'b0}};
                    Reg_B[tr][tc] <= {PIXEL_W{1'b0}};
                end
            end

            for (tp = 0; tp < 12; tp = tp + 1) begin
                Col_Max_Reg[tp] <= {PIXEL_W{1'b0}};
            end
        end else begin
            h_cnt             <= h_cnt_n;
            ch_grp_cnt        <= ch_grp_cnt_n;
            w_blk_cnt         <= w_blk_cnt_n;
            load_state        <= load_state_n;
            load_side         <= load_side_n;
            load_h_cnt        <= load_h_cnt_n;
            load_ch_grp_cnt   <= load_ch_grp_cnt_n;
            load_w_blk_cnt    <= load_w_blk_cnt_n;
            compute_state     <= compute_state_n;
            side_a_ready      <= side_a_ready_n;
            side_b_ready      <= side_b_ready_n;
            req_row_cnt       <= req_row_cnt_n;
            recv_row_cnt      <= recv_row_cnt_n;
            tag_wr_ptr        <= tag_wr_ptr_n;
            tag_rd_ptr        <= tag_rd_ptr_n;

            cbuf_rd_en        <= cbuf_rd_en_n;
            cbuf_rd_row       <= cbuf_rd_row_n;
            cbuf_rd_col_align <= cbuf_rd_col_align_n;
            cbuf_rd_ch_grp    <= cbuf_rd_ch_grp_n;
            cbuf_rd_row_free  <= cbuf_rd_row_free_n;
            cbuf_rd_free_num  <= cbuf_rd_free_num_n;
            obuf_wr_vld       <= obuf_wr_vld_n;
            obuf_wr_mask      <= obuf_wr_mask_n;
            obuf_wr_dat       <= obuf_wr_dat_n;
            pool_done         <= pool_done_n;

            for (tr = 0; tr < 5; tr = tr + 1) begin
                tag_side[tr]       <= tag_side_n[tr];
                tag_row[tr]        <= tag_row_n[tr];
                tag_dst_mask[tr]   <= tag_dst_mask_n[tr];
                tag_col_base_s[tr] <= tag_col_base_s_n[tr];
                tag_req_col_s[tr]  <= tag_req_col_s_n[tr];
            end

            for (tr = 0; tr < 5; tr = tr + 1) begin
                for (tc = 0; tc < 8; tc = tc + 1) begin
                    Reg_A[tr][tc] <= Reg_A_n[tr][tc];
                    Reg_B[tr][tc] <= Reg_B_n[tr][tc];
                end
            end

            for (tp = 0; tp < 12; tp = tp + 1) begin
                Col_Max_Reg[tp] <= Col_Max_Reg_n[tp];
            end
        end
    end

endmodule
