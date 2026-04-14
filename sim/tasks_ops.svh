`ifndef TB_TASKS_OPS_SVH
`define TB_TASKS_OPS_SVH

// ============================================================================
// 算子级验证任务库
// 包含池化、上采样、concat、残差和卷积的参考模型、配置任务与回归入口。
// ============================================================================
localparam [1:0] TB_OP_CONV   = 2'd0;
localparam [1:0] TB_OP_POOL   = 2'd1;
localparam [1:0] TB_OP_RESADD = 2'd2;


// 向上取整除法，供拍数和分组计算复用。
function automatic int ceil_div_int(input int value, input int factor);
    ceil_div_int = (value + factor - 1) / factor;
endfunction



// 估算特征图在 DDR 中占用的字节数。
function automatic int calc_feature_bytes(input int width, input int height, input int channels);
    calc_feature_bytes = height * ceil_div_int(channels, 8) * ceil_div_int(width, 2) * 16;
endfunction


// 计算最后一个输出通道组真正需要启用的 bank 数。
function automatic int calc_active_banks(input int out_channels);
    int rem_cout;
    begin
        rem_cout = out_channels % 16;
        calc_active_banks = (rem_cout == 0) ? 8 : ceil_div_int(rem_cout, 2);
    end
endfunction


// resident 模式判定：当前软件侧已经保证每个 region 足够容纳 Kx*Ky*ch_in_grp。
// 因此只要 16 通道输出组总数不超过 4，就可以整层常驻在 WBUF 中。
function automatic int calc_wt_resident_en(input int out_channels);
    int co_groups_x16;
    begin
        co_groups_x16 = ceil_div_int(out_channels, 16);
        calc_wt_resident_en = (co_groups_x16 <= 4) ? 1 : 0;
    end
endfunction



// 依据硬件打包格式估算权重总拍数。
function automatic int calc_wt_total_beats(
    input int in_ch_groups,
    input int out_channels,
    input int kx,
    input int ky
);
    int co_groups_x16;
    int coords_per_region;
    int active_banks;
    begin
        co_groups_x16     = ceil_div_int(out_channels, 16);
        coords_per_region = in_ch_groups * kx * ky;
        active_banks      = calc_active_banks(out_channels);

        if (co_groups_x16 > 1) begin
            calc_wt_total_beats = (co_groups_x16 - 1) * coords_per_region * 8
                                + coords_per_region * active_banks;
        end else begin
            calc_wt_total_beats = coords_per_region * active_banks;
        end
    end
endfunction


// 统一 8bit 饱和裁剪函数。
function automatic logic signed [7:0] sat_s8(input integer value);
    begin
        if (value > 127) begin
            sat_s8 = 8'sd127;
        end else if (value < -128) begin
            sat_s8 = -8'sd128;
        end else begin
            sat_s8 = value[7:0];
        end
    end
endfunction



// 生成可重复的输入模式，便于调试和复现问题。
function automatic logic signed [7:0] gen_pattern_value(
    input int pattern_id,
    input int h,
    input int w,
    input int c
);
    int tmp;
    begin
        case (pattern_id)
            0: tmp = ((h * 17 + w * 11 + c * 5) % 95)  - 47;
            1: tmp = ((h * 9  + w * 21 + c * 7) % 111) - 55;
            2: tmp = ((h * 29 + w * 13 + c * 19) % 221) - 110;
            3: tmp = ((h * 23 + w * 15 + c * 27) % 241) - 120;
            4: tmp = ((h * 5  + w * 3  + c * 2) % 7)   - 3;
            default: tmp = ((h * 31 + w * 7 + c * 3) % 127) - 63;
        endcase
        gen_pattern_value = sat_s8(tmp);
    end
endfunction


// 生成卷积测试使用的小幅度权重。
function automatic logic signed [7:0] gen_conv_weight_value(
    input int oc,
    input int ic,
    input int ky,
    input int kx
);
    int tmp;
    begin
        tmp = ((oc * 3 + ic * 5 + ky * 2 + kx) % 3) - 1;
        gen_conv_weight_value = sat_s8(tmp);
    end
endfunction


// 生成卷积测试使用的 bias。
function automatic integer gen_conv_bias_value(input int oc);
    begin
        gen_conv_bias_value = ((oc * 5) % 9) - 4;
    end
endfunction

// ============================================================================
// DDR 与寄存器辅助任务
// ============================================================================

