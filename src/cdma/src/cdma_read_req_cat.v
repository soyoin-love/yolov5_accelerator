

`timescale 1ns / 1ps

module cdma_read_req_cat #(
    parameter ROW_BLOCKS = 8
)(
    input  wire        clk,
    input  wire        rst_n,

    // 全局控制与基础张量维度配置
    input  wire        start,
    input  wire [31:0] cfg_base_addr,
    input  wire [15:0] cfg_width,
    input  wire [15:0] cfg_height,
    input  wire [15:0] cfg_ch_groups,

    // virtual concat 配置
    input  wire        cfg_cat_en,
    input  wire [31:0] cfg_cat_src1_base_addr,
    input  wire [15:0] cfg_cat_src0_ch_groups,
    input  wire [31:0] cfg_cat_src0_line_stride,
    input  wire [31:0] cfg_cat_src1_line_stride,
    input  wire [31:0] cfg_cat_src0_surface_stride,
    input  wire [31:0] cfg_cat_src1_surface_stride,

    // 下游行缓存回收 credit
    input  wire        rd_row_free,
    input  wire [3:0]  rd_free_num,

    // MCIF 请求接口
    input  wire        mcif_req_rdy,
    output wire        mcif_req_vld,
    output wire [39:0] mcif_req_pd
);

    // =========================================================================
    // 1. 启动时锁存配置，避免请求周期内反复走长组合链
    // =========================================================================
    reg        cfg_cat_en_r;
    reg [15:0] cfg_height_r;
    reg [15:0] total_beats_per_line_r;

    reg [15:0] src0_ch_groups_r;
    reg [15:0] src1_ch_groups_r;
    reg        first_src_sel_r;

    reg [31:0] src0_line_stride_r;
    reg [31:0] src1_line_stride_r;
    reg [31:0] src0_surface_stride_r;
    reg [31:0] src1_surface_stride_r;

    reg [31:0] src0_row_base_addr_r;
    reg [31:0] src1_row_base_addr_r;
    reg [31:0] group_base_addr_r;
    reg [31:0] current_addr_r;

    wire [15:0] cfg_total_beats_per_line;
    wire [31:0] cfg_default_surface_stride;
    wire [31:0] cfg_default_line_stride;
    wire [15:0] cfg_src0_ch_groups;
    wire [15:0] cfg_src1_ch_groups;
    wire        cfg_first_src_sel;
    wire [31:0] cfg_src0_line_stride_sel;
    wire [31:0] cfg_src1_line_stride_sel;
    wire [31:0] cfg_src0_surface_stride_sel;
    wire [31:0] cfg_src1_surface_stride_sel;
    wire [31:0] cfg_first_addr;

    assign cfg_total_beats_per_line   = (cfg_width + 16'd1) >> 1;
    assign cfg_default_surface_stride = {12'd0, cfg_total_beats_per_line, 4'd0};
    assign cfg_default_line_stride    = cfg_default_surface_stride * cfg_ch_groups;

    assign cfg_src0_ch_groups = cfg_cat_en ? cfg_cat_src0_ch_groups : cfg_ch_groups;
    assign cfg_src1_ch_groups = (cfg_cat_en && (cfg_ch_groups > cfg_cat_src0_ch_groups)) ?
                                (cfg_ch_groups - cfg_cat_src0_ch_groups) : 16'd0;
    assign cfg_first_src_sel  = cfg_cat_en && (cfg_src0_ch_groups == 16'd0) && (cfg_src1_ch_groups != 16'd0);

    assign cfg_src0_surface_stride_sel =
        (cfg_cat_en && (cfg_cat_src0_surface_stride != 32'd0)) ? cfg_cat_src0_surface_stride :
                                                                cfg_default_surface_stride;
    assign cfg_src1_surface_stride_sel =
        (cfg_cat_en && (cfg_cat_src1_surface_stride != 32'd0)) ? cfg_cat_src1_surface_stride :
                                                                cfg_default_surface_stride;

    assign cfg_src0_line_stride_sel =
        (cfg_cat_en && (cfg_cat_src0_line_stride != 32'd0)) ? cfg_cat_src0_line_stride :
                                                              (cfg_default_surface_stride * cfg_src0_ch_groups);
    assign cfg_src1_line_stride_sel =
        (cfg_cat_en && (cfg_cat_src1_line_stride != 32'd0)) ? cfg_cat_src1_line_stride :
                                                              (cfg_default_surface_stride * cfg_src1_ch_groups);

    assign cfg_first_addr = cfg_first_src_sel ? cfg_cat_src1_base_addr : cfg_base_addr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cfg_cat_en_r           <= 1'b0;
            cfg_height_r           <= 16'd0;
            total_beats_per_line_r <= 16'd0;
            src0_ch_groups_r       <= 16'd0;
            src1_ch_groups_r       <= 16'd0;
            first_src_sel_r        <= 1'b0;
            src0_line_stride_r     <= 32'd0;
            src1_line_stride_r     <= 32'd0;
            src0_surface_stride_r  <= 32'd0;
            src1_surface_stride_r  <= 32'd0;
        end else if (start) begin
            cfg_cat_en_r           <= cfg_cat_en;
            cfg_height_r           <= cfg_height;
            total_beats_per_line_r <= cfg_total_beats_per_line;
            src0_ch_groups_r       <= cfg_src0_ch_groups;
            src1_ch_groups_r       <= cfg_src1_ch_groups;
            first_src_sel_r        <= cfg_first_src_sel;
            src0_line_stride_r     <= cfg_src0_line_stride_sel;
            src1_line_stride_r     <= cfg_src1_line_stride_sel;
            src0_surface_stride_r  <= cfg_src0_surface_stride_sel;
            src1_surface_stride_r  <= cfg_src1_surface_stride_sel;
        end
    end

    // =========================================================================
    // 2. 请求状态寄存器
    // =========================================================================
    reg [4:0]  row_credits;
    reg [15:0] req_row;
    reg [15:0] req_local_ch_grp;
    reg [15:0] req_col_beat;
    reg        req_src_sel;

    wire [15:0] active_src_ch_groups;
    wire [31:0] active_surface_stride;
    wire [15:0] beats_rem;
    wire [8:0]  cur_burst_len;
    wire [31:0] cur_burst_bytes;
    wire [31:0] next_group_base_addr;
    wire [31:0] next_src0_row_base_addr;
    wire [31:0] next_src1_row_base_addr;
    wire [31:0] next_row_first_addr;

    wire        req_ack;
    wire        col_beat_last;
    wire        active_src_last;
    wire        current_src_is_last;
    wire        req_row_done;

    assign active_src_ch_groups = req_src_sel ? src1_ch_groups_r : src0_ch_groups_r;
    assign active_surface_stride = req_src_sel ? src1_surface_stride_r : src0_surface_stride_r;

    assign beats_rem            = total_beats_per_line_r - req_col_beat;
    assign cur_burst_len        = (beats_rem > 16'd256) ? 9'd256 : beats_rem[8:0];
    assign cur_burst_bytes      = {19'd0, cur_burst_len, 4'd0};
    assign next_group_base_addr = group_base_addr_r + active_surface_stride;
    assign next_src0_row_base_addr = src0_row_base_addr_r + src0_line_stride_r;
    assign next_src1_row_base_addr = src1_row_base_addr_r + src1_line_stride_r;
    assign next_row_first_addr  = first_src_sel_r ? next_src1_row_base_addr : next_src0_row_base_addr;

    assign req_ack              = mcif_req_vld && mcif_req_rdy;
    assign col_beat_last        = req_ack && (beats_rem <= 16'd256);
    assign active_src_last      = col_beat_last &&
                                (active_src_ch_groups != 16'd0) &&
                                (req_local_ch_grp == active_src_ch_groups - 16'd1);
    assign current_src_is_last  = (!cfg_cat_en_r) || req_src_sel || (src1_ch_groups_r == 16'd0);
    assign req_row_done         = req_ack && active_src_last && current_src_is_last;

    assign mcif_req_vld = (row_credits > 0) &&
                        (req_row < cfg_height_r) &&
                        (active_src_ch_groups != 16'd0);
    assign mcif_req_pd  = {(cur_burst_len[7:0] - 8'd1), current_addr_r};

    // 行 credit 仍与“整行请求完成”保持严格同步。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_credits <= 5'd0;
        end else if (start) begin
            row_credits <= ROW_BLOCKS[4:0];
        end else begin
            case ({rd_row_free, req_row_done})
                2'b10: row_credits <= row_credits + rd_free_num;
                2'b01: row_credits <= row_credits - 5'd1;
                2'b11: row_credits <= row_credits + rd_free_num - 5'd1;
                default: row_credits <= row_credits;
            endcase
        end
    end

    // 这里把 row/source/channel/beat 以及对应地址放在同一个时序块里推进，
    // 保证地址、通道组与行完成脉冲始终按同一拍同步更新。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_row          <= 16'd0;
            req_local_ch_grp <= 16'd0;
            req_col_beat     <= 16'd0;
            req_src_sel      <= 1'b0;
        end else if (start) begin
            req_row          <= 16'd0;
            req_local_ch_grp <= 16'd0;
            req_col_beat     <= 16'd0;
            req_src_sel      <= cfg_first_src_sel;
        end else if (req_ack) begin
            if (col_beat_last) begin
                req_col_beat <= 16'd0;

                if (active_src_last) begin
                    req_local_ch_grp <= 16'd0;

                    if (current_src_is_last) begin
                        req_row        <= req_row + 16'd1;
                        req_src_sel    <= first_src_sel_r;
                    end else begin
                        req_src_sel    <= 1'b1;
                    end
                end else begin
                    req_local_ch_grp <= req_local_ch_grp + 16'd1;
                end
            end else begin
                req_col_beat <= req_col_beat + cur_burst_len;
            end
        end
    end

    // 地址链路改为寄存器递推，避免 row*stride/ch*stride 的长组合路径。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            src0_row_base_addr_r <= 32'd0;
            src1_row_base_addr_r <= 32'd0;
            group_base_addr_r    <= 32'd0;
            current_addr_r       <= 32'd0;
        end else if (start) begin
            src0_row_base_addr_r <= cfg_base_addr;
            src1_row_base_addr_r <= cfg_cat_src1_base_addr;
            group_base_addr_r    <= cfg_first_addr;
            current_addr_r       <= cfg_first_addr;
        end else if (req_ack) begin
            if (col_beat_last) begin
                if (active_src_last) begin
                    if (current_src_is_last) begin
                        src0_row_base_addr_r <= next_src0_row_base_addr;
                        src1_row_base_addr_r <= next_src1_row_base_addr;
                        group_base_addr_r    <= next_row_first_addr;
                        current_addr_r       <= next_row_first_addr;
                    end else begin
                        group_base_addr_r    <= src1_row_base_addr_r;
                        current_addr_r       <= src1_row_base_addr_r;
                    end
                end else begin
                    group_base_addr_r        <= next_group_base_addr;
                    current_addr_r           <= next_group_base_addr;
                end
            end else begin
                current_addr_r <= current_addr_r + cur_burst_bytes;
            end
        end
    end

endmodule
