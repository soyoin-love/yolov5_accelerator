`timescale 1ns / 1ps

// 独立残差加法算子顶层。
// 整个模块拆成三部分并行工作：
// 1. CBUF 读引擎：持续向 CBUF 发读请求，并把返回数据写入 cbuf_fifo；
// 2. RBUF 读引擎：持续向 RBUF 发读请求，并把返回数据写入 rbuf_fifo；
// 3. 写回引擎：当两个 FIFO 都有数据时，同时弹出，送入 1 拍时序 resadd_core，
//    再按写坐标把结果写入 OBUF。
// 这样可以把 CBUF 4 拍、RBUF 3 拍的读延迟完全解耦，避免原来串行等待带来的流水气泡。
module resadd_top #(
    parameter BANK_NUM = 8,
    parameter TK_IN    = 8,
    parameter N        = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         start,

    input  wire [15:0]                  cfg_w_out,
    input  wire [15:0]                  cfg_h_out,
    input  wire [15:0]                  cfg_ch_groups,
    input  wire                         cfg_relu_en,

    input  wire                         cbuf_can_read,
    input  wire [15:0]                  cbuf_status_wr_row_ptr,
    input  wire [15:0]                  cbuf_status_rd_row_ptr,
    output reg  [7:0]                   cbuf_rd_en,
    output reg  [15:0]                  cbuf_rd_row,
    output reg  [15:0]                  cbuf_rd_col_align,
    output reg  [15:0]                  cbuf_rd_ch_grp,
    output reg                          cbuf_rd_row_free,
    output reg  [3:0]                   cbuf_rd_free_num,
    input  wire                         cbuf_rd_dat_vld,
    input  wire [BANK_NUM*TK_IN*N-1:0]  cbuf_rd_dat,

    input  wire                         rbuf_can_read,
    input  wire [15:0]                  rbuf_status_wr_row_ptr,
    input  wire [15:0]                  rbuf_status_rd_row_ptr,
    output reg  [7:0]                   rbuf_rd_en,
    output reg  [15:0]                  rbuf_rd_row,
    output reg  [15:0]                  rbuf_rd_col_align,
    output reg  [15:0]                  rbuf_rd_ch_grp,
    output reg                          rbuf_rd_row_free,
    output reg  [3:0]                   rbuf_rd_free_num,
    input  wire                         rbuf_rd_dat_vld,
    input  wire [BANK_NUM*TK_IN*N-1:0]  rbuf_rd_dat,

    input  wire                         obuf_can_write,
    output reg                          obuf_wr_vld,
    output reg  [2*BANK_NUM-1:0]        obuf_wr_mask,
    output reg  [2*BANK_NUM*64-1:0]     obuf_wr_dat,

    output reg                          resadd_done
);

    localparam DATA_W     = BANK_NUM * TK_IN * N;
    localparam FIFO_DEPTH = 16;

    reg         running;
    reg         c_issue_done;
    reg         r_issue_done;
    reg         w_issue_done;

    reg [15:0]  h_cnt_c;
    reg [15:0]  ch_grp_cnt_c;
    reg [15:0]  w_blk_cnt_c;

    reg [15:0]  h_cnt_r;
    reg [15:0]  ch_grp_cnt_r;
    reg [15:0]  w_blk_cnt_r;

    reg [15:0]  h_cnt_w;
    reg [15:0]  ch_grp_cnt_w;
    reg [15:0]  w_blk_cnt_w;

    reg [4:0]   cbuf_inflight_cnt;
    reg [4:0]   rbuf_inflight_cnt;

    reg         meta_vld_d1;
    reg [7:0]   out_mask_d1;
    reg         ch_grp_odd_d1;
    reg         row_free_d1;
    reg         done_d1;

    wire        cfg_has_work;
    wire [15:0] cfg_w_out_blocks_raw;
    wire [15:0] cfg_w_out_blocks;
    wire [15:0] cfg_h_out_safe;
    wire [15:0] cfg_ch_groups_safe;

    wire [DATA_W-1:0] cbuf_fifo_dout;
    wire [DATA_W-1:0] rbuf_fifo_dout;
    wire              cbuf_fifo_full;
    wire              cbuf_fifo_empty;
    wire              rbuf_fifo_full;
    wire              rbuf_fifo_empty;
    wire [4:0]        cbuf_fifo_used_num;
    wire [4:0]        rbuf_fifo_used_num;

    wire              cbuf_fifo_wr_en;
    wire              rbuf_fifo_wr_en;
    wire [5:0]        cbuf_total_used;
    wire [5:0]        rbuf_total_used;

    wire [7:0]        out_mask_c;
    wire [7:0]        out_mask_r;
    wire [7:0]        out_mask_w;
    wire              cbuf_row_ready;
    wire              rbuf_row_ready;

    wire              c_last_w;
    wire              c_last_ch;
    wire              c_last_h;
    wire              r_last_w;
    wire              r_last_ch;
    wire              r_last_h;
    wire              w_last_w;
    wire              w_last_ch;
    wire              w_last_h;

    wire              cbuf_issue_fire;
    wire              rbuf_issue_fire;
    wire              pop_en;
    wire              core_sum_vld;
    wire [DATA_W-1:0] core_sum_dat;

    integer p;

    function [7:0] calc_out_mask;
        input [15:0] cur_w_blk;
        input [15:0] cur_w_out;
        integer i;
        reg [15:0] col_base;
        begin
            col_base = cur_w_blk << 3;
            calc_out_mask = 8'd0;
            for (i = 0; i < 8; i = i + 1) begin
                if ((col_base + i) < cur_w_out) begin
                    calc_out_mask[i] = 1'b1;
                end
            end
        end
    endfunction

    assign cfg_has_work       = (cfg_w_out != 16'd0) && (cfg_h_out != 16'd0) && (cfg_ch_groups != 16'd0);
    assign cfg_w_out_blocks_raw = (cfg_w_out + 16'd7) >> 3;
    assign cfg_w_out_blocks   = cfg_has_work ? cfg_w_out_blocks_raw : 16'd1;
    assign cfg_h_out_safe     = cfg_has_work ? cfg_h_out : 16'd1;
    assign cfg_ch_groups_safe = cfg_has_work ? cfg_ch_groups : 16'd1;

    assign cbuf_fifo_wr_en = cbuf_rd_dat_vld;
    assign rbuf_fifo_wr_en = rbuf_rd_dat_vld;
    assign cbuf_total_used = {1'b0, cbuf_fifo_used_num} + cbuf_inflight_cnt;
    assign rbuf_total_used = {1'b0, rbuf_fifo_used_num} + rbuf_inflight_cnt;

    assign out_mask_c = calc_out_mask(w_blk_cnt_c, cfg_w_out);
    assign out_mask_r = calc_out_mask(w_blk_cnt_r, cfg_w_out);
    assign out_mask_w = calc_out_mask(w_blk_cnt_w, cfg_w_out);
    // ResAdd 的读引擎会超前预取，因此不能只看全局 can_read。
    // 这里额外要求目标行必须处于 [rd_row_ptr, wr_row_ptr) 的安全窗口内，
    // 避免在行槽位复用边界上读到正被下一帧写入的物理地址。
    assign cbuf_row_ready = (h_cnt_c >= cbuf_status_rd_row_ptr) &&
                            (h_cnt_c <  cbuf_status_wr_row_ptr);
    assign rbuf_row_ready = (h_cnt_r >= rbuf_status_rd_row_ptr) &&
                            (h_cnt_r <  rbuf_status_wr_row_ptr);

    assign c_last_w  = (w_blk_cnt_c  == cfg_w_out_blocks   - 1'b1);
    assign c_last_ch = (ch_grp_cnt_c == cfg_ch_groups_safe - 1'b1);
    assign c_last_h  = (h_cnt_c      == cfg_h_out_safe     - 1'b1);

    assign r_last_w  = (w_blk_cnt_r  == cfg_w_out_blocks   - 1'b1);
    assign r_last_ch = (ch_grp_cnt_r == cfg_ch_groups_safe - 1'b1);
    assign r_last_h  = (h_cnt_r      == cfg_h_out_safe     - 1'b1);

    assign w_last_w  = (w_blk_cnt_w  == cfg_w_out_blocks   - 1'b1);
    assign w_last_ch = (ch_grp_cnt_w == cfg_ch_groups_safe - 1'b1);
    assign w_last_h  = (h_cnt_w      == cfg_h_out_safe     - 1'b1);

    // 生产者只看各自 FIFO 的占用量和在途请求数，互不阻塞。
    assign cbuf_issue_fire = running &&
                            !c_issue_done &&
                            cbuf_can_read &&
                            cbuf_row_ready &&
                            !cbuf_fifo_full &&
                            (cbuf_total_used < FIFO_DEPTH);

    assign rbuf_issue_fire = running &&
                            !r_issue_done &&
                            rbuf_can_read &&
                            rbuf_row_ready &&
                            !rbuf_fifo_full &&
                            (rbuf_total_used < FIFO_DEPTH);

    // 消费者只要同时拿到两路数据，并且 OBUF 当前可写，就弹出一组数据。
    assign pop_en = running &&
                    !w_issue_done &&
                    !cbuf_fifo_empty &&
                    !rbuf_fifo_empty &&
                    obuf_can_write;

    resadd_core #(
        .PIXEL_NUM(BANK_NUM),
        .CH_NUM   (N)
    ) u_resadd_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .in_vld     (pop_en),
        .src0_dat   (cbuf_fifo_dout),
        .src1_dat   (rbuf_fifo_dout),
        .cfg_relu_en(cfg_relu_en),
        .sum_vld    (core_sum_vld),
        .sum_dat    (core_sum_dat)
    );

    resadd_sync_fifo #(
        .DATA_W(DATA_W),
        .DEPTH (FIFO_DEPTH)
    ) u_cbuf_fifo (
        .clk     (clk),
        .rst_n   (rst_n),
        .clr     (start),
        .wr_en   (cbuf_fifo_wr_en),
        .rd_en   (pop_en),
        .din     (cbuf_rd_dat),
        .dout    (cbuf_fifo_dout),
        .full    (cbuf_fifo_full),
        .empty   (cbuf_fifo_empty),
        .used_num(cbuf_fifo_used_num)
    );

    resadd_sync_fifo #(
        .DATA_W(DATA_W),
        .DEPTH (FIFO_DEPTH)
    ) u_rbuf_fifo (
        .clk     (clk),
        .rst_n   (rst_n),
        .clr     (start),
        .wr_en   (rbuf_fifo_wr_en),
        .rd_en   (pop_en),
        .din     (rbuf_rd_dat),
        .dout    (rbuf_fifo_dout),
        .full    (rbuf_fifo_full),
        .empty   (rbuf_fifo_empty),
        .used_num(rbuf_fifo_used_num)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running            <= 1'b0;
            c_issue_done       <= 1'b0;
            r_issue_done       <= 1'b0;
            w_issue_done       <= 1'b0;
            h_cnt_c            <= 16'd0;
            ch_grp_cnt_c       <= 16'd0;
            w_blk_cnt_c        <= 16'd0;
            h_cnt_r            <= 16'd0;
            ch_grp_cnt_r       <= 16'd0;
            w_blk_cnt_r        <= 16'd0;
            h_cnt_w            <= 16'd0;
            ch_grp_cnt_w       <= 16'd0;
            w_blk_cnt_w        <= 16'd0;
            cbuf_inflight_cnt  <= 5'd0;
            rbuf_inflight_cnt  <= 5'd0;
            meta_vld_d1        <= 1'b0;
            out_mask_d1        <= 8'd0;
            ch_grp_odd_d1      <= 1'b0;
            row_free_d1        <= 1'b0;
            done_d1            <= 1'b0;
            cbuf_rd_en         <= 8'd0;
            cbuf_rd_row        <= 16'd0;
            cbuf_rd_col_align  <= 16'd0;
            cbuf_rd_ch_grp     <= 16'd0;
            cbuf_rd_row_free   <= 1'b0;
            cbuf_rd_free_num   <= 4'd0;
            rbuf_rd_en         <= 8'd0;
            rbuf_rd_row        <= 16'd0;
            rbuf_rd_col_align  <= 16'd0;
            rbuf_rd_ch_grp     <= 16'd0;
            rbuf_rd_row_free   <= 1'b0;
            rbuf_rd_free_num   <= 4'd0;
            obuf_wr_vld        <= 1'b0;
            obuf_wr_mask       <= {2*BANK_NUM{1'b0}};
            obuf_wr_dat        <= {(2*BANK_NUM*64){1'b0}};
            resadd_done        <= 1'b0;
        end else begin
            // 单拍脉冲信号默认拉低。
            cbuf_rd_en        <= 8'd0;
            cbuf_rd_row_free  <= 1'b0;
            cbuf_rd_free_num  <= 4'd0;
            rbuf_rd_en        <= 8'd0;
            rbuf_rd_row_free  <= 1'b0;
            rbuf_rd_free_num  <= 4'd0;
            obuf_wr_vld       <= 1'b0;
            obuf_wr_mask      <= {2*BANK_NUM{1'b0}};
            obuf_wr_dat       <= {(2*BANK_NUM*64){1'b0}};
            resadd_done       <= 1'b0;

            if (start) begin
                c_issue_done      <= 1'b0;
                r_issue_done      <= 1'b0;
                w_issue_done      <= 1'b0;
                h_cnt_c           <= 16'd0;
                ch_grp_cnt_c      <= 16'd0;
                w_blk_cnt_c       <= 16'd0;
                h_cnt_r           <= 16'd0;
                ch_grp_cnt_r      <= 16'd0;
                w_blk_cnt_r       <= 16'd0;
                h_cnt_w           <= 16'd0;
                ch_grp_cnt_w      <= 16'd0;
                w_blk_cnt_w       <= 16'd0;
                cbuf_inflight_cnt <= 5'd0;
                rbuf_inflight_cnt <= 5'd0;
                meta_vld_d1       <= 1'b0;
                out_mask_d1       <= 8'd0;
                ch_grp_odd_d1     <= 1'b0;
                row_free_d1       <= 1'b0;
                done_d1           <= 1'b0;

                if (cfg_has_work) begin
                    running <= 1'b1;
                end else begin
                    running     <= 1'b0;
                    resadd_done <= 1'b1;
                end
            end else begin
                // 统计 CBUF 在途请求数，用来避免固定读延迟下 FIFO 溢出。
                case ({cbuf_issue_fire, cbuf_rd_dat_vld})
                    2'b10: cbuf_inflight_cnt <= cbuf_inflight_cnt + 1'b1;
                    2'b01: cbuf_inflight_cnt <= cbuf_inflight_cnt - 1'b1;
                    default: cbuf_inflight_cnt <= cbuf_inflight_cnt;
                endcase

                // 统计 RBUF 在途请求数。
                case ({rbuf_issue_fire, rbuf_rd_dat_vld})
                    2'b10: rbuf_inflight_cnt <= rbuf_inflight_cnt + 1'b1;
                    2'b01: rbuf_inflight_cnt <= rbuf_inflight_cnt - 1'b1;
                    default: rbuf_inflight_cnt <= rbuf_inflight_cnt;
                endcase

                // CBUF 读引擎。
                if (cbuf_issue_fire) begin
                    cbuf_rd_en        <= out_mask_c;
                    cbuf_rd_row       <= h_cnt_c;
                    cbuf_rd_col_align <= w_blk_cnt_c << 3;
                    cbuf_rd_ch_grp    <= ch_grp_cnt_c;

                    if (c_last_w) begin
                        w_blk_cnt_c <= 16'd0;
                        if (c_last_ch) begin
                            ch_grp_cnt_c <= 16'd0;
                            if (c_last_h) begin
                                c_issue_done <= 1'b1;
                            end else begin
                                h_cnt_c <= h_cnt_c + 1'b1;
                            end
                        end else begin
                            ch_grp_cnt_c <= ch_grp_cnt_c + 1'b1;
                        end
                    end else begin
                        w_blk_cnt_c <= w_blk_cnt_c + 1'b1;
                    end
                end

                // RBUF 读引擎。
                if (rbuf_issue_fire) begin
                    rbuf_rd_en        <= out_mask_r;
                    rbuf_rd_row       <= h_cnt_r;
                    rbuf_rd_col_align <= w_blk_cnt_r << 3;
                    rbuf_rd_ch_grp    <= ch_grp_cnt_r;

                    if (r_last_w) begin
                        w_blk_cnt_r <= 16'd0;
                        if (r_last_ch) begin
                            ch_grp_cnt_r <= 16'd0;
                            if (r_last_h) begin
                                r_issue_done <= 1'b1;
                            end else begin
                                h_cnt_r <= h_cnt_r + 1'b1;
                            end
                        end else begin
                            ch_grp_cnt_r <= ch_grp_cnt_r + 1'b1;
                        end
                    end else begin
                        w_blk_cnt_r <= w_blk_cnt_r + 1'b1;
                    end
                end

                // 写回引擎。
                // 当 pop_en 为真时，同时从两个 FIFO 弹出一组数据，送入 1 拍 resadd_core。
                // 写坐标计数器与元信息在这里独立推进，不再依赖全局状态机等待某一路返回。
                if (pop_en) begin
                    meta_vld_d1   <= 1'b1;
                    out_mask_d1   <= out_mask_w;
                    ch_grp_odd_d1 <= ch_grp_cnt_w[0];
                    row_free_d1   <= w_last_w && w_last_ch;
                    done_d1       <= w_last_w && w_last_ch && w_last_h;

                    if (w_last_w) begin
                        w_blk_cnt_w <= 16'd0;
                        if (w_last_ch) begin
                            ch_grp_cnt_w <= 16'd0;
                            if (w_last_h) begin
                                w_issue_done <= 1'b1;
                            end else begin
                                h_cnt_w <= h_cnt_w + 1'b1;
                            end
                        end else begin
                            ch_grp_cnt_w <= ch_grp_cnt_w + 1'b1;
                        end
                    end else begin
                        w_blk_cnt_w <= w_blk_cnt_w + 1'b1;
                    end
                end else begin
                    meta_vld_d1 <= 1'b0;
                end

                // resadd_core 的结果在时钟后沿更新，顶层在下一拍看到有效结果后直接写回 OBUF。
                if (core_sum_vld && meta_vld_d1) begin
                    obuf_wr_vld <= 1'b1;

                    if (ch_grp_odd_d1 == 1'b0) begin
                        obuf_wr_mask[7:0]  <= out_mask_d1;
                        obuf_wr_mask[15:8] <= 8'd0;
                        for (p = 0; p < BANK_NUM; p = p + 1) begin
                            obuf_wr_dat[p*64 +: 64] <= core_sum_dat[p*64 +: 64];
                        end
                    end else begin
                        obuf_wr_mask[7:0]  <= 8'd0;
                        obuf_wr_mask[15:8] <= out_mask_d1;
                        for (p = 0; p < BANK_NUM; p = p + 1) begin
                            obuf_wr_dat[BANK_NUM*64 + p*64 +: 64] <= core_sum_dat[p*64 +: 64];
                        end
                    end

                    if (row_free_d1) begin
                        cbuf_rd_row_free <= 1'b1;
                        cbuf_rd_free_num <= 4'd1;
                        rbuf_rd_row_free <= 1'b1;
                        rbuf_rd_free_num <= 4'd1;
                    end

                    if (done_d1) begin
                        resadd_done  <= 1'b1;
                        running      <= 1'b0;
                        c_issue_done <= 1'b0;
                        r_issue_done <= 1'b0;
                        w_issue_done <= 1'b0;
                    end
                end
            end
        end
    end

endmodule

// 深度 16 的同步 FIFO。
// 这里故意把深度固定为 16，便于综合成 LUTRAM 或 SRL16，节省 BRAM。
module resadd_sync_fifo #(
    parameter DATA_W = 512,
    parameter DEPTH  = 16
)(
    input  wire               clk,
    input  wire               rst_n,
    input  wire               clr,
    input  wire               wr_en,
    input  wire               rd_en,
    input  wire [DATA_W-1:0]  din,
    output wire [DATA_W-1:0]  dout,
    output wire               full,
    output wire               empty,
    output wire [4:0]         used_num
);

    (* ram_style = "distributed" *) reg [DATA_W-1:0] mem [0:DEPTH-1];
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] used_num_r;

    wire wr_fire;
    wire rd_fire;

    assign wr_fire  = wr_en && !full;
    assign rd_fire  = rd_en && !empty;
    assign full     = (used_num_r == DEPTH);
    assign empty    = (used_num_r == 5'd0);
    assign used_num = used_num_r;
    assign dout     = mem[rd_ptr];

    always @(posedge clk) begin
        if (wr_fire) begin
            mem[wr_ptr] <= din;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr     <= 4'd0;
            rd_ptr     <= 4'd0;
            used_num_r <= 5'd0;
        end else if (clr) begin
            wr_ptr     <= 4'd0;
            rd_ptr     <= 4'd0;
            used_num_r <= 5'd0;
        end else begin
            case ({wr_fire, rd_fire})
                2'b10: begin
                    wr_ptr     <= wr_ptr + 1'b1;
                    used_num_r <= used_num_r + 1'b1;
                end
                2'b01: begin
                    rd_ptr     <= rd_ptr + 1'b1;
                    used_num_r <= used_num_r - 1'b1;
                end
                2'b11: begin
                    wr_ptr <= wr_ptr + 1'b1;
                    rd_ptr <= rd_ptr + 1'b1;
                end
                default: begin
                    wr_ptr     <= wr_ptr;
                    rd_ptr     <= rd_ptr;
                    used_num_r <= used_num_r;
                end
            endcase
        end
    end

endmodule