// 向 AXI 从内存写入一个 128bit beat。
task automatic tb_write_mem128(input logic [31:0] base_addr, input logic [127:0] data);
    begin
        u_AXI_HP_Slave.memory[base_addr[31:2] + 0] = data[31:0];
        u_AXI_HP_Slave.memory[base_addr[31:2] + 1] = data[63:32];
        u_AXI_HP_Slave.memory[base_addr[31:2] + 2] = data[95:64];
        u_AXI_HP_Slave.memory[base_addr[31:2] + 3] = data[127:96];
    end
endtask

// 向 AXI 从内存写入一个 64bit 数据块，主要用于 bias/scale/shift。
task automatic tb_write_mem64(input logic [31:0] base_addr, input logic [63:0] data);
    begin
        u_AXI_HP_Slave.memory[base_addr[31:2] + 0] = data[31:0];
        u_AXI_HP_Slave.memory[base_addr[31:2] + 1] = data[63:32];
    end
endtask

// 清空一段 DDR 地址范围。
task automatic clear_mem_region(input logic [31:0] base_addr, input int byte_num);
    int word_num;
    int i;
    begin
        if (byte_num > 0) begin
            word_num = ceil_div_int(byte_num, 4);
            for (i = 0; i < word_num; i = i + 1) begin
                u_AXI_HP_Slave.memory[base_addr[31:2] + i] = 32'd0;
            end
        end
    end
endtask

