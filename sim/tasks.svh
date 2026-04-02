`include "../defines.vh"


// =========================================================================
// 读取配置文本并自动下发 Task
// =========================================================================
task  automatic load_config_and_run(input string filename);
    int fd;
    int items_read;
    logic [7:0]  file_addr;
    logic [31:0] file_data;

    fd = $fopen(filename, "r");   //存储句柄
    if (fd == 0) begin
        $display("[Error] 无法打开配置文件: %s", filename);
        $finish;
    end

    $display("=== [Testbench] 开始加载寄存器配置: %s ===", filename);

    // 逐行读取文件
    while (!$feof(fd)) begin  //没到文件末尾就继续循环
        items_read = $fscanf(fd, "%h %h", file_addr, file_data);
        if (items_read == 2) begin   //当的确读到一个键值对才写入
            // 调用底层的配置任务下发数据
            cfg_write(file_addr, file_data);
            $display("[CFG] 写入地址: 8'h%h, 数据: 32'h%h", file_addr, file_data);
        end
    end
    $fclose(fd);

    $display("=== [Testbench] 寄存器配置加载完毕 ===");

    // 最后触发硬件开始计算 (对应 8'h00 地址写 1)
    $display("=== [Testbench] 发送启动脉冲 (ap_start) ===");
    cfg_write(8'h00, 32'h0000_0001);
endtask

// =========================================================================
// 极简配置总线底层写驱动 (供 load_config_and_run 调用)
// =========================================================================
//negedge  clk触发激励发送,posedge  clk进行状态检测与数据抓取
task  automatic cfg_write(input logic [7:0] addr, input logic [31:0] data);
    @(negedge clk);
    cfg_req   <= 1'b1;
    cfg_addr  <= addr;
    cfg_wdata <= data;


    // 等待从机应答
    wait(cfg_ack == 1'b1);
    @(negedge clk);
    
    // 撤销请求
    cfg_req <= 1'b0;
    wait(cfg_ack == 1'b0);
endtask



// =========================================================================
// 软件参考模型 Task：执行比特级一致的量化卷积
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
    
    // 累加与量化中间变量 (严格对齐硬件位宽)
    longint acc;       // 对应硬件 27-bit 累加器 (使用 64-bit 防止软件溢出)
    longint raw_mul;   // 对应硬件 Stage 1: (Acc + Bias) * Scale
    longint shifted;   // 对应硬件 Stage 2: 移位后结果
    int     out_val;   // 最终截断结果

    begin
        // 1. 计算输出维度
        Wout = (Win - Kx + 2 * pad_x) / Sx + 1;
        Hout = (Hin - Ky + 2 * pad_y) / Sy + 1;

        $display("=== [Ref Model] 开始计算: %0dx%0d (In: %0d, Out: %0d) ===", Wout, Hout, CHin, CHout);

        // 2. 遍历输出特征图的每一个点
        for (ho = 0; ho < Hout; ho++) begin
            for (wo = 0; wo < Wout; wo++) begin
                for (oc = 0; oc < CHout; oc++) begin
                    
                    acc = 0; // 每个输出点累加器清零

                    // 3. 展开卷积核与输入通道进行 MAC 运算
                    for (ky = 0; ky < Ky; ky++) begin
                        for (kx = 0; kx < Kx; kx++) begin
                            
                            // 映射到输入图的物理坐标
                            hi = ho * Sy + ky - pad_y;
                            wi = wo * Sx + kx - pad_x;

                            // 边界检查 (Padding 清洗逻辑)
                            if (hi >= 0 && hi < Hin && wi >= 0 && wi < Win) begin
                                for (ic = 0; ic < CHin; ic++) begin
                                    // 乘加：如果坐标有效，执行有符号乘加
                                    acc = acc + (ref_ifm[hi][wi][ic] * ref_wt[oc][ic][ky][kx]);
                                end
                            end
                            // 如果坐标越界，等效于硬件 csc_dat 中的 p_mask 置 0，不累加
                        end
                    end

                    // ==========================================
                    // 4. 严格对齐硬件的 Requant 反量化逻辑
                    // ==========================================
                    // 第一步：乘法补偿 (Acc + Bias) * Scale
                    //raw_mul = (acc + ref_bias[oc]) * ref_scale[oc];

                    // 第一步：乘法补偿 (Acc * Scale) + Bias 
                    // 【核心修复】：改为先乘再加，与 DSP 硬件架构绝对一致
                    raw_mul = (acc * ref_scale[oc]) + ref_bias[oc];

                    // 第二步：算术右移
                    // 注意：在 SV 中，对 signed 类型使用 >>> 是算术右移（保留符号位）
                    shifted = raw_mul >>> ref_shift[oc];

                    // 第三步：饱和截断与 ReLU
                    if (relu_en) begin
                        if (shifted < 0)        out_val = 0;
                        else if (shifted > 127) out_val = 127;
                        else                    out_val = shifted;
                    end else begin
                        if (shifted < -128)     out_val = -128;
                        else if (shifted > 127) out_val = 127;
                        else                    out_val = shifted;
                    end

                    // 将结果写入参考模型的输出数组
                    ref_ofm[ho][wo][oc] = out_val;

                end
            end
        end
        $display("=== [Ref Model] 卷积计算完成 ===");
    end
endtask

// =========================================================================
// 读取量化参数 (Bias, Scale, Shift)
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
        if (items == 1) begin  //读取64bit数据
    

            // 【修改这里】：对齐 Python 脚本与硬件的新 64-bit 协议
            raw_shift = line_data[63:56]; // [63:56] 8-bit
            raw_scale = line_data[55:38]; // [55:38] 18-bit
            raw_bias  = line_data[37:0];  // [37:0]  38-bit (注意：原来的 raw_bias 声明需改成 logic [37:0])

            // 符号位扩展 (将 18bit/38bit 扩展为 SV 的 64bit signed, 注意 ref_bias 也要扩位)
            ref_shift[oc] = raw_shift;
            ref_scale[oc] = (raw_scale[17]) ? {14'h3FFF, raw_scale} : {14'h0000, raw_scale};
            // 38-bit 符号扩展到 64-bit (或者 64-bit 声明的数组)
            ref_bias[oc]  = (raw_bias[37])  ? {26'h3FFFFFF, raw_bias} : {26'h0000000, raw_bias};

            // 2. 压入底层 AXI Memory (假设 u_AXI_HP_Slave.memory 是 32-bit 数组)
            addr_offset = base_addr + (oc * 8); // 64-bit = 8 bytes
            u_AXI_HP_Slave.memory[addr_offset / 4]     = line_data[31:0];
            u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = line_data[63:32];
        end
    end
    
    // 处理奇数 OC 的 64-bit 占位符对齐
    if (OC % 2 != 0) begin
        void'($fscanf(fd, "%h", line_data));  //oc为奇数时,在脚本中会多填充一个64bit的0需要读出来
        addr_offset = base_addr + (OC * 8);
        u_AXI_HP_Slave.memory[addr_offset / 4]     = line_data[31:0];
        u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = line_data[63:32];
    end

    $fclose(fd);
    $display("=== [Testbench] 参数加载完成 ===");
endtask

// =========================================================================
// 读取 INT8 权重数据并反向重排
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

    // 严格镜像 Python 的打包装箱顺序
    for (int co_grp = 0; co_grp < OC_pad; co_grp += 16) begin
        for (int ci_grp = 0; ci_grp < IC_pad; ci_grp += 8) begin
            for (int ky = 0; ky < Ky; ky++) begin
                for (int kx = 0; kx < Kx; kx++) begin
                    
                    co_grp_end = (co_grp + 16 > OC_pad) ? OC_pad : co_grp + 16;  //本组有多少个输出通道
                    for (int oc_pair = co_grp; oc_pair < co_grp_end; oc_pair += 2) begin
                        items = $fscanf(fd, "%h", line_data);
                        if (items == 1) begin
                            // 1. 压入底层 AXI Memory (每行 128-bit = 16 bytes = 4 个 32-bit word)
                            u_AXI_HP_Slave.memory[addr_offset / 4]     = line_data[31:0];
                            u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = line_data[63:32];
                            u_AXI_HP_Slave.memory[(addr_offset / 4)+2] = line_data[95:64];
                            u_AXI_HP_Slave.memory[(addr_offset / 4)+3] = line_data[127:96];
                            addr_offset += 16;

                            // 2. 解析回软件参考模型 ref_wt
                            for (int i = 0; i < 8; i++) begin
                                if ((ci_grp + i) < IC) begin   //不接受补零数据,此处用的是IC和OC而不是pad
                                    // 低 64-bit 对应 OC_A
                                    if (oc_pair < OC)
                                        ref_wt[oc_pair][ci_grp+i][ky][kx] = $signed(line_data[i*8 +: 8]);
                                    // 高 64-bit 对应 OC_B
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
// 硬件写回结果与软件参考模型对比 (Scoreboard) - 适配 [H][C_groups][W_groups]
// =========================================================================
task automatic compare_results(input logic [31:0] base_addr, 
                            input int Wout, input int Hout, input int OC);
    logic [127:0] hw_data;
    logic signed [7:0] hw_val, sw_val;
    int addr_offset;
    int error_cnt = 0;
    
    int W_groups, C_groups;
    int current_w, current_c;

    // 1. 计算内存排布的分组数
    W_groups = (Wout + 1) / 2; // W 方向：每 2 个像素打成一个 128-bit 节拍
    C_groups = (OC + 7) / 8;   // C 方向：每 8 个通道打成一个 64-bit 子块

    $display("=== [Scoreboard] 开始比对软硬件输出结果 (排布: H -> C_grp -> W_grp) ===");

    // 2. 严格按照 WDMA 的线性写入顺序遍历：先行 -> 再通道组 -> 最后列
    for (int h = 0; h < Hout; h++) begin
        for (int cg = 0; cg < C_groups; cg++) begin
            for (int wg = 0; wg < W_groups; wg++) begin
                
                // 物理地址偏移量计算
                addr_offset = base_addr + ((h * C_groups * W_groups) + (cg * W_groups) + wg) * 16;
                
                // 从 AXI Slave 内存中重组 128-bit 数据
                hw_data[31:0]   = u_AXI_HP_Slave.memory[addr_offset / 4];
                hw_data[63:32]  = u_AXI_HP_Slave.memory[(addr_offset / 4)+1];
                hw_data[95:64]  = u_AXI_HP_Slave.memory[(addr_offset / 4)+2];
                hw_data[127:96] = u_AXI_HP_Slave.memory[(addr_offset / 4)+3];

                // 3. 解包 128-bit 数据：包含 p=0 (低64位) 和 p=1 (高64位) 两个像素
                for (int p = 0; p < 2; p++) begin  //写入时两个像素一组
                    current_w = wg * 2 + p;
                    
                    // 越界保护：丢弃行末 Padding 的假像素
                    if (current_w < Wout) begin
                        
                        // 遍历半个节拍里的 8 个通道
                        for (int c = 0; c < 8; c++) begin  //8个通道一组
                            current_c = cg * 8 + c;
                            
                            // 越界保护：丢弃通道末尾 Padding 的假通道
                            if (current_c < OC) begin
                                
                                // 数据切片：
                                // p=0 取 [c*8 +: 8] 
                                // p=1 取 [64 + c*8 +: 8]
                                hw_val = $signed(hw_data[p*64 + c*8 +: 8]);
                                sw_val = ref_ofm[h][current_w][current_c];  //绝对坐标

                                if (hw_val !== sw_val) begin
                                    if (error_cnt < 10) begin
                                        $display("[Error] 坐标(H:%0d, W:%0d, C:%0d)不匹配! HW: %0d, SW: %0d", 
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
        $display("=== [Result] 验证通过！硬件与软件结果比特级对齐 (共比对 %0d 个点) ===", Wout*Hout*OC);
    else
        $display("=== [Result] 验证失败！共发现 %0d 处不匹配 ===", error_cnt);
endtask


// =========================================================================
// 生成随机输入特征图 (IFM) 并写入软件参考模型和硬件 AXI 内存
// 排布格式: [H] -> [C_groups] -> [W_groups] (2 Pixels * 8 Channels per Beat)
// =========================================================================
task automatic generate_random_ifm(input logic [31:0] base_addr, 
                                input int Win, input int Hin, input int CHin);
    int addr_offset;
    logic [127:0] packed_data;
    logic signed [7:0] rand_val;
    
    int W_groups, C_groups;
    int current_w, current_c;

    // 1. 计算维度分组
    W_groups = (Win + 1) / 2;  // W 方向：每 2 个像素打成一个 128-bit 节拍
    C_groups = (CHin + 7) / 8; // C 方向：每 8 个通道为一个组 (TK_IN=8)

    addr_offset = base_addr;

    $display("=== [Testbench] 开始生成随机输入特征图: %0dx%0dx%0d (排布: H->C_grp->W_grp) ===", Hin, Win, CHin);
    
    // 2. 严格镜像 CDMA_RX 的读取顺序：先行 -> 再通道组 -> 最后列
    for (int h = 0; h < Hin; h++) begin
        for (int cg = 0; cg < C_groups; cg++) begin
            for (int wg = 0; wg < W_groups; wg++) begin
                
                packed_data = 128'd0; // 每次打包前清零，确保 Padding 区域干净
                
                // 3. 在这个 128-bit 节拍内，打包 2 个像素 (p=0 和 p=1)
                for (int p = 0; p < 2; p++) begin
                    current_w = wg * 2 + p;
                    
                    // 越界保护：如果图像宽度是奇数，不生成第二个假像素
                    if (current_w < Win) begin
                        
                        // 打包这半个节拍里的 8 个通道
                        for (int c = 0; c < 8; c++) begin
                            current_c = cg * 8 + c;
                            
                            // 越界保护：如果输入通道不是 8 的倍数，不生成假通道
                            if (current_c < CHin) begin
                                // 生成 -128 到 127 之间的随机有符号数
                                //rand_val = $random; 
                                // =======================================================
                                // 【核心修改】：坐标数据注入
                                // 方案 A (极简排查列错位)：直接让像素值等于它的宽度坐标！
                                rand_val = current_w[7:0];
                                
                                // 方案 B (如果以后想查通道错位，可以解开下面这行注释)：
                                // 高4位存宽度的低4位，低4位存通道的低4位
                                // coordinate_val = {current_w[3:0], current_c[3:0]};
                                // =======================================================
                                // 1. 存入软件参考模型 (供黄金模型算答案)
                                ref_ifm[h][current_w][current_c] = rand_val;
                                
                                // 2. 拼装到 128-bit 总线
                                // p=0 放低 64-bit，p=1 放高 64-bit
                                packed_data[p*64 + c*8 +: 8] = rand_val;
                            end
                        end
                    end
                end
                
                // 4. 压入底层 AXI Memory 
                // 由于我们按照硬件读取顺序遍历，地址可以线性递增
                u_AXI_HP_Slave.memory[addr_offset / 4]     = packed_data[31:0];
                u_AXI_HP_Slave.memory[(addr_offset / 4)+1] = packed_data[63:32];
                u_AXI_HP_Slave.memory[(addr_offset / 4)+2] = packed_data[95:64];
                u_AXI_HP_Slave.memory[(addr_offset / 4)+3] = packed_data[127:96];
                addr_offset += 16;
                
            end
        end
    end
    $display("=== [Testbench] 随机特征图生成并加载完成 ===");
endtask