`timescale 1ns / 1ps

module cdma_rx_write_cat #(
    parameter BANK_NUM = 8,
    parameter TK_IN    = 8,
    parameter N        = 8
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,
    input  wire [15:0]                        cfg_width,
    input  wire [15:0]                        cfg_height,
    input  wire [15:0]                        cfg_ch_groups,
    input  wire                               cfg_cat_en,
    input  wire                               cfg_cat_src0_upsample,
    input  wire [15:0]                        cfg_cat_src0_ch_groups,
    input  wire                               mcif_rx_vld,
    input  wire [2*TK_IN*N-1:0]               mcif_rx_dat,
    output wire                               mcif_rx_rdy,
    output reg                                wr_en,
    output reg  [15:0]                        wr_row,
    output reg  [15:0]                        wr_col_blk,
    output reg  [15:0]                        wr_ch_grp,
    output reg  [BANK_NUM-1:0]                wr_bank_en,
    output reg  [BANK_NUM*TK_IN*N-1:0]        wr_bank_dat,
    output reg                                wr_row_done
);

    localparam PHASE_SRC0      = 2'd0;
    localparam PHASE_SRC1_EVEN = 2'd1;
    localparam PHASE_SRC1_ODD  = 2'd2;
    localparam PIXEL_W         = TK_IN * N;

    reg        cfg_src0_upsample_r;
    reg [15:0] cfg_unit_rows_r;
    reg [15:0] dst_beats_per_line_r;
    reg [15:0] src0_width_r;
    reg [15:0] src0_beats_per_line_r;
    reg [15:0] src0_ch_groups_r;
    reg [15:0] src1_ch_groups_r;
    reg [1:0]  first_phase_r;
    reg        input_active_r;
    reg [15:0] rx_unit_row;
    reg [15:0] rx_local_ch_grp;
    reg [15:0] rx_col_beat;
    reg [1:0]  rx_phase;
    reg [1:0]  up_buf_valid;
    reg [15:0] up_buf_row_even [0:1];
    reg [15:0] up_buf_row_odd  [0:1];
    reg [15:0] up_buf_ch_grp   [0:1];
    reg [15:0] up_buf_col_blk  [0:1];
    reg [7:0]  up_buf_bank_en  [0:1];
    reg [BANK_NUM*PIXEL_W-1:0] up_buf_bank_dat [0:1];
    reg        up_buf_row_done_even [0:1];
    reg        up_buf_row_done_odd  [0:1];
    reg        emit_active_r;
    reg        emit_odd_r;
    reg        emit_sel_r;
    reg        fill_sel_r;

    wire [15:0] src0_width_cfg;
    wire [15:0] src0_beats_cfg;
    wire [15:0] dst_beats_cfg;
    wire [15:0] src0_ch_groups_cfg;
    wire [15:0] src1_ch_groups_cfg;
    wire [15:0] unit_rows_cfg;
    wire [1:0]  first_phase_cfg;
    wire [15:0] active_beats_per_line;
    wire [15:0] active_src_ch_groups;
    wire        mcif_rx_ack;
    wire        beat_last;
    wire        phase_last_ch_grp;
    wire        phase_done;
    wire        input_done;
    wire        src0_phase_ack;
    wire        src0_block_first;
    wire        src0_block_done;
    wire        direct_write_fire;
    wire        fill_buf_busy;
    wire        emit_pending;
    wire        emit_start_cur;
    wire        emit_start_alt;
    wire        emit_fire;
    wire        emit_fire_sel;
    wire        emit_fire_odd;
    wire [15:0] emit_wr_row;
    wire [15:0] emit_wr_col_blk;
    wire [15:0] emit_wr_ch_grp;
    wire [7:0]  emit_wr_bank_en;
    wire [BANK_NUM*PIXEL_W-1:0] emit_wr_bank_dat;
    wire        emit_wr_row_done;
    wire [15:0] direct_wr_row;
    wire [15:0] direct_wr_col_blk;
    wire [15:0] direct_wr_ch_grp;
    wire        direct_wr_row_done;

    reg [7:0]  direct_bank_en_comb;
    reg [BANK_NUM*PIXEL_W-1:0] direct_bank_dat_comb;
    reg [7:0]  src0_bank_en_comb;
    reg [BANK_NUM*PIXEL_W-1:0] src0_bank_dat_comb;

    integer base_idx;

    assign dst_beats_cfg      = (cfg_width + 16'd1) >> 1;
    assign src0_width_cfg     = cfg_cat_src0_upsample ? ((cfg_width + 16'd1) >> 1) : cfg_width;
    assign src0_beats_cfg     = (src0_width_cfg + 16'd1) >> 1;
    assign src0_ch_groups_cfg = cfg_cat_en ? cfg_cat_src0_ch_groups : cfg_ch_groups;
    assign src1_ch_groups_cfg = (cfg_cat_en && (cfg_ch_groups > cfg_cat_src0_ch_groups)) ?
                                (cfg_ch_groups - cfg_cat_src0_ch_groups) : 16'd0;
    assign unit_rows_cfg      = cfg_cat_src0_upsample ? ((cfg_height + 16'd1) >> 1) : cfg_height;
    assign first_phase_cfg    = (src0_ch_groups_cfg != 16'd0) ? PHASE_SRC0 : PHASE_SRC1_EVEN;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cfg_src0_upsample_r   <= 1'b0;
            cfg_unit_rows_r       <= 16'd0;
            dst_beats_per_line_r  <= 16'd0;
            src0_width_r          <= 16'd0;
            src0_beats_per_line_r <= 16'd0;
            src0_ch_groups_r      <= 16'd0;
            src1_ch_groups_r      <= 16'd0;
            first_phase_r         <= PHASE_SRC0;
        end else if (start) begin
            cfg_src0_upsample_r   <= cfg_cat_src0_upsample;
            cfg_unit_rows_r       <= unit_rows_cfg;
            dst_beats_per_line_r  <= dst_beats_cfg;
            src0_width_r          <= src0_width_cfg;
            src0_beats_per_line_r <= src0_beats_cfg;
            src0_ch_groups_r      <= src0_ch_groups_cfg;
            src1_ch_groups_r      <= src1_ch_groups_cfg;
            first_phase_r         <= first_phase_cfg;
        end
    end

    assign active_beats_per_line = (rx_phase == PHASE_SRC0) ? src0_beats_per_line_r : dst_beats_per_line_r;
    assign active_src_ch_groups  = (rx_phase == PHASE_SRC0) ? src0_ch_groups_r      : src1_ch_groups_r;
    assign mcif_rx_ack           = mcif_rx_vld && mcif_rx_rdy;
    assign beat_last             = mcif_rx_ack &&
                                   (active_beats_per_line != 16'd0) &&
                                   (rx_col_beat == active_beats_per_line - 16'd1);
    assign phase_last_ch_grp     = (active_src_ch_groups != 16'd0) &&
                                   (rx_local_ch_grp == active_src_ch_groups - 16'd1);
    assign phase_done            = beat_last && phase_last_ch_grp;
    assign input_done            = phase_done &&
                                   (cfg_unit_rows_r != 16'd0) &&
                                   (rx_unit_row == cfg_unit_rows_r - 16'd1) &&
                                   (
                                       (!cfg_src0_upsample_r &&
                                           (((rx_phase == PHASE_SRC0) && (src1_ch_groups_r == 16'd0)) ||
                                            (rx_phase == PHASE_SRC1_EVEN))) ||
                                       (cfg_src0_upsample_r &&
                                           (((rx_phase == PHASE_SRC0) && (src1_ch_groups_r == 16'd0)) ||
                                            (rx_phase == PHASE_SRC1_ODD)))
                                   );
    assign src0_phase_ack        = mcif_rx_ack && cfg_src0_upsample_r && (rx_phase == PHASE_SRC0);
    assign src0_block_first      = src0_phase_ack && (rx_col_beat[0] == 1'b0);
    assign src0_block_done       = src0_phase_ack && (rx_col_beat[0] || beat_last);
    assign fill_buf_busy         = up_buf_valid[fill_sel_r] || (emit_active_r && (emit_sel_r == fill_sel_r));
    assign emit_pending          = emit_active_r || up_buf_valid[0] || up_buf_valid[1];
    assign emit_start_cur        = !emit_active_r && up_buf_valid[emit_sel_r];
    assign emit_start_alt        = !emit_active_r && !up_buf_valid[emit_sel_r] && up_buf_valid[~emit_sel_r];
    assign emit_fire             = emit_active_r || emit_start_cur || emit_start_alt;
    assign emit_fire_sel         = emit_active_r ? emit_sel_r :
                                   (emit_start_cur ? emit_sel_r : ~emit_sel_r);
    assign emit_fire_odd         = emit_active_r ? emit_odd_r : 1'b0;
    assign emit_wr_row           = emit_fire_odd ?
                                   (emit_fire_sel ? up_buf_row_odd[1]      : up_buf_row_odd[0]) :
                                   (emit_fire_sel ? up_buf_row_even[1]     : up_buf_row_even[0]);
    assign emit_wr_col_blk       = emit_fire_sel ? up_buf_col_blk[1]        : up_buf_col_blk[0];
    assign emit_wr_ch_grp        = emit_fire_sel ? up_buf_ch_grp[1]         : up_buf_ch_grp[0];
    assign emit_wr_bank_en       = emit_fire_sel ? up_buf_bank_en[1]        : up_buf_bank_en[0];
    assign emit_wr_bank_dat      = emit_fire_sel ? up_buf_bank_dat[1]       : up_buf_bank_dat[0];
    assign emit_wr_row_done      = emit_fire_odd ?
                                   (emit_fire_sel ? up_buf_row_done_odd[1]  : up_buf_row_done_odd[0]) :
                                   (emit_fire_sel ? up_buf_row_done_even[1] : up_buf_row_done_even[0]);
    assign direct_write_fire     = mcif_rx_ack && (!cfg_src0_upsample_r || (rx_phase != PHASE_SRC0));
    assign direct_wr_row         = cfg_src0_upsample_r ?
                                   ((rx_phase == PHASE_SRC1_ODD) ? ((rx_unit_row << 1) + 16'd1) :
                                                                   (rx_unit_row << 1)) :
                                   rx_unit_row;
    assign direct_wr_col_blk     = rx_col_beat >> 2;
    assign direct_wr_ch_grp      = (rx_phase == PHASE_SRC0) ? rx_local_ch_grp :
                                   (src0_ch_groups_r + rx_local_ch_grp);
    assign direct_wr_row_done    = phase_done &&
                                   (
                                       (!cfg_src0_upsample_r &&
                                           (((rx_phase == PHASE_SRC0) && (src1_ch_groups_r == 16'd0)) ||
                                            (rx_phase == PHASE_SRC1_EVEN))) ||
                                       (cfg_src0_upsample_r &&
                                           (((rx_phase == PHASE_SRC1_EVEN) && (src1_ch_groups_r != 16'd0)) ||
                                            (rx_phase == PHASE_SRC1_ODD)))
                                   );

    always @(*) begin
        direct_bank_en_comb  = 8'd0;
        direct_bank_dat_comb = {(BANK_NUM*PIXEL_W){1'b0}};
        case (rx_col_beat[1:0])
            2'd0: begin
                direct_bank_en_comb[0] = 1'b1;
                direct_bank_en_comb[1] = 1'b1;
                direct_bank_dat_comb[0*PIXEL_W +: PIXEL_W] = mcif_rx_dat[PIXEL_W-1:0];
                direct_bank_dat_comb[1*PIXEL_W +: PIXEL_W] = mcif_rx_dat[2*PIXEL_W-1:PIXEL_W];
            end
            2'd1: begin
                direct_bank_en_comb[2] = 1'b1;
                direct_bank_en_comb[3] = 1'b1;
                direct_bank_dat_comb[2*PIXEL_W +: PIXEL_W] = mcif_rx_dat[PIXEL_W-1:0];
                direct_bank_dat_comb[3*PIXEL_W +: PIXEL_W] = mcif_rx_dat[2*PIXEL_W-1:PIXEL_W];
            end
            2'd2: begin
                direct_bank_en_comb[4] = 1'b1;
                direct_bank_en_comb[5] = 1'b1;
                direct_bank_dat_comb[4*PIXEL_W +: PIXEL_W] = mcif_rx_dat[PIXEL_W-1:0];
                direct_bank_dat_comb[5*PIXEL_W +: PIXEL_W] = mcif_rx_dat[2*PIXEL_W-1:PIXEL_W];
            end
            default: begin
                direct_bank_en_comb[6] = 1'b1;
                direct_bank_en_comb[7] = 1'b1;
                direct_bank_dat_comb[6*PIXEL_W +: PIXEL_W] = mcif_rx_dat[PIXEL_W-1:0];
                direct_bank_dat_comb[7*PIXEL_W +: PIXEL_W] = mcif_rx_dat[2*PIXEL_W-1:PIXEL_W];
            end
        endcase
    end

    always @(*) begin
        src0_bank_en_comb  = 8'd0;
        src0_bank_dat_comb = {(BANK_NUM*PIXEL_W){1'b0}};
        base_idx = rx_col_beat[0] ? 4 : 0;

        if ((rx_col_beat << 1) < src0_width_r) begin
            src0_bank_en_comb[base_idx + 0] = 1'b1;
            src0_bank_en_comb[base_idx + 1] = 1'b1;
            src0_bank_dat_comb[(base_idx + 0)*PIXEL_W +: PIXEL_W] = mcif_rx_dat[PIXEL_W-1:0];
            src0_bank_dat_comb[(base_idx + 1)*PIXEL_W +: PIXEL_W] = mcif_rx_dat[PIXEL_W-1:0];
        end

        if (((rx_col_beat << 1) + 16'd1) < src0_width_r) begin
            src0_bank_en_comb[base_idx + 2] = 1'b1;
            src0_bank_en_comb[base_idx + 3] = 1'b1;
            src0_bank_dat_comb[(base_idx + 2)*PIXEL_W +: PIXEL_W] = mcif_rx_dat[2*PIXEL_W-1:PIXEL_W];
            src0_bank_dat_comb[(base_idx + 3)*PIXEL_W +: PIXEL_W] = mcif_rx_dat[2*PIXEL_W-1:PIXEL_W];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_active_r  <= 1'b0;
            rx_unit_row     <= 16'd0;
            rx_local_ch_grp <= 16'd0;
            rx_col_beat     <= 16'd0;
            rx_phase        <= PHASE_SRC0;
        end else if (start) begin
            input_active_r  <= (unit_rows_cfg != 16'd0);
            rx_unit_row     <= 16'd0;
            rx_local_ch_grp <= 16'd0;
            rx_col_beat     <= 16'd0;
            rx_phase        <= first_phase_cfg;
        end else if (mcif_rx_ack) begin
            if (input_done) begin
                input_active_r <= 1'b0;
            end
            if (beat_last) begin
                rx_col_beat <= 16'd0;
                if (phase_done) begin
                    rx_local_ch_grp <= 16'd0;
                    if (cfg_src0_upsample_r) begin
                        case (rx_phase)
                            PHASE_SRC0: begin
                                if (src1_ch_groups_r != 16'd0) begin
                                    rx_phase <= PHASE_SRC1_EVEN;
                                end else begin
                                    rx_phase    <= first_phase_r;
                                    rx_unit_row <= rx_unit_row + 16'd1;
                                end
                            end
                            PHASE_SRC1_EVEN: rx_phase <= PHASE_SRC1_ODD;
                            default: begin
                                rx_phase    <= first_phase_r;
                                rx_unit_row <= rx_unit_row + 16'd1;
                            end
                        endcase
                    end else begin
                        case (rx_phase)
                            PHASE_SRC0: begin
                                if (src1_ch_groups_r != 16'd0) begin
                                    rx_phase <= PHASE_SRC1_EVEN;
                                end else begin
                                    rx_phase    <= first_phase_r;
                                    rx_unit_row <= rx_unit_row + 16'd1;
                                end
                            end
                            default: begin
                                rx_phase    <= first_phase_r;
                                rx_unit_row <= rx_unit_row + 16'd1;
                            end
                        endcase
                    end
                end else begin
                    rx_local_ch_grp <= rx_local_ch_grp + 16'd1;
                end
            end else begin
                rx_col_beat <= rx_col_beat + 16'd1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            up_buf_valid[0]         <= 1'b0;
            up_buf_valid[1]         <= 1'b0;
            up_buf_row_even[0]      <= 16'd0;
            up_buf_row_even[1]      <= 16'd0;
            up_buf_row_odd[0]       <= 16'd0;
            up_buf_row_odd[1]       <= 16'd0;
            up_buf_ch_grp[0]        <= 16'd0;
            up_buf_ch_grp[1]        <= 16'd0;
            up_buf_col_blk[0]       <= 16'd0;
            up_buf_col_blk[1]       <= 16'd0;
            up_buf_bank_en[0]       <= 8'd0;
            up_buf_bank_en[1]       <= 8'd0;
            up_buf_bank_dat[0]      <= {(BANK_NUM*PIXEL_W){1'b0}};
            up_buf_bank_dat[1]      <= {(BANK_NUM*PIXEL_W){1'b0}};
            up_buf_row_done_even[0] <= 1'b0;
            up_buf_row_done_even[1] <= 1'b0;
            up_buf_row_done_odd[0]  <= 1'b0;
            up_buf_row_done_odd[1]  <= 1'b0;
            emit_active_r           <= 1'b0;
            emit_odd_r              <= 1'b0;
            emit_sel_r              <= 1'b0;
            fill_sel_r              <= 1'b0;
        end else if (start) begin
            up_buf_valid[0]         <= 1'b0;
            up_buf_valid[1]         <= 1'b0;
            up_buf_bank_en[0]       <= 8'd0;
            up_buf_bank_en[1]       <= 8'd0;
            up_buf_bank_dat[0]      <= {(BANK_NUM*PIXEL_W){1'b0}};
            up_buf_bank_dat[1]      <= {(BANK_NUM*PIXEL_W){1'b0}};
            up_buf_row_done_even[0] <= 1'b0;
            up_buf_row_done_even[1] <= 1'b0;
            up_buf_row_done_odd[0]  <= 1'b0;
            up_buf_row_done_odd[1]  <= 1'b0;
            emit_active_r           <= 1'b0;
            emit_odd_r              <= 1'b0;
            emit_sel_r              <= 1'b0;
            fill_sel_r              <= 1'b0;
        end else begin
            if (src0_phase_ack) begin
                if (src0_block_first) begin
                    up_buf_valid[fill_sel_r]         <= 1'b0;
                    up_buf_row_even[fill_sel_r]      <= (rx_unit_row << 1);
                    up_buf_row_odd[fill_sel_r]       <= (rx_unit_row << 1) + 16'd1;
                    up_buf_ch_grp[fill_sel_r]        <= rx_local_ch_grp;
                    up_buf_col_blk[fill_sel_r]       <= (rx_col_beat >> 1);
                    up_buf_bank_en[fill_sel_r]       <= src0_bank_en_comb;
                    up_buf_bank_dat[fill_sel_r]      <= src0_bank_dat_comb;
                    up_buf_row_done_even[fill_sel_r] <= 1'b0;
                    up_buf_row_done_odd[fill_sel_r]  <= 1'b0;
                end else begin
                    up_buf_bank_en[fill_sel_r]  <= up_buf_bank_en[fill_sel_r] | src0_bank_en_comb;
                    up_buf_bank_dat[fill_sel_r] <= up_buf_bank_dat[fill_sel_r] | src0_bank_dat_comb;
                end
                if (src0_block_done) begin
                    up_buf_valid[fill_sel_r] <= 1'b1;
                    if ((src1_ch_groups_r == 16'd0) && phase_done) begin
                        up_buf_row_done_even[fill_sel_r] <= 1'b1;
                        up_buf_row_done_odd[fill_sel_r]  <= 1'b1;
                    end
                    fill_sel_r <= ~fill_sel_r;
                end
            end

            if (emit_fire) begin
                if (emit_fire_odd) begin
                    up_buf_valid[emit_fire_sel] <= 1'b0;
                    emit_active_r               <= 1'b0;
                    emit_odd_r                  <= 1'b0;
                    emit_sel_r                  <= ~emit_fire_sel;
                end else begin
                    emit_active_r <= 1'b1;
                    emit_odd_r    <= 1'b1;
                    emit_sel_r    <= emit_fire_sel;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_en       <= 1'b0;
            wr_row      <= 16'd0;
            wr_col_blk  <= 16'd0;
            wr_ch_grp   <= 16'd0;
            wr_bank_en  <= {BANK_NUM{1'b0}};
            wr_bank_dat <= {(BANK_NUM*PIXEL_W){1'b0}};
            wr_row_done <= 1'b0;
        end else if (start) begin
            wr_en       <= 1'b0;
            wr_row      <= 16'd0;
            wr_col_blk  <= 16'd0;
            wr_ch_grp   <= 16'd0;
            wr_bank_en  <= {BANK_NUM{1'b0}};
            wr_bank_dat <= {(BANK_NUM*PIXEL_W){1'b0}};
            wr_row_done <= 1'b0;
        end else begin
            wr_en       <= 1'b0;
            wr_row_done <= 1'b0;
            wr_bank_en  <= {BANK_NUM{1'b0}};
            wr_bank_dat <= {(BANK_NUM*PIXEL_W){1'b0}};

            if (emit_fire) begin
                wr_en       <= 1'b1;
                wr_row      <= emit_wr_row;
                wr_col_blk  <= emit_wr_col_blk;
                wr_ch_grp   <= emit_wr_ch_grp;
                wr_bank_en  <= emit_wr_bank_en;
                wr_bank_dat <= emit_wr_bank_dat;
                wr_row_done <= emit_wr_row_done;
            end else if (direct_write_fire) begin
                wr_en       <= 1'b1;
                wr_row      <= direct_wr_row;
                wr_col_blk  <= direct_wr_col_blk;
                wr_ch_grp   <= direct_wr_ch_grp;
                wr_bank_en  <= direct_bank_en_comb;
                wr_bank_dat <= direct_bank_dat_comb;
                wr_row_done <= direct_wr_row_done;
            end
        end
    end

    assign mcif_rx_rdy = input_active_r &&
                         (
                             !cfg_src0_upsample_r ? 1'b1 :
                             ((rx_phase == PHASE_SRC0) ? !fill_buf_busy :
                                                         !emit_pending)
                         );

endmodule
