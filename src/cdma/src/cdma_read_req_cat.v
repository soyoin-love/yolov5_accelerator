`timescale 1ns / 1ps

module cdma_read_req_cat #(
    parameter ROW_BLOCKS = 8
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] cfg_base_addr,
    input  wire [15:0] cfg_width,
    input  wire [15:0] cfg_height,
    input  wire [15:0] cfg_ch_groups,
    input  wire        cfg_cat_en,
    input  wire        cfg_cat_src0_upsample,
    input  wire [31:0] cfg_cat_src1_base_addr,
    input  wire [15:0] cfg_cat_src0_ch_groups,
    input  wire [31:0] cfg_cat_src0_line_stride,
    input  wire [31:0] cfg_cat_src1_line_stride,
    input  wire [31:0] cfg_cat_src0_surface_stride,
    input  wire [31:0] cfg_cat_src1_surface_stride,
    input  wire        rd_row_free,
    input  wire [3:0]  rd_free_num,
    input  wire        mcif_req_rdy,
    output wire        mcif_req_vld,
    output wire [39:0] mcif_req_pd
);

    localparam PHASE_SRC0      = 2'd0;
    localparam PHASE_SRC1_EVEN = 2'd1;
    localparam PHASE_SRC1_ODD  = 2'd2;

    reg        cfg_src0_upsample_r;
    reg [15:0] cfg_unit_rows_r;
    reg [15:0] dst_beats_per_line_r;
    reg [15:0] src0_beats_per_line_r;
    reg [15:0] src0_ch_groups_r;
    reg [15:0] src1_ch_groups_r;
    reg [1:0]  first_phase_r;
    reg [4:0]  credit_cost_r;
    reg [31:0] src0_line_stride_r;
    reg [31:0] src1_line_stride_r;
    reg [31:0] src1_line_stride_x2_r;
    reg [31:0] src0_surface_stride_r;
    reg [31:0] src1_surface_stride_r;
    reg [31:0] src0_row_base_addr_r;
    reg [31:0] src1_even_row_base_addr_r;
    reg [31:0] src1_odd_row_base_addr_r;
    reg [31:0] group_base_addr_r;
    reg [31:0] current_addr_r;
    reg [4:0]  row_credits;
    reg [15:0] req_unit_row;
    reg [15:0] req_local_ch_grp;
    reg [15:0] req_col_beat;
    reg [1:0]  req_phase;

    wire [15:0] src0_width_cfg;
    wire [15:0] src0_beats_cfg;
    wire [15:0] dst_beats_cfg;
    wire [15:0] src0_ch_groups_cfg;
    wire [15:0] src1_ch_groups_cfg;
    wire [15:0] unit_rows_cfg;
    wire [31:0] src0_surface_stride_cfg;
    wire [31:0] src1_surface_stride_cfg;
    wire [31:0] src0_line_stride_cfg;
    wire [31:0] src1_line_stride_cfg;
    wire [31:0] src1_line_stride_x2_cfg;
    wire [1:0]  first_phase_cfg;
    wire [31:0] first_phase_addr_cfg;
    wire [15:0] active_beats_per_line;
    wire [15:0] active_src_ch_groups;
    wire [31:0] active_surface_stride;
    wire [15:0] beats_rem;
    wire [8:0]  cur_burst_len;
    wire [31:0] cur_burst_bytes;
    wire [31:0] next_group_base_addr;
    wire [31:0] next_src0_row_base_addr;
    wire [31:0] next_src1_even_row_base_addr;
    wire [31:0] next_src1_odd_row_base_addr;
    wire [31:0] next_first_phase_addr;
    wire        credits_ok;
    wire        phase_has_data;
    wire        req_ack;
    wire        col_beat_last;
    wire        phase_last_ch_grp;
    wire        phase_done;
    wire        unit_done;

    assign dst_beats_cfg      = (cfg_width + 16'd1) >> 1;
    assign src0_width_cfg     = cfg_cat_src0_upsample ? ((cfg_width + 16'd1) >> 1) : cfg_width;
    assign src0_beats_cfg     = (src0_width_cfg + 16'd1) >> 1;
    assign src0_ch_groups_cfg = cfg_cat_en ? cfg_cat_src0_ch_groups : cfg_ch_groups;
    assign src1_ch_groups_cfg = (cfg_cat_en && (cfg_ch_groups > cfg_cat_src0_ch_groups)) ?
                                (cfg_ch_groups - cfg_cat_src0_ch_groups) : 16'd0;
    assign unit_rows_cfg      = cfg_cat_src0_upsample ? ((cfg_height + 16'd1) >> 1) : cfg_height;
    assign src0_surface_stride_cfg =
        (cfg_cat_src0_surface_stride != 32'd0) ? cfg_cat_src0_surface_stride :
                                                 {12'd0, src0_beats_cfg, 4'd0};
    assign src1_surface_stride_cfg =
        (cfg_cat_en && (cfg_cat_src1_surface_stride != 32'd0)) ? cfg_cat_src1_surface_stride :
                                                                 {12'd0, dst_beats_cfg, 4'd0};
    assign src0_line_stride_cfg =
        (cfg_cat_src0_line_stride != 32'd0) ? cfg_cat_src0_line_stride :
                                              (src0_surface_stride_cfg * src0_ch_groups_cfg);
    assign src1_line_stride_cfg =
        (cfg_cat_en && (cfg_cat_src1_line_stride != 32'd0)) ? cfg_cat_src1_line_stride :
                                                              (src1_surface_stride_cfg * src1_ch_groups_cfg);
    assign src1_line_stride_x2_cfg = src1_line_stride_cfg << 1;
    assign first_phase_cfg         = (src0_ch_groups_cfg != 16'd0) ? PHASE_SRC0 : PHASE_SRC1_EVEN;
    assign first_phase_addr_cfg    = (src0_ch_groups_cfg != 16'd0) ? cfg_base_addr : cfg_cat_src1_base_addr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cfg_src0_upsample_r   <= 1'b0;
            cfg_unit_rows_r       <= 16'd0;
            dst_beats_per_line_r  <= 16'd0;
            src0_beats_per_line_r <= 16'd0;
            src0_ch_groups_r      <= 16'd0;
            src1_ch_groups_r      <= 16'd0;
            first_phase_r         <= PHASE_SRC0;
            credit_cost_r         <= 5'd1;
            src0_line_stride_r    <= 32'd0;
            src1_line_stride_r    <= 32'd0;
            src1_line_stride_x2_r <= 32'd0;
            src0_surface_stride_r <= 32'd0;
            src1_surface_stride_r <= 32'd0;
        end else if (start) begin
            cfg_src0_upsample_r   <= cfg_cat_src0_upsample;
            cfg_unit_rows_r       <= unit_rows_cfg;
            dst_beats_per_line_r  <= dst_beats_cfg;
            src0_beats_per_line_r <= src0_beats_cfg;
            src0_ch_groups_r      <= src0_ch_groups_cfg;
            src1_ch_groups_r      <= src1_ch_groups_cfg;
            first_phase_r         <= first_phase_cfg;
            credit_cost_r         <= cfg_cat_src0_upsample ? 5'd2 : 5'd1;
            src0_line_stride_r    <= src0_line_stride_cfg;
            src1_line_stride_r    <= src1_line_stride_cfg;
            src1_line_stride_x2_r <= src1_line_stride_x2_cfg;
            src0_surface_stride_r <= src0_surface_stride_cfg;
            src1_surface_stride_r <= src1_surface_stride_cfg;
        end
    end

    assign active_beats_per_line = (req_phase == PHASE_SRC0) ? src0_beats_per_line_r : dst_beats_per_line_r;
    assign active_src_ch_groups  = (req_phase == PHASE_SRC0) ? src0_ch_groups_r      : src1_ch_groups_r;
    assign active_surface_stride = (req_phase == PHASE_SRC0) ? src0_surface_stride_r  : src1_surface_stride_r;
    assign phase_has_data        = (active_src_ch_groups != 16'd0);
    assign credits_ok            = cfg_src0_upsample_r ? (row_credits > 5'd1) : (row_credits != 5'd0);
    assign beats_rem             = active_beats_per_line - req_col_beat;
    assign cur_burst_len         = (beats_rem > 16'd256) ? 9'd256 : beats_rem[8:0];
    assign cur_burst_bytes       = {19'd0, cur_burst_len, 4'd0};
    assign next_group_base_addr  = group_base_addr_r + active_surface_stride;
    assign next_src0_row_base_addr = src0_row_base_addr_r + src0_line_stride_r;
    assign next_src1_even_row_base_addr = cfg_src0_upsample_r ?
                                          (src1_even_row_base_addr_r + src1_line_stride_x2_r) :
                                          (src1_even_row_base_addr_r + src1_line_stride_r);
    assign next_src1_odd_row_base_addr  = src1_odd_row_base_addr_r + src1_line_stride_x2_r;
    assign next_first_phase_addr = (first_phase_r == PHASE_SRC0) ? next_src0_row_base_addr :
                                   next_src1_even_row_base_addr;
    assign req_ack               = mcif_req_vld && mcif_req_rdy;
    assign col_beat_last         = req_ack && (beats_rem <= 16'd256);
    assign phase_last_ch_grp     = (active_src_ch_groups != 16'd0) &&
                                   (req_local_ch_grp == active_src_ch_groups - 16'd1);
    assign phase_done            = col_beat_last && phase_last_ch_grp;
    assign unit_done             = phase_done &&
                                   (
                                       (!cfg_src0_upsample_r &&
                                           (((req_phase == PHASE_SRC0) && (src1_ch_groups_r == 16'd0)) ||
                                            (req_phase == PHASE_SRC1_EVEN))) ||
                                       (cfg_src0_upsample_r &&
                                           (((req_phase == PHASE_SRC0) && (src1_ch_groups_r == 16'd0)) ||
                                            (req_phase == PHASE_SRC1_ODD)))
                                   );
    assign mcif_req_vld          = credits_ok && (req_unit_row < cfg_unit_rows_r) && phase_has_data;
    assign mcif_req_pd           = {(cur_burst_len[7:0] - 8'd1), current_addr_r};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_credits <= 5'd0;
        end else if (start) begin
            row_credits <= ROW_BLOCKS[4:0];
        end else begin
            case ({rd_row_free, unit_done})
                2'b10: row_credits <= row_credits + rd_free_num;
                2'b01: row_credits <= row_credits - credit_cost_r;
                2'b11: row_credits <= row_credits + rd_free_num - credit_cost_r;
                default: row_credits <= row_credits;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_unit_row     <= 16'd0;
            req_local_ch_grp <= 16'd0;
            req_col_beat     <= 16'd0;
            req_phase        <= PHASE_SRC0;
        end else if (start) begin
            req_unit_row     <= 16'd0;
            req_local_ch_grp <= 16'd0;
            req_col_beat     <= 16'd0;
            req_phase        <= first_phase_cfg;
        end else if (req_ack) begin
            if (col_beat_last) begin
                req_col_beat <= 16'd0;
                if (phase_done) begin
                    req_local_ch_grp <= 16'd0;
                    if (cfg_src0_upsample_r) begin
                        case (req_phase)
                            PHASE_SRC0: begin
                                if (src1_ch_groups_r != 16'd0) begin
                                    req_phase <= PHASE_SRC1_EVEN;
                                end else begin
                                    req_phase    <= first_phase_r;
                                    req_unit_row <= req_unit_row + 16'd1;
                                end
                            end
                            PHASE_SRC1_EVEN: req_phase <= PHASE_SRC1_ODD;
                            default: begin
                                req_phase    <= first_phase_r;
                                req_unit_row <= req_unit_row + 16'd1;
                            end
                        endcase
                    end else begin
                        case (req_phase)
                            PHASE_SRC0: begin
                                if (src1_ch_groups_r != 16'd0) begin
                                    req_phase <= PHASE_SRC1_EVEN;
                                end else begin
                                    req_phase    <= first_phase_r;
                                    req_unit_row <= req_unit_row + 16'd1;
                                end
                            end
                            default: begin
                                req_phase    <= first_phase_r;
                                req_unit_row <= req_unit_row + 16'd1;
                            end
                        endcase
                    end
                end else begin
                    req_local_ch_grp <= req_local_ch_grp + 16'd1;
                end
            end else begin
                req_col_beat <= req_col_beat + cur_burst_len;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            src0_row_base_addr_r      <= 32'd0;
            src1_even_row_base_addr_r <= 32'd0;
            src1_odd_row_base_addr_r  <= 32'd0;
            group_base_addr_r         <= 32'd0;
            current_addr_r            <= 32'd0;
        end else if (start) begin
            src0_row_base_addr_r      <= cfg_base_addr;
            src1_even_row_base_addr_r <= cfg_cat_src1_base_addr;
            src1_odd_row_base_addr_r  <= cfg_cat_src1_base_addr + src1_line_stride_cfg;
            group_base_addr_r         <= first_phase_addr_cfg;
            current_addr_r            <= first_phase_addr_cfg;
        end else if (req_ack) begin
            if (col_beat_last) begin
                if (phase_done) begin
                    if (cfg_src0_upsample_r) begin
                        case (req_phase)
                            PHASE_SRC0: begin
                                if (src1_ch_groups_r != 16'd0) begin
                                    group_base_addr_r <= src1_even_row_base_addr_r;
                                    current_addr_r    <= src1_even_row_base_addr_r;
                                end else begin
                                    src0_row_base_addr_r      <= next_src0_row_base_addr;
                                    src1_even_row_base_addr_r <= next_src1_even_row_base_addr;
                                    src1_odd_row_base_addr_r  <= next_src1_odd_row_base_addr;
                                    group_base_addr_r         <= next_first_phase_addr;
                                    current_addr_r            <= next_first_phase_addr;
                                end
                            end
                            PHASE_SRC1_EVEN: begin
                                group_base_addr_r <= src1_odd_row_base_addr_r;
                                current_addr_r    <= src1_odd_row_base_addr_r;
                            end
                            default: begin
                                src0_row_base_addr_r      <= next_src0_row_base_addr;
                                src1_even_row_base_addr_r <= next_src1_even_row_base_addr;
                                src1_odd_row_base_addr_r  <= next_src1_odd_row_base_addr;
                                group_base_addr_r         <= next_first_phase_addr;
                                current_addr_r            <= next_first_phase_addr;
                            end
                        endcase
                    end else begin
                        case (req_phase)
                            PHASE_SRC0: begin
                                if (src1_ch_groups_r != 16'd0) begin
                                    group_base_addr_r <= src1_even_row_base_addr_r;
                                    current_addr_r    <= src1_even_row_base_addr_r;
                                end else begin
                                    src0_row_base_addr_r      <= next_src0_row_base_addr;
                                    src1_even_row_base_addr_r <= next_src1_even_row_base_addr;
                                    src1_odd_row_base_addr_r  <= next_src1_odd_row_base_addr;
                                    group_base_addr_r         <= next_first_phase_addr;
                                    current_addr_r            <= next_first_phase_addr;
                                end
                            end
                            default: begin
                                src0_row_base_addr_r      <= next_src0_row_base_addr;
                                src1_even_row_base_addr_r <= next_src1_even_row_base_addr;
                                src1_odd_row_base_addr_r  <= next_src1_odd_row_base_addr;
                                group_base_addr_r         <= next_first_phase_addr;
                                current_addr_r            <= next_first_phase_addr;
                            end
                        endcase
                    end
                end else begin
                    group_base_addr_r <= next_group_base_addr;
                    current_addr_r    <= next_group_base_addr;
                end
            end else begin
                current_addr_r <= current_addr_r + cur_burst_bytes;
            end
        end
    end

endmodule
