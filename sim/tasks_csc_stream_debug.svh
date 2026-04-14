`ifndef TB_TASKS_CSC_STREAM_DEBUG_SVH
`define TB_TASKS_CSC_STREAM_DEBUG_SVH

// ============================================================================
// CSC 数据流调试任务
// 1. 检查送入 MAC 的 feature 数据是否与软件参考一致。
// 2. 检查送入 MAC 的 weight 数据是否与软件参考一致。
// 3. 对 stride=2 场景补充 phase0/phase1 专用调试，打印：
//    - phase0 保存进 saved_cbuf_dat 的原始拍
//    - phase1 当前拍读回的原始拍
//    - 最终拼好的 mac_features_in
// 4. 将卷积位置计数器和期望/实际总线拉到 testbench 作用域，便于波形定位。
// ============================================================================

bit     csc_dbg_en                    = 1'b0;
integer csc_dbg_max_print             = 20;
integer csc_dbg_cbuf_err_cnt          = 0;
integer csc_dbg_wbuf_err_cnt          = 0;
integer csc_dbg_phase_err_cnt         = 0;
integer csc_dbg_cbuf_print_cnt        = 0;
integer csc_dbg_wbuf_print_cnt        = 0;
integer csc_dbg_phase_print_cnt       = 0;

// 这组信号会直接显示在波形里，用于快速定位当前 MAC 输入对应的卷积位置。
bit     csc_dbg_ctx_valid_cur         = 1'b0;
bit     csc_dbg_phase_pair_valid_cur  = 1'b0;
integer csc_dbg_h_cur                 = 0;
integer csc_dbg_w_blk_cur             = 0;
integer csc_dbg_ci_grp_cur            = 0;
integer csc_dbg_co_grp_cur            = 0;
integer csc_dbg_kx_cur                = 0;
integer csc_dbg_ky_cur                = 0;
integer csc_dbg_in_row_cur            = 0;
integer csc_dbg_in_col_base_cur       = 0;

// 期望值与实际值总线，方便直接在波形里查看。
logic [8*64-1:0]  csc_dbg_cbuf_expected_dat       = '0;
logic [8*64-1:0]  csc_dbg_cbuf_actual_dat         = '0;
logic [8*128-1:0] csc_dbg_wbuf_expected_dat       = '0;
logic [8*128-1:0] csc_dbg_wbuf_actual_dat         = '0;
logic [8*64-1:0]  csc_dbg_phase0_expected_bus     = '0;
logic [8*64-1:0]  csc_dbg_phase0_actual_bus       = '0;
logic [8*64-1:0]  csc_dbg_phase1_expected_bus     = '0;
logic [8*64-1:0]  csc_dbg_phase1_actual_bus       = '0;
logic [8*64-1:0]  csc_dbg_phase_merge_expected_bus = '0;
logic [8*64-1:0]  csc_dbg_phase_merge_actual_bus   = '0;
logic [8*64-1:0]  csc_dbg_phase0_actual_raw_bus   = '0;
logic [8*64-1:0]  csc_dbg_phase1_actual_raw_bus   = '0;

// 为了便于在 ModelSim 中观察，按像素位置把 512bit 总线切成 8 组 64bit。
logic [63:0] csc_dbg_cbuf_expected_pix [0:7];
logic [63:0] csc_dbg_cbuf_actual_pix   [0:7];
logic [63:0] csc_dbg_phase0_expected_pix [0:7];
logic [63:0] csc_dbg_phase0_actual_pix   [0:7];
logic [63:0] csc_dbg_phase1_expected_pix [0:7];
logic [63:0] csc_dbg_phase1_actual_pix   [0:7];
logic [63:0] csc_dbg_merge_expected_pix  [0:7];
logic [63:0] csc_dbg_merge_actual_pix    [0:7];

// 进一步按通道切成 8bit，便于直接查看某个像素位置上的 ch0~ch7。
logic signed [7:0] csc_dbg_cbuf_expected_val [0:7][0:7];
logic signed [7:0] csc_dbg_cbuf_actual_val   [0:7][0:7];
logic signed [7:0] csc_dbg_phase0_expected_val [0:7][0:7];
logic signed [7:0] csc_dbg_phase0_actual_val   [0:7][0:7];
logic signed [7:0] csc_dbg_phase1_expected_val [0:7][0:7];
logic signed [7:0] csc_dbg_phase1_actual_val   [0:7][0:7];
logic signed [7:0] csc_dbg_merge_expected_val  [0:7][0:7];
logic signed [7:0] csc_dbg_merge_actual_val    [0:7][0:7];

