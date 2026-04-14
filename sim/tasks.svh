`include "../defines.vh"


// =========================================================================
// 通用仿真任务库
// 包含卷积路径验证需要的底层配置任务、软件参考模型、数据装载与结果比对。
// =========================================================================
task  automatic load_config_and_run(input string filename);
    int fd;
    int items_read;
    logic [7:0]  file_addr;
    logic [31:0] file_data;

    fd = $fopen(filename, "r");
    if (fd == 0) begin
        $display("[Error] 无法打开配置文件: %s", filename);
        $finish;
    end

    $display("=== [Testbench] 开始加载寄存器配置: %s ===", filename);


    while (!$feof(fd)) begin
        items_read = $fscanf(fd, "%h %h", file_addr, file_data);
        if (items_read == 2) begin

            cfg_write(file_addr, file_data);
            $display("[CFG] 写入地址: 8'h%h, 数据: 32'h%h", file_addr, file_data);
        end
    end
    $fclose(fd);

    $display("=== [Testbench] 寄存器配置加载完成 ===");


    $display("=== [Testbench] 发送启动命令 (ap_start) ===");
    cfg_write(8'h00, 32'h0000_0001);
endtask

// =========================================================================
// 配置总线写任务
// 在负边沿发起请求，等待 cfg_ack 完成一次完整握手。
// =========================================================================

task  automatic cfg_write(input logic [7:0] addr, input logic [31:0] data);
    @(negedge clk);
    cfg_req   <= 1'b1;
    cfg_addr  <= addr;
    cfg_wdata <= data;



    wait(cfg_ack == 1'b1);
    @(negedge clk);


    cfg_req <= 1'b0;
    wait(cfg_ack == 1'b0);
endtask



// =========================================================================
// 卷积软件参考模型
// 计算流程与硬件保持一致：MAC -> scale/bias -> shift -> 可选 ReLU。
// =========================================================================
task automatic simulate_conv_layer(
    input int Win, input int Hin, input int CHin, input int CHout,
    input int Kx, input int Ky, input int Sx, input int Sy,
    input int pad_x, input int pad_y,
    input bit relu_en
);
    int Wout, Hout;
    int ho, wo, oc, ky, kx, ic;
    int hi, wi;


    longint acc;
    longint raw_mul;
    longint shifted;
    int     out_val;

    begin

        Wout = (Win - Kx + 2 * pad_x) / Sx + 1;
        Hout = (Hin - Ky + 2 * pad_y) / Sy + 1;

        $display("=== [Ref Model] 开始计算卷积: %0dx%0d (In: %0d, Out: %0d) ===", Wout, Hout, CHin, CHout);


        for (ho = 0; ho < Hout; ho++) begin
            for (wo = 0; wo < Wout; wo++) begin
                for (oc = 0; oc < CHout; oc++) begin

                    acc = 0;


                    for (ky = 0; ky < Ky; ky++) begin
                        for (kx = 0; kx < Kx; kx++) begin


                            hi = ho * Sy + ky - pad_y;
                            wi = wo * Sx + kx - pad_x;


                            if (hi >= 0 && hi < Hin && wi >= 0 && wi < Win) begin
                                for (ic = 0; ic < CHin; ic++) begin

                                    acc = acc + (ref_ifm[hi][wi][ic] * ref_wt[oc][ic][ky][kx]);
                                end
                            end

                        end
                    end

                    // 与硬件 requant 顺序保持一致：先乘 scale，再加 bias。
                    raw_mul = (acc * ref_scale[oc]) + ref_bias[oc];



                    shifted = raw_mul >>> ref_shift[oc];


                    if (relu_en) begin
                        if (shifted < 0)        out_val = 0;
                        else if (shifted > 127) out_val = 127;
                        else                    out_val = shifted;
                    end else begin
                        if (shifted < -128)     out_val = -128;
                        else if (shifted > 127) out_val = 127;
                        else                    out_val = shifted;
                    end


                    ref_ofm[ho][wo][oc] = out_val;

                end
            end
        end
        $display("=== [Ref Model] 卷积参考计算完成 ===");
    end
endtask

// =========================================================================
// 量化参数装载任务
// 文本中的每一行对应一个输出通道的 {shift, scale, bias}。
// =========================================================================
task automatic  load_params(input string filename, input logic [31:0] base_addr, input int OC);
    int fd, items;
    logic [63:0] line_data;
    logic [37:0] raw_bias;
    logic [17:0] raw_scale;
    logic [7:0]  raw_shift;
    int addr_offset;

    fd = $fopen(filename, "r");
    if (fd == 0) begin
        $display("[Error] 无法打开参数文件: %s", filename);
        $finish;
    end

    $display("=== [Testbench] 开始加载参数文件: %s ===", filename);
    for (int oc = 0; oc < OC; oc++) begin
        items = $fscanf(fd, "%h", line_data);
        if (items == 1) begin



            raw_shift = line_data[63:56]; // [63:56] 8-bit
            raw_scale = line_data[55:38]; // [55:38] 18-bit
            raw_bias  = line_data[37:0];


            ref_shift[oc] = raw_shift;
            ref_scale[oc] = (raw_scale[17]) ? {14'h3FFF, raw_scale} : {14'h0000, raw_scale};

            ref_bias[oc]  = (raw_bias[37])  ? {26'h3FFFFFF, raw_bias} : {26'h0000000, raw_bias};


            addr_offset = base_addr + (oc * 8); // 64-bit = 8 bytes
            u_AXI_HP_Slave.memory[addr_offset / 4]     = line_data[31:0];
            u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = line_data[63:32];
        end
    end


    if (OC % 2 != 0) begin
        void'($fscanf(fd, "%h", line_data));
        addr_offset = base_addr + (OC * 8);
        u_AXI_HP_Slave.memory[addr_offset / 4]     = line_data[31:0];
        u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = line_data[63:32];
    end

    $fclose(fd);
    $display("=== [Testbench] 参数加载完成 ===");
endtask

// =========================================================================
// 权重装载任务
// 除了写入 DDR 模型外，还会同步展开 ref_wt 供软件参考模型使用。
// =========================================================================
task automatic load_weights(input string filename, input logic [31:0] base_addr,
                input int OC, input int IC, input int Ky, input int Kx);
    int fd, items;
    logic [127:0] line_data;
    int OC_pad, IC_pad;
    int co_grp_end;
    int addr_offset;

    fd = $fopen(filename, "r");
    if (fd == 0) begin
        $display("[Error] 无法打开权重文件: %s", filename);
        $finish;
    end

    OC_pad = (OC % 2 == 0) ? OC : OC + 1;
    IC_pad = (IC % 8 == 0) ? IC : IC + (8 - (IC % 8));
    addr_offset = base_addr;

    $display("=== [Testbench] 开始加载并重排权重: %s ===", filename);


    for (int co_grp = 0; co_grp < OC_pad; co_grp += 16) begin
        for (int ci_grp = 0; ci_grp < IC_pad; ci_grp += 8) begin
            for (int ky = 0; ky < Ky; ky++) begin
                for (int kx = 0; kx < Kx; kx++) begin

                    co_grp_end = (co_grp + 16 > OC_pad) ? OC_pad : co_grp + 16;
                    for (int oc_pair = co_grp; oc_pair < co_grp_end; oc_pair += 2) begin
                        items = $fscanf(fd, "%h", line_data);
                        if (items == 1) begin

                            u_AXI_HP_Slave.memory[addr_offset / 4]     = line_data[31:0];
                            u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = line_data[63:32];
                            u_AXI_HP_Slave.memory[(addr_offset / 4)+2] = line_data[95:64];
                            u_AXI_HP_Slave.memory[(addr_offset / 4)+3] = line_data[127:96];
                            addr_offset += 16;


                            for (int i = 0; i < 8; i++) begin
                                if ((ci_grp + i) < IC) begin

                                    if (oc_pair < OC)
                                        ref_wt[oc_pair][ci_grp+i][ky][kx] = $signed(line_data[i*8 +: 8]);

                                    if ((oc_pair + 1) < OC)
                                        ref_wt[oc_pair+1][ci_grp+i][ky][kx] = $signed(line_data[64 + i*8 +: 8]);
                                end
                            end
                        end
                    end

                end
            end
        end
    end

    $fclose(fd);
    $display("=== [Testbench] 权重加载与重排完成 ===");
endtask


// =========================================================================
// 结果比对任务
// 从 AXI 从内存中读回输出，并与 ref_ofm 逐点比较。
// =========================================================================
task automatic compare_results(input logic [31:0] base_addr,
                            input int Wout, input int Hout, input int OC);
    logic [127:0] hw_data;
    logic signed [7:0] hw_val, sw_val;
    int addr_offset;
    int error_cnt = 0;

    int W_groups, C_groups;
    int current_w, current_c;


    W_groups = (Wout + 1) / 2;
    C_groups = (OC + 7) / 8;

    $display("=== [Scoreboard] 开始比对硬件输出结果 (顺序: H -> C_grp -> W_grp) ===");


    for (int h = 0; h < Hout; h++) begin
        for (int cg = 0; cg < C_groups; cg++) begin
            for (int wg = 0; wg < W_groups; wg++) begin


                addr_offset = base_addr + ((h * C_groups * W_groups) + (cg * W_groups) + wg) * 16;


                hw_data[31:0]   = u_AXI_HP_Slave.memory[addr_offset / 4];
                hw_data[63:32]  = u_AXI_HP_Slave.memory[(addr_offset / 4)+1];
                hw_data[95:64]  = u_AXI_HP_Slave.memory[(addr_offset / 4)+2];
                hw_data[127:96] = u_AXI_HP_Slave.memory[(addr_offset / 4)+3];


                for (int p = 0; p < 2; p++) begin
                    current_w = wg * 2 + p;


                    if (current_w < Wout) begin


                        for (int c = 0; c < 8; c++) begin
                            current_c = cg * 8 + c;


                            if (current_c < OC) begin




                                hw_val = $signed(hw_data[p*64 + c*8 +: 8]);
                                sw_val = ref_ofm[h][current_w][current_c];

                                if (hw_val !== sw_val) begin
                                    if (error_cnt < 10) begin
                                        $display("[Error] 位置(H:%0d, W:%0d, C:%0d)不匹配! HW: %0d, SW: %0d",
                                                h, current_w, current_c, hw_val, sw_val);
                                    end
                                    error_cnt++;
                                end
                            end
                        end
                    end
                end

            end
        end
    end

    if (error_cnt == 0)
        $display("=== [Result] 验证通过，硬件输出与软件参考完全一致 (共比对 %0d 个点) ===", Wout*Hout*OC);
    else
        $display("=== [Result] 验证失败，共发现 %0d 个不匹配 ===", error_cnt);
endtask


// =========================================================================
// 输入特征图生成任务
// 生成可重复的简单模式输入，并同步写入 ref_ifm 与 AXI 内存。
// =========================================================================
task automatic generate_random_ifm(input logic [31:0] base_addr,
                                input int Win, input int Hin, input int CHin);
    int addr_offset;
    logic [127:0] packed_data;
    logic signed [7:0] rand_val;

    int W_groups, C_groups;
    int current_w, current_c;


    W_groups = (Win + 1) / 2;
    C_groups = (CHin + 7) / 8;

    addr_offset = base_addr;

    $display("=== [Testbench] 开始生成输入特征图: %0dx%0dx%0d (顺序: H->C_grp->W_grp) ===", Hin, Win, CHin);


    for (int h = 0; h < Hin; h++) begin
        for (int cg = 0; cg < C_groups; cg++) begin
            for (int wg = 0; wg < W_groups; wg++) begin

                packed_data = 128'd0;


                for (int p = 0; p < 2; p++) begin
                    current_w = wg * 2 + p;


                    if (current_w < Win) begin


                        for (int c = 0; c < 8; c++) begin
                            current_c = cg * 8 + c;


                            if (current_c < CHin) begin

                                rand_val = current_w[7:0];

                                ref_ifm[h][current_w][current_c] = rand_val;



                                packed_data[p*64 + c*8 +: 8] = rand_val;
                            end
                        end
                    end
                end



                u_AXI_HP_Slave.memory[addr_offset / 4]     = packed_data[31:0];
                u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = packed_data[63:32];
                u_AXI_HP_Slave.memory[(addr_offset / 4)+2] = packed_data[95:64];
                u_AXI_HP_Slave.memory[(addr_offset / 4)+3] = packed_data[127:96];
                addr_offset += 16;

            end
        end
    end
    $display("=== [Testbench] 输入特征图生成并写入完成 ===");
endtask
