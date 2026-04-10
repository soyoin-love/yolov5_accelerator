`timescale 1ns / 1ps

module cdma_rx_write_cat #(
    parameter TK_IN = 8,
    parameter N     = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,

    input  wire [15:0]           cfg_width,
    input  wire [15:0]           cfg_ch_groups,
    input  wire [15:0]           cfg_height,

    // virtual concat 配置
    input  wire                  cfg_cat_en,
    input  wire [15:0]           cfg_cat_src0_ch_groups,

    input  wire                  mcif_rx_vld,
    input  wire [2*TK_IN*N-1:0]  mcif_rx_dat,
    output wire                  mcif_rx_rdy,

    output reg                   wr_en,
    output reg [15:0]            wr_row,
    output reg [15:0]            wr_col,
    output reg [15:0]            wr_ch_grp,
    output reg [2*TK_IN*N-1:0]   wr_dat,
    output reg                   wr_row_done
);

    reg  [15:0] rx_row;
    reg  [15:0] rx_col;
    reg  [15:0] rx_local_ch_grp;
    reg         rx_src_sel;
    reg         working;
    reg  [15:0] cfg_height_m1;

    wire [15:0] src0_ch_groups;
    wire [15:0] src1_ch_groups;
    wire        first_src_sel;
    wire [15:0] active_src_ch_groups;

    wire        mcif_rx_ack;
    wire        col_last;
    wire        active_src_last;
    wire        current_src_is_last;
    wire        row_write_last;
    wire        done;
    wire [15:0] out_ch_grp;

    assign src0_ch_groups = cfg_cat_en ? cfg_cat_src0_ch_groups : cfg_ch_groups;
    assign src1_ch_groups = (cfg_cat_en && (cfg_ch_groups > cfg_cat_src0_ch_groups)) ?
                            (cfg_ch_groups - cfg_cat_src0_ch_groups) : 16'd0;
    assign first_src_sel  = cfg_cat_en && (src0_ch_groups == 16'd0) && (src1_ch_groups != 16'd0);

    assign active_src_ch_groups = (!cfg_cat_en) ? cfg_ch_groups :
                                (rx_src_sel ? src1_ch_groups : src0_ch_groups);

    assign mcif_rx_ack      = mcif_rx_vld && mcif_rx_rdy;
    assign col_last         = mcif_rx_ack && (rx_col + 16'd2 >= cfg_width);
    assign active_src_last  = col_last &&
                            (active_src_ch_groups != 16'd0) &&
                            (rx_local_ch_grp == active_src_ch_groups - 16'd1);
    assign current_src_is_last = (!cfg_cat_en) || rx_src_sel || (src1_ch_groups == 16'd0);
    assign row_write_last   = active_src_last && current_src_is_last;
    assign out_ch_grp       = (!cfg_cat_en || !rx_src_sel) ?
                            rx_local_ch_grp :
                            (cfg_cat_src0_ch_groups + rx_local_ch_grp);
    assign done             = mcif_rx_ack && row_write_last && (rx_row == cfg_height_m1);

    // 回写侧严格按请求侧同样的嵌套顺序推进计数，保证 CBUF 坐标一致。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_en       <= 1'b0;
            wr_row      <= 16'd0;
            wr_col      <= 16'd0;
            wr_ch_grp   <= 16'd0;
            wr_dat      <= {(2*TK_IN*N){1'b0}};
            wr_row_done <= 1'b0;
        end else begin
            wr_en       <= mcif_rx_ack;
            wr_row_done <= mcif_rx_ack && row_write_last;

            if (mcif_rx_ack) begin
                wr_row    <= rx_row;
                wr_col    <= rx_col;
                wr_ch_grp <= out_ch_grp;
                wr_dat    <= mcif_rx_dat;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rx_col <= 16'd0;
        end else if (mcif_rx_ack) begin
            if (col_last) begin
                rx_col <= 16'd0;
            end else begin
                rx_col <= rx_col + 16'd2;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rx_local_ch_grp <= 16'd0;
        end else if (col_last) begin
            if (active_src_last) begin
                rx_local_ch_grp <= 16'd0;
            end else begin
                rx_local_ch_grp <= rx_local_ch_grp + 16'd1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_src_sel <= 1'b0;
        end else if (start) begin
            rx_src_sel <= first_src_sel;
        end else if (mcif_rx_ack && active_src_last && cfg_cat_en) begin
            if (current_src_is_last) begin
                rx_src_sel <= first_src_sel;
            end else begin
                rx_src_sel <= 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rx_row <= 16'd0;
        end else if (mcif_rx_ack && row_write_last) begin
            rx_row <= rx_row + 16'd1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cfg_height_m1 <= 16'd0;
        end else if (start) begin
            cfg_height_m1 <= (cfg_height == 16'd0) ? 16'd0 : (cfg_height - 16'd1);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            working <= 1'b0;
        end else if (start) begin
            working <= 1'b1;
        end else if (done) begin
            working <= 1'b0;
        end
    end

    assign mcif_rx_rdy = working;

endmodule