// 用于对齐 mac_valid 的上下文流水线。
bit     csc_dbg_ctx_vld_pipe [0:4];
integer csc_dbg_h_pipe       [0:4];
integer csc_dbg_w_blk_pipe   [0:4];
integer csc_dbg_ci_grp_pipe  [0:4];
integer csc_dbg_co_grp_pipe  [0:4];
integer csc_dbg_kx_pipe      [0:4];
integer csc_dbg_ky_pipe      [0:4];
integer csc_dbg_pix_idx;
integer csc_dbg_ch_idx;

// 将大总线拆成按像素/通道可直接展开的调试数组，方便在波形中逐项查看。
always @(*) begin
    for (csc_dbg_pix_idx = 0; csc_dbg_pix_idx < 8; csc_dbg_pix_idx = csc_dbg_pix_idx + 1) begin
        csc_dbg_cbuf_expected_pix[csc_dbg_pix_idx]   = csc_dbg_cbuf_expected_dat[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_cbuf_actual_pix[csc_dbg_pix_idx]     = csc_dbg_cbuf_actual_dat[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_phase0_expected_pix[csc_dbg_pix_idx] = csc_dbg_phase0_expected_bus[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_phase0_actual_pix[csc_dbg_pix_idx]   = csc_dbg_phase0_actual_bus[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_phase1_expected_pix[csc_dbg_pix_idx] = csc_dbg_phase1_expected_bus[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_phase1_actual_pix[csc_dbg_pix_idx]   = csc_dbg_phase1_actual_bus[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_merge_expected_pix[csc_dbg_pix_idx]  = csc_dbg_phase_merge_expected_bus[csc_dbg_pix_idx*64 +: 64];
        csc_dbg_merge_actual_pix[csc_dbg_pix_idx]    = csc_dbg_phase_merge_actual_bus[csc_dbg_pix_idx*64 +: 64];

        for (csc_dbg_ch_idx = 0; csc_dbg_ch_idx < 8; csc_dbg_ch_idx = csc_dbg_ch_idx + 1) begin
            csc_dbg_cbuf_expected_val[csc_dbg_pix_idx][csc_dbg_ch_idx]   =
                csc_dbg_cbuf_expected_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_cbuf_actual_val[csc_dbg_pix_idx][csc_dbg_ch_idx]     =
                csc_dbg_cbuf_actual_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_phase0_expected_val[csc_dbg_pix_idx][csc_dbg_ch_idx] =
                csc_dbg_phase0_expected_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_phase0_actual_val[csc_dbg_pix_idx][csc_dbg_ch_idx]   =
                csc_dbg_phase0_actual_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_phase1_expected_val[csc_dbg_pix_idx][csc_dbg_ch_idx] =
                csc_dbg_phase1_expected_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_phase1_actual_val[csc_dbg_pix_idx][csc_dbg_ch_idx]   =
                csc_dbg_phase1_actual_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_merge_expected_val[csc_dbg_pix_idx][csc_dbg_ch_idx]  =
                csc_dbg_merge_expected_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
            csc_dbg_merge_actual_val[csc_dbg_pix_idx][csc_dbg_ch_idx]    =
                csc_dbg_merge_actual_pix[csc_dbg_pix_idx][csc_dbg_ch_idx*8 +: 8];
        end
    end
end

function automatic logic signed [7:0] csc_dbg_get_ifm_value(
    input integer row_idx,
    input integer col_idx,
    input integer ch_idx
);
    begin
        if ((row_idx < 0) || (row_idx >= Hin) ||
            (col_idx < 0) || (col_idx >= Win) ||
            (ch_idx  < 0) || (ch_idx  >= CHin)) begin
            csc_dbg_get_ifm_value = 8'sd0;
        end else begin
            csc_dbg_get_ifm_value = ref_ifm[row_idx][col_idx][ch_idx];
        end
    end
endfunction

function automatic logic signed [7:0] csc_dbg_get_wt_value(
    input integer oc_idx,
    input integer ic_idx,
    input integer ky_idx,
    input integer kx_idx
);
    begin
        if ((oc_idx < 0) || (oc_idx >= CHout) ||
            (ic_idx < 0) || (ic_idx >= CHin) ||
            (ky_idx < 0) || (ky_idx >= Ky)   ||
            (kx_idx < 0) || (kx_idx >= Kx)) begin
            csc_dbg_get_wt_value = 8'sd0;
        end else begin
            csc_dbg_get_wt_value = ref_wt[oc_idx][ic_idx][ky_idx][kx_idx];
        end
    end
endfunction

// 根据卷积位置构造期望的 MAC feature 总线。
task automatic csc_dbg_build_expected_mac_bus(
    input  integer h_idx,
    input  integer w_blk_idx,
    input  integer ci_grp_idx,
    input  integer kx_idx,
    input  integer ky_idx,
    output logic [8*64-1:0] exp_bus
);
    integer pix_idx;
    integer lane_idx;
    integer in_row_idx;
    integer in_col_idx;
    integer ch_idx;
    begin
        exp_bus    = '0;
        in_row_idx = h_idx * Sy + ky_idx - Py;
        for (pix_idx = 0; pix_idx < 8; pix_idx = pix_idx + 1) begin
            in_col_idx = (w_blk_idx * 8 + pix_idx) * Sx + kx_idx - Px;
            for (lane_idx = 0; lane_idx < 8; lane_idx = lane_idx + 1) begin
                ch_idx = ci_grp_idx * 8 + lane_idx;
                exp_bus[pix_idx*64 + lane_idx*8 +: 8] =
                    csc_dbg_get_ifm_value(in_row_idx, in_col_idx, ch_idx);
            end
        end
    end
endtask

// 对 stride=2 场景，构造 phase0/phase1 两拍各自的原始 CBUF 期望值。
task automatic csc_dbg_build_expected_stride2_phase_bus(
    input  integer h_idx,
    input  integer w_blk_idx,
    input  integer ci_grp_idx,
    input  integer kx_idx,
    input  integer ky_idx,
    output logic [8*64-1:0] phase0_bus,
    output logic [8*64-1:0] phase1_bus
);
    integer lane_idx;
    integer ch_idx;
    integer in_row_idx;
    integer phase0_col_idx;
    integer phase1_col_idx;
    begin
        phase0_bus = '0;
        phase1_bus = '0;
        in_row_idx = h_idx * Sy + ky_idx - Py;
        for (lane_idx = 0; lane_idx < 8; lane_idx = lane_idx + 1) begin
            phase0_col_idx = w_blk_idx * 8 * Sx + kx_idx - Px + lane_idx;
            phase1_col_idx = phase0_col_idx + 8;
            for (ch_idx = 0; ch_idx < 8; ch_idx = ch_idx + 1) begin
                phase0_bus[lane_idx*64 + ch_idx*8 +: 8] =
                    csc_dbg_get_ifm_value(in_row_idx, phase0_col_idx, ci_grp_idx * 8 + ch_idx);
                phase1_bus[lane_idx*64 + ch_idx*8 +: 8] =
                    csc_dbg_get_ifm_value(in_row_idx, phase1_col_idx, ci_grp_idx * 8 + ch_idx);
            end
        end
    end
endtask

// phase 调试应与真实功能路径保持一致：
// 原始 CBUF 返回总线可能在无效 lane 上残留旧值，但最终送入 MAC 前会按 mask 清零。
// 因此这里先按 mask 清洗，再做 phase0/phase1 比较。
task automatic csc_dbg_mask_phase_bus(
    input  logic [8*64-1:0] raw_bus,
    input  logic [7:0]      lane_mask,
    output logic [8*64-1:0] masked_bus
);
    integer pix_idx;
    begin
        masked_bus = '0;
        for (pix_idx = 0; pix_idx < 8; pix_idx = pix_idx + 1) begin
            masked_bus[pix_idx*64 +: 64] =
                lane_mask[pix_idx] ? raw_bus[pix_idx*64 +: 64] : 64'd0;
        end
    end
endtask

task automatic csc_dbg_reset();
    integer idx;
    begin
        csc_dbg_en                     = 1'b0;
        csc_dbg_cbuf_err_cnt           = 0;
        csc_dbg_wbuf_err_cnt           = 0;
        csc_dbg_phase_err_cnt          = 0;
        csc_dbg_cbuf_print_cnt         = 0;
        csc_dbg_wbuf_print_cnt         = 0;
        csc_dbg_phase_print_cnt        = 0;

        csc_dbg_ctx_valid_cur          = 1'b0;
        csc_dbg_phase_pair_valid_cur   = 1'b0;
        csc_dbg_h_cur                  = 0;
        csc_dbg_w_blk_cur              = 0;
        csc_dbg_ci_grp_cur             = 0;
        csc_dbg_co_grp_cur             = 0;
        csc_dbg_kx_cur                 = 0;
        csc_dbg_ky_cur                 = 0;
        csc_dbg_in_row_cur             = 0;
        csc_dbg_in_col_base_cur        = 0;

        csc_dbg_cbuf_expected_dat      = '0;
        csc_dbg_cbuf_actual_dat        = '0;
        csc_dbg_wbuf_expected_dat      = '0;
        csc_dbg_wbuf_actual_dat        = '0;
        csc_dbg_phase0_expected_bus    = '0;
        csc_dbg_phase0_actual_bus      = '0;
        csc_dbg_phase1_expected_bus    = '0;
        csc_dbg_phase1_actual_bus      = '0;
        csc_dbg_phase_merge_expected_bus = '0;
        csc_dbg_phase_merge_actual_bus   = '0;
        csc_dbg_phase0_actual_raw_bus  = '0;
        csc_dbg_phase1_actual_raw_bus  = '0;

        for (idx = 0; idx < 5; idx = idx + 1) begin
            csc_dbg_ctx_vld_pipe[idx] = 1'b0;
            csc_dbg_h_pipe[idx]       = 0;
            csc_dbg_w_blk_pipe[idx]   = 0;
            csc_dbg_ci_grp_pipe[idx]  = 0;
            csc_dbg_co_grp_pipe[idx]  = 0;
            csc_dbg_kx_pipe[idx]      = 0;
            csc_dbg_ky_pipe[idx]      = 0;
        end
    end
endtask

task automatic csc_dbg_enable();
    begin
        csc_dbg_reset();
        csc_dbg_en = 1'b1;
        $display("=== [CSC_DBG] enable cbuf/wbuf/phase checker ===");
    end
endtask

task automatic csc_dbg_disable();
    begin
        $display("=== [CSC_DBG] disable checker: cbuf_err=%0d, wbuf_err=%0d, phase_err=%0d ===",
                 csc_dbg_cbuf_err_cnt, csc_dbg_wbuf_err_cnt, csc_dbg_phase_err_cnt);
        csc_dbg_en = 1'b0;
    end
endtask

task automatic csc_dbg_check_cbuf_stream(
    input integer h_idx,
    input integer w_blk_idx,
    input integer ci_grp_idx,
    input integer kx_idx,
    input integer ky_idx
);
    integer pix_idx;
    integer lane_idx;
    integer in_row_idx;
    integer in_col_idx;
    integer ch_idx;
    logic signed [7:0] exp_val;
    logic signed [7:0] act_val;
    logic mismatch_found;
    logic [8*64-1:0] exp_bus;
    begin
        csc_dbg_build_expected_mac_bus(h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx, exp_bus);
        csc_dbg_cbuf_expected_dat = exp_bus;
        csc_dbg_cbuf_actual_dat   = u_dut.u_accel.mac_features_in;

        if (csc_dbg_cbuf_actual_dat !== csc_dbg_cbuf_expected_dat) begin
            csc_dbg_cbuf_err_cnt = csc_dbg_cbuf_err_cnt + 1;
            mismatch_found = 1'b0;
            in_row_idx = h_idx * Sy + ky_idx - Py;
            if (csc_dbg_cbuf_print_cnt < csc_dbg_max_print) begin
                for (pix_idx = 0; (pix_idx < 8) && !mismatch_found; pix_idx = pix_idx + 1) begin
                    in_col_idx = (w_blk_idx * 8 + pix_idx) * Sx + kx_idx - Px;
                    for (lane_idx = 0; (lane_idx < 8) && !mismatch_found; lane_idx = lane_idx + 1) begin
                        ch_idx  = ci_grp_idx * 8 + lane_idx;
                        exp_val = csc_dbg_cbuf_expected_dat[pix_idx*64 + lane_idx*8 +: 8];
                        act_val = csc_dbg_cbuf_actual_dat[pix_idx*64 + lane_idx*8 +: 8];
                        if (act_val !== exp_val) begin
                            $display("[CSC_CBUF_ERR] H:%0d W_blk:%0d CI_grp:%0d KX:%0d KY:%0d pix:%0d ch:%0d in_row:%0d in_col:%0d exp:%0d act:%0d",
                                     h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx,
                                     pix_idx, ch_idx, in_row_idx, in_col_idx, exp_val, act_val);
                            $display("[CSC_CBUF_ERR] exp_bus=%0128h act_bus=%0128h",
                                     csc_dbg_cbuf_expected_dat, csc_dbg_cbuf_actual_dat);
                            csc_dbg_cbuf_print_cnt = csc_dbg_cbuf_print_cnt + 1;
                            mismatch_found = 1'b1;
                        end
                    end
                end
            end
        end
    end
endtask

// stride=2 场景下，额外核对 phase0/phase1 两拍的原始读数与最终拼接结果。
task automatic csc_dbg_check_stride2_phase_pair(
    input integer h_idx,
    input integer w_blk_idx,
    input integer ci_grp_idx,
    input integer kx_idx,
    input integer ky_idx
);
    integer pix_idx;
    integer lane_idx;
    integer in_row_idx;
    integer phase0_col_idx;
    integer phase1_col_idx;
    integer ch_idx;
    logic signed [7:0] exp_val;
    logic signed [7:0] act_val;
    logic mismatch_found;
    begin
        csc_dbg_phase_pair_valid_cur = 1'b1;

        csc_dbg_build_expected_stride2_phase_bus(
            h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx,
            csc_dbg_phase0_expected_bus,
            csc_dbg_phase1_expected_bus
        );
        csc_dbg_build_expected_mac_bus(
            h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx,
            csc_dbg_phase_merge_expected_bus
        );

        csc_dbg_phase0_actual_raw_bus  = u_dut.u_accel.u_csc.saved_cbuf_dat;
        csc_dbg_phase1_actual_raw_bus  = u_dut.u_accel.cbuf_rd_dat_out;
        csc_dbg_mask_phase_bus(
            u_dut.u_accel.u_csc.saved_cbuf_dat,
            u_dut.u_accel.u_csc.saved_in_p_mask,
            csc_dbg_phase0_actual_bus
        );
        csc_dbg_mask_phase_bus(
            u_dut.u_accel.cbuf_rd_dat_out,
            u_dut.u_accel.u_csc.in_p_mask_d5,
            csc_dbg_phase1_actual_bus
        );
        csc_dbg_phase_merge_actual_bus = u_dut.u_accel.mac_features_in;

        mismatch_found = 1'b0;
        in_row_idx = h_idx * Sy + ky_idx - Py;

        if (csc_dbg_phase0_actual_bus !== csc_dbg_phase0_expected_bus) begin
            csc_dbg_phase_err_cnt = csc_dbg_phase_err_cnt + 1;
            if (csc_dbg_phase_print_cnt < csc_dbg_max_print) begin
                for (pix_idx = 0; (pix_idx < 8) && !mismatch_found; pix_idx = pix_idx + 1) begin
                    phase0_col_idx = w_blk_idx * 8 * Sx + kx_idx - Px + pix_idx;
                    for (lane_idx = 0; (lane_idx < 8) && !mismatch_found; lane_idx = lane_idx + 1) begin
                        ch_idx  = ci_grp_idx * 8 + lane_idx;
                        exp_val = csc_dbg_phase0_expected_bus[pix_idx*64 + lane_idx*8 +: 8];
                        act_val = csc_dbg_phase0_actual_bus[pix_idx*64 + lane_idx*8 +: 8];
                        if (act_val !== exp_val) begin
                            $display("[CSC_PHASE0_ERR] H:%0d W_blk:%0d CI_grp:%0d KX:%0d KY:%0d lane:%0d ch:%0d in_row:%0d in_col:%0d exp:%0d act:%0d",
                                     h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx,
                                     pix_idx, ch_idx, in_row_idx, phase0_col_idx, exp_val, act_val);
                            $display("[CSC_PHASE0_ERR] exp_bus=%0128h act_bus=%0128h raw_bus=%0128h mask=%02h",
                                     csc_dbg_phase0_expected_bus, csc_dbg_phase0_actual_bus,
                                     csc_dbg_phase0_actual_raw_bus, u_dut.u_accel.u_csc.saved_in_p_mask);
                            csc_dbg_phase_print_cnt = csc_dbg_phase_print_cnt + 1;
                            mismatch_found = 1'b1;
                        end
                    end
                end
            end
        end

        mismatch_found = 1'b0;
        if (csc_dbg_phase1_actual_bus !== csc_dbg_phase1_expected_bus) begin
            csc_dbg_phase_err_cnt = csc_dbg_phase_err_cnt + 1;
            if (csc_dbg_phase_print_cnt < csc_dbg_max_print) begin
                for (pix_idx = 0; (pix_idx < 8) && !mismatch_found; pix_idx = pix_idx + 1) begin
                    phase1_col_idx = w_blk_idx * 8 * Sx + kx_idx - Px + 8 + pix_idx;
                    for (lane_idx = 0; (lane_idx < 8) && !mismatch_found; lane_idx = lane_idx + 1) begin
                        ch_idx  = ci_grp_idx * 8 + lane_idx;
                        exp_val = csc_dbg_phase1_expected_bus[pix_idx*64 + lane_idx*8 +: 8];
                        act_val = csc_dbg_phase1_actual_bus[pix_idx*64 + lane_idx*8 +: 8];
                        if (act_val !== exp_val) begin
                            $display("[CSC_PHASE1_ERR] H:%0d W_blk:%0d CI_grp:%0d KX:%0d KY:%0d lane:%0d ch:%0d in_row:%0d in_col:%0d exp:%0d act:%0d",
                                     h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx,
                                     pix_idx, ch_idx, in_row_idx, phase1_col_idx, exp_val, act_val);
                            $display("[CSC_PHASE1_ERR] exp_bus=%0128h act_bus=%0128h raw_bus=%0128h mask=%02h",
                                     csc_dbg_phase1_expected_bus, csc_dbg_phase1_actual_bus,
                                     csc_dbg_phase1_actual_raw_bus, u_dut.u_accel.u_csc.in_p_mask_d5);
                            csc_dbg_phase_print_cnt = csc_dbg_phase_print_cnt + 1;
                            mismatch_found = 1'b1;
                        end
                    end
                end
            end
        end

        if (csc_dbg_phase_merge_actual_bus !== csc_dbg_phase_merge_expected_bus) begin
            csc_dbg_phase_err_cnt = csc_dbg_phase_err_cnt + 1;
            if (csc_dbg_phase_print_cnt < csc_dbg_max_print) begin
                $display("[CSC_PHASE_MERGE_ERR] H:%0d W_blk:%0d CI_grp:%0d KX:%0d KY:%0d",
                         h_idx, w_blk_idx, ci_grp_idx, kx_idx, ky_idx);
                $display("[CSC_PHASE_MERGE_ERR] phase0_exp=%0128h", csc_dbg_phase0_expected_bus);
                $display("[CSC_PHASE_MERGE_ERR] phase0_act=%0128h", csc_dbg_phase0_actual_bus);
                $display("[CSC_PHASE_MERGE_ERR] phase0_raw=%0128h mask=%02h",
                         csc_dbg_phase0_actual_raw_bus, u_dut.u_accel.u_csc.saved_in_p_mask);
                $display("[CSC_PHASE_MERGE_ERR] phase1_exp=%0128h", csc_dbg_phase1_expected_bus);
                $display("[CSC_PHASE_MERGE_ERR] phase1_act=%0128h", csc_dbg_phase1_actual_bus);
                $display("[CSC_PHASE_MERGE_ERR] phase1_raw=%0128h mask=%02h",
                         csc_dbg_phase1_actual_raw_bus, u_dut.u_accel.u_csc.in_p_mask_d5);
                $display("[CSC_PHASE_MERGE_ERR] merge_exp =%0128h", csc_dbg_phase_merge_expected_bus);
                $display("[CSC_PHASE_MERGE_ERR] merge_act =%0128h", csc_dbg_phase_merge_actual_bus);
                csc_dbg_phase_print_cnt = csc_dbg_phase_print_cnt + 1;
            end
        end
    end
endtask

task automatic csc_dbg_check_wbuf_stream(
    input integer h_idx,
    input integer w_blk_idx,
    input integer ci_grp_idx,
    input integer co_grp_idx,
    input integer kx_idx,
    input integer ky_idx
);
    integer bank_idx;
    integer lane_idx;
    integer oc0_idx;
    integer oc1_idx;
    integer ic_idx;
    logic signed [7:0] exp_val;
    logic signed [7:0] act_val;
    logic mismatch_found;
    begin
        csc_dbg_wbuf_expected_dat = '0;
        csc_dbg_wbuf_actual_dat   = u_dut.u_accel.wbuf_rd_dat_out;

        for (bank_idx = 0; bank_idx < 8; bank_idx = bank_idx + 1) begin
            oc0_idx = co_grp_idx * 16 + bank_idx * 2;
            oc1_idx = oc0_idx + 1;
            for (lane_idx = 0; lane_idx < 8; lane_idx = lane_idx + 1) begin
                ic_idx = ci_grp_idx * 8 + lane_idx;
                csc_dbg_wbuf_expected_dat[bank_idx*128 + lane_idx*8 +: 8] =
                    csc_dbg_get_wt_value(oc0_idx, ic_idx, ky_idx, kx_idx);
                csc_dbg_wbuf_expected_dat[bank_idx*128 + 64 + lane_idx*8 +: 8] =
                    csc_dbg_get_wt_value(oc1_idx, ic_idx, ky_idx, kx_idx);
            end
        end

        if (csc_dbg_wbuf_actual_dat !== csc_dbg_wbuf_expected_dat) begin
            csc_dbg_wbuf_err_cnt = csc_dbg_wbuf_err_cnt + 1;
            mismatch_found = 1'b0;
            if (csc_dbg_wbuf_print_cnt < csc_dbg_max_print) begin
                for (bank_idx = 0; (bank_idx < 8) && !mismatch_found; bank_idx = bank_idx + 1) begin
                    oc0_idx = co_grp_idx * 16 + bank_idx * 2;
                    oc1_idx = oc0_idx + 1;
                    for (lane_idx = 0; (lane_idx < 8) && !mismatch_found; lane_idx = lane_idx + 1) begin
                        ic_idx = ci_grp_idx * 8 + lane_idx;

                        exp_val = csc_dbg_wbuf_expected_dat[bank_idx*128 + lane_idx*8 +: 8];
                        act_val = csc_dbg_wbuf_actual_dat[bank_idx*128 + lane_idx*8 +: 8];
                        if (act_val !== exp_val) begin
                            $display("[CSC_WBUF_ERR] H:%0d W_blk:%0d CI_grp:%0d CO_grp:%0d KX:%0d KY:%0d bank:%0d oc:%0d ic:%0d exp:%0d act:%0d",
                                     h_idx, w_blk_idx, ci_grp_idx, co_grp_idx, kx_idx, ky_idx,
                                     bank_idx, oc0_idx, ic_idx, exp_val, act_val);
                            $display("[CSC_WBUF_ERR] exp_bank=%032h act_bank=%032h",
                                     csc_dbg_wbuf_expected_dat[bank_idx*128 +: 128],
                                     csc_dbg_wbuf_actual_dat[bank_idx*128 +: 128]);
                            csc_dbg_wbuf_print_cnt = csc_dbg_wbuf_print_cnt + 1;
                            mismatch_found = 1'b1;
                        end

                        exp_val = csc_dbg_wbuf_expected_dat[bank_idx*128 + 64 + lane_idx*8 +: 8];
                        act_val = csc_dbg_wbuf_actual_dat[bank_idx*128 + 64 + lane_idx*8 +: 8];
                        if (act_val !== exp_val) begin
                            $display("[CSC_WBUF_ERR] H:%0d W_blk:%0d CI_grp:%0d CO_grp:%0d KX:%0d KY:%0d bank:%0d oc:%0d ic:%0d exp:%0d act:%0d",
                                     h_idx, w_blk_idx, ci_grp_idx, co_grp_idx, kx_idx, ky_idx,
                                     bank_idx, oc1_idx, ic_idx, exp_val, act_val);
                            $display("[CSC_WBUF_ERR] exp_bank=%032h act_bank=%032h",
                                     csc_dbg_wbuf_expected_dat[bank_idx*128 +: 128],
                                     csc_dbg_wbuf_actual_dat[bank_idx*128 +: 128]);
                            csc_dbg_wbuf_print_cnt = csc_dbg_wbuf_print_cnt + 1;
                            mismatch_found = 1'b1;
                        end
                    end
                end
            end
        end
    end
endtask

always @(posedge clk or negedge rst_n) begin : CSC_DEBUG_MONITOR
    integer pipe_idx;
    if (!rst_n) begin
        csc_dbg_reset();
    end else if (csc_dbg_en) begin
        for (pipe_idx = 4; pipe_idx > 0; pipe_idx = pipe_idx - 1) begin
            csc_dbg_ctx_vld_pipe[pipe_idx] <= csc_dbg_ctx_vld_pipe[pipe_idx-1];
            csc_dbg_h_pipe[pipe_idx]       <= csc_dbg_h_pipe[pipe_idx-1];
            csc_dbg_w_blk_pipe[pipe_idx]   <= csc_dbg_w_blk_pipe[pipe_idx-1];
            csc_dbg_ci_grp_pipe[pipe_idx]  <= csc_dbg_ci_grp_pipe[pipe_idx-1];
            csc_dbg_co_grp_pipe[pipe_idx]  <= csc_dbg_co_grp_pipe[pipe_idx-1];
            csc_dbg_kx_pipe[pipe_idx]      <= csc_dbg_kx_pipe[pipe_idx-1];
            csc_dbg_ky_pipe[pipe_idx]      <= csc_dbg_ky_pipe[pipe_idx-1];
        end

        csc_dbg_ctx_vld_pipe[0] <= u_dut.u_accel.u_csc.step_en;
        csc_dbg_h_pipe[0]       <= u_dut.u_accel.u_csc.h_out;
        csc_dbg_w_blk_pipe[0]   <= u_dut.u_accel.u_csc.w_out_blk;
        csc_dbg_ci_grp_pipe[0]  <= u_dut.u_accel.u_csc.ci_grp;
        csc_dbg_co_grp_pipe[0]  <= u_dut.u_accel.u_csc.co_grp;
        csc_dbg_kx_pipe[0]      <= u_dut.u_accel.u_csc.kx;
        csc_dbg_ky_pipe[0]      <= u_dut.u_accel.u_csc.ky;

        if (u_dut.u_accel.csc_mac_valid && csc_dbg_ctx_vld_pipe[4]) begin
            csc_dbg_ctx_valid_cur   <= 1'b1;
            csc_dbg_h_cur           <= csc_dbg_h_pipe[4];
            csc_dbg_w_blk_cur       <= csc_dbg_w_blk_pipe[4];
            csc_dbg_ci_grp_cur      <= csc_dbg_ci_grp_pipe[4];
            csc_dbg_co_grp_cur      <= csc_dbg_co_grp_pipe[4];
            csc_dbg_kx_cur          <= csc_dbg_kx_pipe[4];
            csc_dbg_ky_cur          <= csc_dbg_ky_pipe[4];
            csc_dbg_in_row_cur      <= csc_dbg_h_pipe[4] * Sy + csc_dbg_ky_pipe[4] - Py;
            csc_dbg_in_col_base_cur <= csc_dbg_w_blk_pipe[4] * 8 * Sx + csc_dbg_kx_pipe[4] - Px;

            csc_dbg_check_cbuf_stream(
                csc_dbg_h_pipe[4],
                csc_dbg_w_blk_pipe[4],
                csc_dbg_ci_grp_pipe[4],
                csc_dbg_kx_pipe[4],
                csc_dbg_ky_pipe[4]
            );

            if (u_dut.u_accel.u_csc.is_stride2_d5) begin
                csc_dbg_check_stride2_phase_pair(
                    csc_dbg_h_pipe[4],
                    csc_dbg_w_blk_pipe[4],
                    csc_dbg_ci_grp_pipe[4],
                    csc_dbg_kx_pipe[4],
                    csc_dbg_ky_pipe[4]
                );
            end else begin
                csc_dbg_phase_pair_valid_cur <= 1'b0;
            end

            csc_dbg_check_wbuf_stream(
                csc_dbg_h_pipe[4],
                csc_dbg_w_blk_pipe[4],
                csc_dbg_ci_grp_pipe[4],
                csc_dbg_co_grp_pipe[4],
                csc_dbg_kx_pipe[4],
                csc_dbg_ky_pipe[4]
            );
        end else begin
            csc_dbg_ctx_valid_cur        <= 1'b0;
            csc_dbg_phase_pair_valid_cur <= 1'b0;
        end
    end
end

`endif