// 清空紧凑版寄存器空间，避免不同测试相互污染。
task automatic clear_compact_regs();
    int addr;
    begin
        for (addr = 'h10; addr <= 'h60; addr = addr + 4) begin
            cfg_write(addr[7:0], 32'd0);
        end
    end
endtask

// 复位测试环境，并等待 DUT 稳定。
task automatic reset_case_env();
    begin
        cfg_req   <= 1'b0;
        cfg_addr  <= 8'd0;
        cfg_wdata <= 32'd0;

        rst_n <= 1'b0;
        repeat (6) @(negedge clk);
        rst_n <= 1'b1;
        repeat (8) @(negedge clk);
    end
endtask

// 等待当前测试用例执行结束。
task automatic wait_case_done(input string case_name);
    begin
        $display("=== [%s] wait ap_done ===", case_name);
        wait (ap_done == 1'b1);
        $display("=== [%s] ap_done at %0t ===", case_name, $time);
        repeat (50) @(negedge clk);
    end
endtask


// 生成输入特征图，并同时写入软件参考数组与 AXI 内存。
task automatic write_feature_tensor(
    input string       tag,
    input logic [31:0] base_addr,
    input int          width,
    input int          height,
    input int          channels,
    input int          tensor_sel,
    input int          pattern_id
);
    int h, cg, wg, p, c;
    int current_w;
    int current_c;
    int w_groups;
    int c_groups;
    logic [31:0]       addr_offset;
    logic [127:0]      packed_data;
    logic signed [7:0] pix_val;
    begin
        w_groups    = ceil_div_int(width, 2);
        c_groups    = ceil_div_int(channels, 8);
        addr_offset = base_addr;

        $display("=== [%s] build feature tensor %0dx%0dx%0d at 0x%08h ===",
                tag, height, width, channels, base_addr);

        for (h = 0; h < height; h = h + 1) begin
            for (cg = 0; cg < c_groups; cg = cg + 1) begin
                for (wg = 0; wg < w_groups; wg = wg + 1) begin
                    packed_data = 128'd0;
                    for (p = 0; p < 2; p = p + 1) begin
                        current_w = wg * 2 + p;
                        if (current_w < width) begin
                            for (c = 0; c < 8; c = c + 1) begin
                                current_c = cg * 8 + c;
                                if (current_c < channels) begin
                                    pix_val = gen_pattern_value(pattern_id, h, current_w, current_c);
                                    if (tensor_sel == 0) begin
                                        ref_ifm[h][current_w][current_c] = pix_val;
                                    end else begin
                                        ref_ifm_aux[h][current_w][current_c] = pix_val;
                                    end
                                    // DDR 中 1 个 128bit beat 打包 2 个空间位置，
                                    // 每个空间位置占 64bit，对应 8 个通道的 8bit 数据。
                                    packed_data[p*64 + c*8 +: 8] = pix_val;
                                end
                            end
                        end
                    end
                    tb_write_mem128(addr_offset, packed_data);
                    if ((h == 0) && (cg == 0) && (wg < 2)) begin
                        $display("[%s][DBG] beat[%0d] = %032h", tag, wg, packed_data);
                    end
                    addr_offset = addr_offset + 32'd16;
                end
            end
        end
    end
endtask

// 构造 1x1 identity conv，便于复用卷积路径验证搬运逻辑。
task automatic build_identity_conv_bundle(
    input string       tag,
    input logic [31:0] wt_base,
    input logic [31:0] bias_base,
    input int          in_channels,
    input int          out_channels
);
    int oc;
    int i;
    int ci_grp;
    int co_grp;
    int oc_pair;
    int oc_pad;
    int ic_pad;
    int co_grp_end;
    logic [31:0]  addr_offset;
    logic [127:0] line_data128;
    logic [63:0]  line_data64;
    begin
        clear_mem_region(wt_base, calc_wt_total_beats(ceil_div_int(in_channels, 8), out_channels, 1, 1) * 16);
        clear_mem_region(bias_base, ceil_div_int(out_channels, 2) * 16);

        for (oc = 0; oc < out_channels; oc = oc + 1) begin
            ref_bias[oc]  = 64'sd0;
            ref_scale[oc] = 18'sd1;
            ref_shift[oc] = 8'd0;
            line_data64   = {8'd0, 18'd1, 38'd0};
            tb_write_mem64(bias_base + oc * 8, line_data64);
        end
        if (out_channels[0]) begin
            tb_write_mem64(bias_base + out_channels * 8, 64'd0);
        end

        oc_pad      = out_channels[0] ? (out_channels + 1) : out_channels;
        ic_pad      = ceil_div_int(in_channels, 8) * 8;
        addr_offset = wt_base;


            co_grp_end = (co_grp + 16 > oc_pad) ? oc_pad : (co_grp + 16);
            for (ci_grp = 0; ci_grp < ic_pad; ci_grp = ci_grp + 8) begin
                for (oc_pair = co_grp; oc_pair < co_grp_end; oc_pair = oc_pair + 2) begin
                    line_data128 = 128'd0;
                    for (i = 0; i < 8; i = i + 1) begin
                        if (((ci_grp + i) < in_channels) &&
                            (oc_pair < out_channels) &&
                            (oc_pair == (ci_grp + i))) begin
                            line_data128[i*8 +: 8] = 8'sd1;
                        end
                        if (((ci_grp + i) < in_channels) &&
                            ((oc_pair + 1) < out_channels) &&
                            ((oc_pair + 1) == (ci_grp + i))) begin
                            line_data128[64 + i*8 +: 8] = 8'sd1;
                        end
                    end
                    tb_write_mem128(addr_offset, line_data128);
                    if (((addr_offset - wt_base) >> 4) < 4) begin
                        $display("[%s][DBG] weight_beat[%0d] = %032h",
                                tag, ((addr_offset - wt_base) >> 4), line_data128);
                    end
                    addr_offset = addr_offset + 32'd16;
                end
            end
    end

endtask

// 构造带固定模式的卷积权重和 bias，供卷积本体验证。
task automatic build_pattern_conv_bundle(
    input string       tag,
    input logic [31:0] wt_base,
    input logic [31:0] bias_base,
    input int          in_channels,
    input int          out_channels,
    input int          kx,
    input int          ky
);
    int oc;
    int i;
    int ci_grp;
    int co_grp;
    int oc_pair;
    int oc_pad;
    int ic_pad;
    int co_grp_end;
    int ky_idx;
    int kx_idx;
    integer bias_val;
    logic signed [37:0] bias_pack;
    logic [31:0]  addr_offset;
    logic [127:0] line_data128;
    logic [63:0]  line_data64;
    logic signed [7:0] wt_val_a;
    logic signed [7:0] wt_val_b;
    
    begin
        clear_mem_region(wt_base, calc_wt_total_beats(ceil_div_int(in_channels, 8), out_channels, kx, ky) * 16);
        clear_mem_region(bias_base, ceil_div_int(out_channels, 2) * 16);

        for (oc = 0; oc < out_channels; oc = oc + 1) begin
            bias_val      = gen_conv_bias_value(oc);
            bias_pack     = bias_val;
            ref_bias[oc]  = bias_val;
            ref_scale[oc] = 18'sd1;
            ref_shift[oc] = 8'd0;
            line_data64   = {8'd0, 18'd1, bias_pack[37:0]};
            tb_write_mem64(bias_base + oc * 8, line_data64);
        end
        if (out_channels[0]) begin
            tb_write_mem64(bias_base + out_channels * 8, 64'd0);
        end

        oc_pad      = out_channels[0] ? (out_channels + 1) : out_channels;
        ic_pad      = ceil_div_int(in_channels, 8) * 8;
        addr_offset = wt_base;

        // 【修复点】：补充缺失的 co_grp 外层循环
        for (co_grp = 0; co_grp < oc_pad; co_grp = co_grp + 16) begin
            co_grp_end = (co_grp + 16 > oc_pad) ? oc_pad : (co_grp + 16);
            
            for (ci_grp = 0; ci_grp < ic_pad; ci_grp = ci_grp + 8) begin
                for (ky_idx = 0; ky_idx < ky; ky_idx = ky_idx + 1) begin
                    for (kx_idx = 0; kx_idx < kx; kx_idx = kx_idx + 1) begin
                        for (oc_pair = co_grp; oc_pair < co_grp_end; oc_pair = oc_pair + 2) begin
                            line_data128 = 128'd0;
                            for (i = 0; i < 8; i = i + 1) begin
                                if ((ci_grp + i) < in_channels) begin
                                    if (oc_pair < out_channels) begin
                                        wt_val_a = gen_conv_weight_value(oc_pair, ci_grp + i, ky_idx, kx_idx);
                                        ref_wt[oc_pair][ci_grp + i][ky_idx][kx_idx] = wt_val_a;
                                        line_data128[i*8 +: 8] = wt_val_a;
                                    end
                                    if ((oc_pair + 1) < out_channels) begin
                                        wt_val_b = gen_conv_weight_value(oc_pair + 1, ci_grp + i, ky_idx, kx_idx);
                                        ref_wt[oc_pair + 1][ci_grp + i][ky_idx][kx_idx] = wt_val_b;
                                        line_data128[64 + i*8 +: 8] = wt_val_b;
                                    end
                                end
                            end
                            tb_write_mem128(addr_offset, line_data128);
                            if (((addr_offset - wt_base) >> 4) < 4) begin
                                $display("[%s][DBG] conv_weight_beat[%0d] = %032h",
                                        tag, ((addr_offset - wt_base) >> 4), line_data128);
                            end
                            addr_offset = addr_offset + 32'd16;
                        end
                    end
                end
            end
        end // 【修复点】：结束 co_grp 循环
    end
endtask

// 配置池化寄存器并启动。
task automatic program_pool_cfg(
    input logic [31:0] f_base,
    input logic [31:0] o_base,
    input int          width,
    input int          height,
    input int          channels,
    input bit          pad_zero
);
    int ch_groups;
    begin
        ch_groups = ceil_div_int(channels, 8);
        clear_compact_regs();
        cfg_write(8'h10, f_base);
        cfg_write(8'h1C, o_base);
        cfg_write(8'h24, {width[15:0], height[15:0]});
        cfg_write(8'h28, {width[15:0], height[15:0]});
        cfg_write(8'h2C, {ch_groups[15:0], channels[15:0]});
        cfg_write(8'h44, ((pad_zero ? 1 : 0) << 2) | TB_OP_POOL);
        cfg_write(8'h60, 32'd0);
        cfg_write(8'h00, 32'h0000_0001);
    end
endtask

// 配置残差加寄存器并启动。
task automatic program_resadd_cfg(
    input logic [31:0] f_base,
    input logic [31:0] r_base,
    input logic [31:0] o_base,
    input int          width,
    input int          height,
    input int          channels,
    input bit          relu_en
);
    int ch_groups;
    begin
        ch_groups = ceil_div_int(channels, 8);
        clear_compact_regs();
        cfg_write(8'h10, f_base);
        cfg_write(8'h1C, o_base);
        cfg_write(8'h20, r_base);
        cfg_write(8'h24, {width[15:0], height[15:0]});
        cfg_write(8'h28, {width[15:0], height[15:0]});
        cfg_write(8'h2C, {ch_groups[15:0], channels[15:0]});
        cfg_write(8'h44, ((relu_en ? 1 : 0) << 3) | TB_OP_RESADD);
        cfg_write(8'h60, 32'd0);
        cfg_write(8'h00, 32'h0000_0001);
    end
endtask

// 配置卷积路径寄存器并启动。
// 同时兼容 concat 与 src0 上采样装载模式。
task automatic program_conv_cfg(
    input logic [31:0] f_base,
    input logic [31:0] wt_base,
    input logic [31:0] b_base,
    input logic [31:0] o_base,
    input int          in_width,
    input int          in_height,
    input int          in_channels,
    input int          out_width,
    input int          out_height,
    input int          out_channels,
    input int          kx,
    input int          ky,
    input int          sx,
    input int          sy,
    input int          px,
    input int          py,
    input bit          relu_en,
    input bit          cat_en,
    input bit          src0_upsample,
    input logic [31:0] src1_base,
    input int          src0_ch_groups
);
    int in_ch_groups;
    int coords_per_region;
    int active_banks;
    int is_odd_oc;
    int wt_total_beats;
    int b_total_beats;
    int wt_resident_en;
    begin
        in_ch_groups      = ceil_div_int(in_channels, 8);
        coords_per_region = in_ch_groups * kx * ky;
        active_banks      = calc_active_banks(out_channels);
        is_odd_oc         = out_channels[0];
        wt_total_beats    = calc_wt_total_beats(in_ch_groups, out_channels, kx, ky);
        b_total_beats     = ceil_div_int(out_channels, 2);
        wt_resident_en    = (TB_AUTO_WT_RESIDENT_EN != 0) ? calc_wt_resident_en(out_channels) : 0;

        clear_compact_regs();
        cfg_write(8'h10, f_base);
        cfg_write(8'h14, wt_base);
        cfg_write(8'h18, b_base);
        cfg_write(8'h1C, o_base);
        cfg_write(8'h24, {in_width[15:0], in_height[15:0]});
        cfg_write(8'h28, {out_width[15:0], out_height[15:0]});
        cfg_write(8'h2C, {in_ch_groups[15:0], out_channels[15:0]});
        cfg_write(8'h30, {py[3:0], px[3:0], ky[3:0], kx[3:0]});
        cfg_write(8'h34, {sy[3:0], sx[3:0], active_banks[3:0], is_odd_oc[0]});
        cfg_write(8'h38, coords_per_region[15:0]);
        cfg_write(8'h3C, wt_total_beats);
        cfg_write(8'h40, ((relu_en ? 1 : 0) << 16) | b_total_beats);
        cfg_write(8'h44, TB_OP_CONV);
        cfg_write(8'h48, src1_base);
        // 0x4C = {src0_upsample, cat_en, src0_ch_groups}
        cfg_write(8'h4C, ((src0_upsample ? 1 : 0) << 17) |
                         ((cat_en ? 1 : 0) << 16) |
                         src0_ch_groups[15:0]);

        cfg_write(8'h54, 32'd0);
        cfg_write(8'h58, 32'd0);
        cfg_write(8'h5C, 32'd0);
        cfg_write(8'h60, wt_resident_en);
        cfg_write(8'h00, 32'h0000_0001);
    end
endtask

// ============================================================================
// 软件参考模型
// 这些任务在 testbench 侧计算参考结果，用于和硬件写回结果逐点对比。
// ============================================================================

// 软件池化参考模型。
task automatic simulate_pool_reference(
    input int width,
    input int height,
    input int channels,
    input bit pad_zero
);
    int h, w, c, ky, kx;
    int ih, iw;
    int max_val;
    int cur_val;
    begin
        $display("=== [POOL_REF] build software reference ===");
        for (h = 0; h < height; h = h + 1) begin
            for (w = 0; w < width; w = w + 1) begin
                for (c = 0; c < channels; c = c + 1) begin
                    max_val = pad_zero ? 0 : -128;
                    for (ky = 0; ky < 5; ky = ky + 1) begin
                        for (kx = 0; kx < 5; kx = kx + 1) begin
                            ih = h + ky - 2;
                            iw = w + kx - 2;
                            if ((ih >= 0) && (ih < height) && (iw >= 0) && (iw < width)) begin
                                cur_val = ref_ifm[ih][iw][c];
                            end else begin
                                cur_val = pad_zero ? 0 : -128;
                            end
                            if (cur_val > max_val) begin
                                max_val = cur_val;
                            end
                        end
                    end
                    ref_ofm[h][w][c] = sat_s8(max_val);
                end
            end
        end
        $display("[POOL_REF][DBG] ref_ofm[0][0][0] = %0d", ref_ofm[0][0][0]);
    end
endtask
// 软件上采样参考模型，采用 nearest x2。
task automatic simulate_upsample_reference(
    input int src_width,
    input int src_height,
    input int channels,
    input int dst_width,
    input int dst_height
);
    int h, w, c;
    begin
        $display("=== [UPSAMPLE_REF] build software reference ===");
        for (h = 0; h < dst_height; h = h + 1) begin
            for (w = 0; w < dst_width; w = w + 1) begin
                for (c = 0; c < channels; c = c + 1) begin
                    ref_ofm[h][w][c] = ref_ifm[h >> 1][w >> 1][c];
                end
            end
        end
        $display("[UPSAMPLE_REF][DBG] ref_ofm[1][1][0] = %0d", ref_ofm[1][1][0]);
    end
endtask
// 软件 concat 参考模型，按通道维拼接两路输入。
task automatic simulate_concat_reference(
    input int width,
    input int height,
    input int src0_channels,
    input int src1_channels
);
    int h, w, c;
    begin
        $display("=== [CONCAT_REF] build software reference ===");
        for (h = 0; h < height; h = h + 1) begin
            for (w = 0; w < width; w = w + 1) begin
                for (c = 0; c < src0_channels; c = c + 1) begin
                    ref_ofm[h][w][c] = ref_ifm[h][w][c];
                end
                for (c = 0; c < src1_channels; c = c + 1) begin
                    ref_ofm[h][w][src0_channels + c] = ref_ifm_aux[h][w][c];
                end
            end
        end
        $display("[CONCAT_REF][DBG] ref_ofm[0][0][0] = %0d, ref_ofm[0][0][8] = %0d",
                 ref_ofm[0][0][0], ref_ofm[0][0][8]);
    end
endtask
// 软件 upsample + concat 联合参考模型。
task automatic simulate_upsample_concat_reference(
    input int dst_width,
    input int dst_height,
    input int src0_channels,
    input int src1_channels
);
    int h, w, c;
    begin
        $display("=== [UPCAT_REF] build software reference ===");
        for (h = 0; h < dst_height; h = h + 1) begin
            for (w = 0; w < dst_width; w = w + 1) begin
                for (c = 0; c < src0_channels; c = c + 1) begin
                    ref_ofm[h][w][c] = ref_ifm[h >> 1][w >> 1][c];
                end
                for (c = 0; c < src1_channels; c = c + 1) begin
                    ref_ofm[h][w][src0_channels + c] = ref_ifm_aux[h][w][c];
                end
            end
        end
        $display("[UPCAT_REF][DBG] ref_ofm[0][0][0] = %0d, ref_ofm[0][0][8] = %0d",
                 ref_ofm[0][0][0], ref_ofm[0][0][8]);
    end
endtask
// 软件残差加参考模型。
task automatic simulate_resadd_reference(
    input int width,
    input int height,
    input int channels,
    input bit relu_en
);
    int h, w, c;
    int sum_val;
    begin
        $display("=== [RESADD_REF] build software reference ===");
        for (h = 0; h < height; h = h + 1) begin
            for (w = 0; w < width; w = w + 1) begin
                for (c = 0; c < channels; c = c + 1) begin
                    sum_val = ref_ifm[h][w][c] + ref_ifm_aux[h][w][c];
                    if (relu_en && (sum_val < 0)) begin
                        sum_val = 0;
                    end
                    ref_ofm[h][w][c] = sat_s8(sum_val);
                end
            end
        end
        $display("[RESADD_REF][DBG] ref_ofm[0][0][0] = %0d", ref_ofm[0][0][0]);
    end
endtask

// ============================================================================
// 算子级独立回归入口
// 每个 task 都会完成：环境复位、输入准备、软件参考、硬件启动和结果比对。
// ============================================================================

// 卷积算子验证入口。
task automatic run_conv_case(input bit relu_en);
    string case_name;
    int in_width;
    int in_height;
    int in_channels;
    int out_width;
    int out_height;
    int out_channels;
    int kx;
    int ky;
    int sx;
    int sy;
    int px;
    int py;
    begin
        case_name    = relu_en ? "CONV_RELU" : "CONV_LINEAR";
        // 卷积验证参数统一从 testbench.sv 顶层配置区读取。
        in_width     = TB_CONV_IN_W;
        // 下面这组赋值会覆盖旧的 task 内默认值，实际以 testbench 顶层参数为准。
        in_width     = Win;
        in_height    = Hin;
        in_channels  = CHin;
        out_channels = CHout;
        kx           = Kx;
        ky           = Ky;
        sx           = Sx;
        sy           = Sy;
        px           = Px;
        py           = Py;
        out_width    = (in_width  - kx + 2 * px) / sx + 1;
        out_height   = (in_height - ky + 2 * py) / sy + 1;

        $display("\n================ %s ================\n", case_name);
        reset_case_env();
        csc_dbg_enable();
        clear_mem_region(IFM_BASE,  calc_feature_bytes(in_width, in_height, in_channels));
        clear_mem_region(WT_BASE,   calc_wt_total_beats(ceil_div_int(in_channels, 8), out_channels, kx, ky) * 16);
        clear_mem_region(BIAS_BASE, ceil_div_int(out_channels, 2) * 16);
        clear_mem_region(OFM_BASE,  calc_feature_bytes(out_width, out_height, out_channels));

        write_feature_tensor(case_name, IFM_BASE, in_width, in_height, in_channels, 0, TB_CONV_IFM_PATTERN);
        build_pattern_conv_bundle(case_name, WT_BASE, BIAS_BASE, in_channels, out_channels, kx, ky);
        simulate_conv_layer(in_width, in_height, in_channels, out_channels, kx, ky, sx, sy, px, py, relu_en);
        program_conv_cfg(IFM_BASE, WT_BASE, BIAS_BASE, OFM_BASE,
                        in_width, in_height, in_channels,
                        out_width, out_height, out_channels,
                        kx, ky, sx, sy, px, py,
                        relu_en, 1'b0, 1'b0, 32'd0, 16'd0);
        wait_case_done(case_name);
        compare_results(OFM_BASE, out_width, out_height, out_channels);
        csc_dbg_disable();
    end
endtask
// 池化算子验证入口。
task automatic run_pool_case(input bit pad_zero);
    string case_name;
    int width;
    int height;
    int channels;
    begin
        case_name = pad_zero ? "POOL_PAD_ZERO" : "POOL_PAD_MIN";
        width     = TB_POOL_W;
        height    = TB_POOL_H;
        channels  = TB_POOL_C;

        $display("\n================ %s ================\n", case_name);
        reset_case_env();
        clear_mem_region(IFM_BASE, calc_feature_bytes(width, height, channels));
        clear_mem_region(OFM_BASE, calc_feature_bytes(width, height, channels));
        write_feature_tensor(case_name, IFM_BASE, width, height, channels, 0, TB_POOL_IFM_PATTERN);
        simulate_pool_reference(width, height, channels, pad_zero);
        program_pool_cfg(IFM_BASE, OFM_BASE, width, height, channels, pad_zero);
        wait_case_done(case_name);
        compare_results(OFM_BASE, width, height, channels);
    end
endtask
// 上采样算子验证入口。
task automatic run_upsample_case();
    string case_name;
    int src_width;
    int src_height;
    int dst_width;
    int dst_height;
    int channels;
    begin
        case_name  = "UPSAMPLE_ONLY";
        src_width  = TB_UP_SRC_W;
        src_height = TB_UP_SRC_H;
        dst_width  = src_width * 2;
        dst_height = src_height * 2;
        channels   = TB_UP_C;

        $display("\n================ %s ================\n", case_name);
        reset_case_env();
        clear_mem_region(IFM_BASE, calc_feature_bytes(src_width, src_height, channels));
        clear_mem_region(WT_BASE, calc_wt_total_beats(ceil_div_int(channels, 8), channels, 1, 1) * 16);
        clear_mem_region(BIAS_BASE, ceil_div_int(channels, 2) * 16);
        clear_mem_region(OFM_BASE, calc_feature_bytes(dst_width, dst_height, channels));
        write_feature_tensor(case_name, IFM_BASE, src_width, src_height, channels, 0, TB_UP_IFM_PATTERN);
        build_identity_conv_bundle(case_name, WT_BASE, BIAS_BASE, channels, channels);
        simulate_upsample_reference(src_width, src_height, channels, dst_width, dst_height);
        program_conv_cfg(IFM_BASE, WT_BASE, BIAS_BASE, OFM_BASE,
                        dst_width, dst_height, channels,
                        dst_width, dst_height, channels,
                        1, 1, 1, 1, 0, 0,
                        1'b0, 1'b0, 1'b1, 32'd0, 16'd0);
        wait_case_done(case_name);
        compare_results(OFM_BASE, dst_width, dst_height, channels);
    end
endtask
// concat 算子验证入口。
task automatic run_concat_case();
    string case_name;
    int width;
    int height;
    int src0_channels;
    int src1_channels;
    int total_channels;
    int src0_groups;
    begin
        case_name      = "CONCAT_ONLY";
        width          = TB_CAT_W;
        height         = TB_CAT_H;
        src0_channels  = TB_CAT_SRC0_C;
        src1_channels  = TB_CAT_SRC1_C;
        total_channels = src0_channels + src1_channels;
        src0_groups    = ceil_div_int(src0_channels, 8);

        $display("\n================ %s ================\n", case_name);
        reset_case_env();
        clear_mem_region(IFM_BASE, calc_feature_bytes(width, height, src0_channels));
        clear_mem_region(AUX_BASE, calc_feature_bytes(width, height, src1_channels));
        clear_mem_region(WT_BASE, calc_wt_total_beats(ceil_div_int(total_channels, 8), total_channels, 1, 1) * 16);
        clear_mem_region(BIAS_BASE, ceil_div_int(total_channels, 2) * 16);
        clear_mem_region(OFM_BASE, calc_feature_bytes(width, height, total_channels));
        write_feature_tensor("CONCAT_SRC0", IFM_BASE, width, height, src0_channels, 0, TB_CAT_SRC0_PATTERN);
        write_feature_tensor("CONCAT_SRC1", AUX_BASE, width, height, src1_channels, 1, TB_CAT_SRC1_PATTERN);
        build_identity_conv_bundle(case_name, WT_BASE, BIAS_BASE, total_channels, total_channels);
        simulate_concat_reference(width, height, src0_channels, src1_channels);
        program_conv_cfg(IFM_BASE, WT_BASE, BIAS_BASE, OFM_BASE,
                        width, height, total_channels,
                        width, height, total_channels,
                        1, 1, 1, 1, 0, 0,
                        1'b0, 1'b1, 1'b0, AUX_BASE, src0_groups);
        wait_case_done(case_name);
        compare_results(OFM_BASE, width, height, total_channels);
    end
endtask
// 上采样 + concat 联合验证入口。
task automatic run_upsample_concat_case();
    string case_name;
    int src0_width;
    int src0_height;
    int dst_width;
    int dst_height;
    int src0_channels;
    int src1_channels;
    int total_channels;
    int src0_groups;
    begin
        case_name      = "UPSAMPLE_CONCAT";
        src0_width     = TB_UPCAT_SRC0_W;
        src0_height    = TB_UPCAT_SRC0_H;
        dst_width      = src0_width * 2;
        dst_height     = src0_height * 2;
        src0_channels  = TB_UPCAT_SRC0_C;
        src1_channels  = TB_UPCAT_SRC1_C;
        total_channels = src0_channels + src1_channels;
        src0_groups    = ceil_div_int(src0_channels, 8);

        $display("\n================ %s ================\n", case_name);
        reset_case_env();
        clear_mem_region(IFM_BASE, calc_feature_bytes(src0_width, src0_height, src0_channels));
        clear_mem_region(AUX_BASE, calc_feature_bytes(dst_width, dst_height, src1_channels));
        clear_mem_region(WT_BASE, calc_wt_total_beats(ceil_div_int(total_channels, 8), total_channels, 1, 1) * 16);
        clear_mem_region(BIAS_BASE, ceil_div_int(total_channels, 2) * 16);
        clear_mem_region(OFM_BASE, calc_feature_bytes(dst_width, dst_height, total_channels));
        write_feature_tensor("UPCAT_SRC0", IFM_BASE, src0_width, src0_height, src0_channels, 0, TB_UPCAT_SRC0_PATTERN);
        write_feature_tensor("UPCAT_SRC1", AUX_BASE, dst_width, dst_height, src1_channels, 1, TB_UPCAT_SRC1_PATTERN);
        build_identity_conv_bundle(case_name, WT_BASE, BIAS_BASE, total_channels, total_channels);
        simulate_upsample_concat_reference(dst_width, dst_height, src0_channels, src1_channels);
        program_conv_cfg(IFM_BASE, WT_BASE, BIAS_BASE, OFM_BASE,
                        dst_width, dst_height, total_channels,
                        dst_width, dst_height, total_channels,
                        1, 1, 1, 1, 0, 0,
                        1'b0, 1'b1, 1'b1, AUX_BASE, src0_groups);
        wait_case_done(case_name);
        compare_results(OFM_BASE, dst_width, dst_height, total_channels);
    end
endtask
// 残差加算子验证入口。
task automatic run_resadd_case(input bit relu_en);
    string case_name;
    int width;
    int height;
    int channels;
    begin
        case_name = relu_en ? "RESADD_RELU" : "RESADD_LINEAR";
        width     = TB_RESADD_W;
        height    = TB_RESADD_H;
        channels  = TB_RESADD_C;

        $display("\n================ %s ================\n", case_name);
        reset_case_env();
        clear_mem_region(IFM_BASE, calc_feature_bytes(width, height, channels));
        clear_mem_region(RES_BASE, calc_feature_bytes(width, height, channels));
        clear_mem_region(OFM_BASE, calc_feature_bytes(width, height, channels));
        write_feature_tensor("RESADD_SRC0", IFM_BASE, width, height, channels, 0, TB_RESADD_SRC0_PATTERN);
        write_feature_tensor("RESADD_SRC1", RES_BASE, width, height, channels, 1, TB_RESADD_SRC1_PATTERN);
        simulate_resadd_reference(width, height, channels, relu_en);
        program_resadd_cfg(IFM_BASE, RES_BASE, OFM_BASE, width, height, channels, relu_en);
        wait_case_done(case_name);
        compare_results(OFM_BASE, width, height, channels);
    end
endtask
// 顺序执行所有算子回归任务。  上采样,卷积,池化,contact过了.残差没过
task automatic run_operator_regression();
    begin
        run_conv_case(1'b0);
        //run_conv_case(1'b1);
        //run_pool_case(1'b0);
        // run_pool_case(1'b1);
        //run_upsample_case();
        //run_concat_case();
        //run_upsample_concat_case();
        //run_resadd_case(1'b0);
        //run_resadd_case(1'b1);

        $display("\n=======================================================");
        $display(">>> all operator verification tasks have finished");
        $display("=======================================================\n");
    end
endtask

`endif
