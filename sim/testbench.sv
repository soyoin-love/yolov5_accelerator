`timescale 1ns / 1ps

`include "../defines.vh"

module testbench;

// =========================================================================
// 总线与信号定义（保持你原来的代码不变）
// =========================================================================
reg         clk;
reg         rst_n;
reg         cfg_req = 0;
reg  [7:0]  cfg_addr;
reg  [31:0] cfg_wdata;
wire        cfg_ack;

wire        ap_done;
wire        ap_idle;

// --- 1. 网络层参数定义 (必须与 Python 脚本生成的配置严格对齐) ---
    // 默认使用 gen_config.py 里的 Layer 1 示例参数
    int Win = 80, Hin = 80, CHin = 3, CHout = 16;
    int Kx = 6, Ky = 6, Sx = 2, Sy = 2, Px = 2, Py = 2;
    
    bit relu_en = 1;

    int Wout, Hout;

    // 内存基地址分配 (必须与 Python 脚本中 f_base, w_base 等严格一致)
    logic [31:0] IFM_BASE  = 32'h0000_0000;
    logic [31:0] WT_BASE   = 32'h0002_0000;
    logic [31:0] BIAS_BASE = 32'h0004_0000;
    logic [31:0] OFM_BASE  = 32'h0006_0000;

// AXI信号定义（保持你原来的代码不变）
wire [`C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID;
wire [32-1 : 0] M_AXI_AWADDR;
wire [7 : 0] M_AXI_AWLEN;
wire [2 : 0] M_AXI_AWSIZE;
wire [1 : 0] M_AXI_AWBURST;
wire  M_AXI_AWLOCK;
wire [3 : 0] M_AXI_AWCACHE;
wire [2 : 0] M_AXI_AWPROT;
wire [3 : 0] M_AXI_AWQOS;
wire M_AXI_AWVALID;
wire  M_AXI_AWREADY;
wire [`AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA;
wire [(`AXI_DATA_WIDTH/8)-1 : 0] M_AXI_WSTRB;
wire  M_AXI_WLAST;
wire  M_AXI_WVALID;
wire  M_AXI_WREADY;
wire [`C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID;
wire [1 : 0] M_AXI_BRESP;
wire  M_AXI_BVALID;
wire  M_AXI_BREADY;
wire [`C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID;
wire [32-1 : 0] M_AXI_ARADDR;
wire [7 : 0] M_AXI_ARLEN;
wire [2 : 0] M_AXI_ARSIZE;
wire [1 : 0] M_AXI_ARBURST;
wire  M_AXI_ARLOCK;
wire [3 : 0] M_AXI_ARCACHE;
wire [2 : 0] M_AXI_ARPROT;
wire [3 : 0] M_AXI_ARQOS;
wire  M_AXI_ARVALID;
wire  M_AXI_ARREADY;
wire [`C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID;
wire [`AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA;
wire [1 : 0] M_AXI_RRESP;
wire  M_AXI_RLAST;
wire  M_AXI_RVALID;
wire  M_AXI_RREADY;

// =========================================================================
// 软件参考模型数据结构（保持你原来的代码不变）
// =========================================================================
logic signed [7:0]  ref_ifm   [0:127][0:127][0:127];  //[hi][wi][ic]
logic signed [7:0]  ref_wt    [0:127][0:127][0:7][0:7];  //[oc][ic][ky][kx]
logic signed [63:0] ref_bias  [0:127]; //1*1*[oc]
logic signed [17:0] ref_scale [0:127]; //1*1*[oc]
logic [7:0]         ref_shift [0:127]; //1*1*[oc]
logic signed [7:0]  ref_ofm   [0:127][0:127][0:127];  //[oc][wi][ic]

// 【注意：tasks.svh必须在全局参数声明之后include，否则任务内会报变量未定义】
`include "tasks.svh"

// =========================================================================
// 内存初始化（保持你原来的代码不变）
// =========================================================================
initial begin
    for (int i = 0; i < `MEM_SIZE; i++) begin
        u_AXI_HP_Slave.memory[i] = 0; 
    end
end

always #5 clk = ~clk;

// =========================================================================
// 主验证流程 (Main Verification Flow)
// =========================================================================
initial begin
    

    // --- 2. 信号初始化与硬件复位 ---
    clk = 0;
    rst_n = 0;
    cfg_req = 0;
    cfg_addr = 0;
    cfg_wdata = 0;

    // 提前计算输出维度供后续 Task 使用
    Wout = (Win - Kx + 2 * Px) / Sx + 1;
    Hout = (Hin - Ky + 2 * Py) / Sy + 1;

    #101;
    rst_n = 1;
    #100;

    $display("\n=======================================================");
    $display(">>> YOLO 硬件加速器验证启动 (Layer: %0dx%0d_%0dc -> %0dx%0d_%0dc)", Hin, Win, CHin, Hout, Wout, CHout);
    $display("=======================================================\n");

    // --- 3. 准备测试数据激励 ---
    // 3.1 自动生成随机特征图，按 [H][C_groups][W_groups] 格式打入 AXI 内存与软件参考模型
    generate_random_ifm(IFM_BASE, Win, Hin, CHin);

    // 3.2 加载 Python 导出的权重和量化参数
    // 注意: 确保此处的文件名与 gen_config.py 及 QTR导出二进制文件.py 生成的名字完全一致
    load_weights("E:/IEEE2026/yolov5-7.0/yolov5-7.0/fpga_bin_export/weights_txt/model_0_conv_weights.txt", WT_BASE, CHout, CHin, Ky, Kx);
    load_params("E:/IEEE2026/yolov5-7.0/yolov5-7.0/fpga_bin_export/params_txt/model_0_conv_params.txt", BIAS_BASE, CHout);

    // --- 4. 执行软件参考模型 ---
    // 利用提取的参数，在内存中计算出一份绝对正确的 ref_ofm
    simulate_conv_layer(Win, Hin, CHin, CHout, Kx, Ky, Sx, Sy, Px, Py, relu_en);

    // --- 5. 配置并启动硬件 ---
    // 触发 cfg_write 时序，写完后向 0x00 写入 1 启动全局 FSM
    load_config_and_run("E:/IEEE2026/yolov5-7.0/yolo_quant/layer1_config.txt");

    // --- 6. 等待硬件执行完毕 ---
    $display("=== [Testbench] 等待硬件计算结束 (ap_done) ===");
    // 挂起仿真进程，直到 global_fsm 吐出 ap_done 脉冲
    wait(ap_done == 1'b1);
    $display("=== [Testbench] 硬件计算完成，耗时: %0t ===", $time);

    // 关键防翻车点：硬件发出 ap_done 时，可能 WDMA 的最后一笔 AXI 总线事务刚发出去
    // 必须等待足够的周期，确保 AXI_HP_Slave 将最后的数据彻底写入 memory 数组
    #500; 

    // --- 7. 取回结果并启动比对计分板 ---
    // 按照 [H][C_groups][W_groups] 的格式去底层内存捞数据并与 ref_ofm 逐一比对
    compare_results(OFM_BASE, Wout, Hout, CHout);

    // --- 8. 结束仿真 ---
    #200;
    $finish;
end

// =========================================================================
// DUT与AXI Slave例化（保持你原来的代码不变）
// =========================================================================
yolo_sim_top #(
    .C_M_AXI_ID_WIDTH(`C_M_AXI_ID_WIDTH), 
    .AXI_DATA_WIDTH(`AXI_DATA_WIDTH),     
    .CBUF_ADDR_W(`CBUF_ADDR_W)            
) u_dut (
    .clk           (clk),                
    .rst_n         (rst_n),              
    .cfg_req       (cfg_req),            
    .cfg_addr      (cfg_addr),           
    .cfg_wdata     (cfg_wdata),          
    .cfg_ack       (cfg_ack),            
    .ap_done       (ap_done),            
    .ap_idle       (ap_idle),            
    .M_AXI_AWID    (M_AXI_AWID),         
    .M_AXI_AWADDR  (M_AXI_AWADDR),       
    .M_AXI_AWLEN   (M_AXI_AWLEN),        
    .M_AXI_AWSIZE  (M_AXI_AWSIZE),       
    .M_AXI_AWBURST (M_AXI_AWBURST),      
    .M_AXI_AWLOCK  (M_AXI_AWLOCK),       
    .M_AXI_AWCACHE (M_AXI_AWCACHE),      
    .M_AXI_AWPROT  (M_AXI_AWPROT),       
    .M_AXI_AWQOS   (M_AXI_AWQOS),        
    .M_AXI_AWVALID (M_AXI_AWVALID),      
    .M_AXI_AWREADY (M_AXI_AWREADY),      
    .M_AXI_WDATA   (M_AXI_WDATA),        
    .M_AXI_WSTRB   (M_AXI_WSTRB),        
    .M_AXI_WLAST   (M_AXI_WLAST),        
    .M_AXI_WVALID  (M_AXI_WVALID),       
    .M_AXI_WREADY  (M_AXI_WREADY),       
    .M_AXI_BID     (M_AXI_BID),          
    .M_AXI_BRESP   (M_AXI_BRESP),        
    .M_AXI_BVALID  (M_AXI_BVALID),       
    .M_AXI_BREADY  (M_AXI_BREADY),       
    .M_AXI_ARID    (M_AXI_ARID),         
    .M_AXI_ARADDR  (M_AXI_ARADDR),       
    .M_AXI_ARLEN   (M_AXI_ARLEN),        
    .M_AXI_ARSIZE  (M_AXI_ARSIZE),       
    .M_AXI_ARBURST (M_AXI_ARBURST),      
    .M_AXI_ARLOCK  (M_AXI_ARLOCK),       
    .M_AXI_ARCACHE (M_AXI_ARCACHE),      
    .M_AXI_ARPROT  (M_AXI_ARPROT),       
    .M_AXI_ARQOS   (M_AXI_ARQOS),        
    .M_AXI_ARVALID (M_AXI_ARVALID),      
    .M_AXI_ARREADY (M_AXI_ARREADY),      
    .M_AXI_RID     (M_AXI_RID),          
    .M_AXI_RDATA   (M_AXI_RDATA),        
    .M_AXI_RRESP   (M_AXI_RRESP),        
    .M_AXI_RLAST   (M_AXI_RLAST),        
    .M_AXI_RVALID  (M_AXI_RVALID),       
    .M_AXI_RREADY  (M_AXI_RREADY)        
);

AXI_HP_Slave #
(
	.C_S_AXI_ID_WIDTH(`C_M_AXI_ID_WIDTH),
	.C_S_AXI_DATA_WIDTH(`AXI_DATA_WIDTH),
	.C_S_AXI_ADDR_WIDTH(32)
)u_AXI_HP_Slave
(
	.S_AXI_ACLK(clk),
	.S_AXI_ARESETN(rst_n),
	.S_AXI_AWID(M_AXI_AWID),
	.S_AXI_AWADDR(M_AXI_AWADDR),
	.S_AXI_AWLEN(M_AXI_AWLEN),
	.S_AXI_AWSIZE(M_AXI_AWSIZE),
	.S_AXI_AWBURST(M_AXI_AWBURST),
	.S_AXI_AWLOCK(M_AXI_AWLOCK),
	.S_AXI_AWCACHE(M_AXI_AWCACHE),
	.S_AXI_AWPROT(M_AXI_AWPROT),
	.S_AXI_AWQOS(M_AXI_AWQOS),
    .S_AXI_AWREGION(4'b0000),
	.S_AXI_AWVALID(M_AXI_AWVALID),
	.S_AXI_AWREADY(M_AXI_AWREADY),
	.S_AXI_WDATA(M_AXI_WDATA),
	.S_AXI_WSTRB(M_AXI_WSTRB),
	.S_AXI_WLAST(M_AXI_WLAST),
	.S_AXI_WVALID(M_AXI_WVALID),
	.S_AXI_WREADY(M_AXI_WREADY),
	.S_AXI_BID(M_AXI_BID),
	.S_AXI_BRESP(M_AXI_BRESP),
	.S_AXI_BVALID(M_AXI_BVALID),
	.S_AXI_BREADY(M_AXI_BREADY),
	.S_AXI_ARID(M_AXI_ARID),
	.S_AXI_ARADDR(M_AXI_ARADDR),
	.S_AXI_ARLEN(M_AXI_ARLEN),
	.S_AXI_ARSIZE(M_AXI_ARSIZE),
	.S_AXI_ARBURST(M_AXI_ARBURST),
	.S_AXI_ARLOCK(M_AXI_ARLOCK),
	.S_AXI_ARCACHE(M_AXI_ARCACHE),
	.S_AXI_ARPROT(M_AXI_ARPROT),
	.S_AXI_ARQOS(M_AXI_ARQOS),
	.S_AXI_ARVALID(M_AXI_ARVALID),
	.S_AXI_ARREADY(M_AXI_ARREADY),
	.S_AXI_RID(M_AXI_RID),
	.S_AXI_RDATA(M_AXI_RDATA),
	.S_AXI_RRESP(M_AXI_RRESP),
	.S_AXI_RLAST(M_AXI_RLAST),
	.S_AXI_RVALID(M_AXI_RVALID),
	.S_AXI_RREADY(M_AXI_RREADY)
);

// =========================================================================
// cacc_requant 模块直接输出拦截与比对 (灰盒探针)
// =========================================================================
// 1. 探针连线：直接刺入底层抓取量化模块的输出
wire        probe_req_vld  = u_dut.u_accel.u_cacc.obuf_wr_vld;
wire [15:0] probe_req_mask = u_dut.u_accel.u_cacc.obuf_wr_mask;
wire [1023:0] probe_req_dat  = u_dut.u_accel.u_cacc.obuf_wr_dat;



// 2. 软件坐标追踪器
int tr_w_blk = 0;
int tr_co_grp = 0;
int tr_h = 0;

int W_out_blocks;
int CO_groups;

// 记录错误数量，防止刷屏
int req_error_cnt = 0;

initial begin
    // 等待配置加载完毕，拿到真实的计算维度
    wait(ap_done == 1'b0); // 等待复位结束
    wait(u_dut.u_accel.buf_start == 1'b1); // 等待启动脉冲
    
    W_out_blocks = (Wout + 7) / 8; // 宽度方向分为几个 8 像素块
    CO_groups    = (CHout + 15) / 16; // 通道方向分为几个 16 通道组
    
    $display("=== [Requant Probe] 探针计分板已启动 (W_blk:%0d, CO_grp:%0d) ===", W_out_blocks, CO_groups);
end
// ==========================================
// 专供看波形的“降维打击”探针
// ==========================================
// 将 1024-bit 彻底展开为 [像素 p=0~7][通道 ch=0~15] 的二维数组
logic signed [7:0] wave_view_dat [0:7][0:15];

always_comb begin
    for (int p = 0; p < 8; p++) begin
        for (int c = 0; c < 8; c++) begin
            // 解析 Group 0 (Ch 0~7)
            wave_view_dat[p][c]   = $signed(probe_req_dat[p*64 + c*8 +: 8]);
            // 解析 Group 1 (Ch 8~15)
            wave_view_dat[p][c+8] = $signed(probe_req_dat[512 + p*64 + c*8 +: 8]);
        end
    end
end
always @(posedge clk) begin
    if (probe_req_vld) begin
        // 遍历当前吐出的 8 个并行像素
        for (int p = 0; p < 8; p++) begin
            automatic int current_w = tr_w_blk * 8 + p;
            
            // 如果该像素在图像宽度范围内
            if (current_w < Wout) begin
                
                // 校验 Group 0 (当前通道组的前 8 个通道)
                if (probe_req_mask[p] == 1'b1) begin
                    for (int c = 0; c < 8; c++) begin
                        automatic int current_c = tr_co_grp * 16 + c;
                        if (current_c < CHout) begin
                            automatic logic signed [7:0] hw_val = $signed(probe_req_dat[p*64 + c*8 +: 8]);
                            automatic logic signed [7:0] sw_val = ref_ofm[tr_h][current_w][current_c];
                            
                            if (hw_val !== sw_val) begin
                                if (req_error_cnt < 15) begin
                                    $display("[Requant Err] 坐标(H:%0d, W:%0d, C:%0d)不匹配! HW: %0d, SW: %0d", 
                                            tr_h, current_w, current_c, hw_val, sw_val);
                                end
                                req_error_cnt++;
                            end
                        end
                    end
                end
                
                // 校验 Group 1 (当前通道组的后 8 个通道)
                if (probe_req_mask[p + 8] == 1'b1) begin
                    for (int c = 0; c < 8; c++) begin
                        automatic int current_c = tr_co_grp * 16 + 8 + c;
                        if (current_c < CHout) begin
                            automatic logic signed [7:0] hw_val = $signed(probe_req_dat[512 + p*64 + c*8 +: 8]);
                            automatic logic signed [7:0] sw_val = ref_ofm[tr_h][current_w][current_c];
                            
                            if (hw_val !== sw_val) begin
                                if (req_error_cnt < 15) begin
                                    $display("[Requant Err] 坐标(H:%0d, W:%0d, C:%0d)不匹配! HW: %0d, SW: %0d", 
                                            tr_h, current_w, current_c, hw_val, sw_val);
                                end
                                req_error_cnt++;
                            end
                        end
                    end
                end
            end
        end // end of pixel loop
        
        // --- 坐标状态机步进 ---
        tr_w_blk++;
        if (tr_w_blk == W_out_blocks) begin
            tr_w_blk = 0;
            tr_co_grp++;
            if (tr_co_grp == CO_groups) begin
                tr_co_grp = 0;
                tr_h++;
            end
        end
    end
end

// =========================================================================
// CMAC_ARRAY 模块输出拦截与降维探针
// =========================================================================
// 1. 探针连线：抓取 cmac_array 的原始输出[cite: 1]
wire        probe_mac_vld  = u_dut.u_accel.u_mac_array.mac_valid_out;
wire [7:0]  probe_mac_mask = u_dut.u_accel.u_mac_array.mac_pixel_mask_out;
wire [15:0] probe_mac_grp  = u_dut.u_accel.u_mac_array.mac_co_grp_out;
wire        probe_mac_last = u_dut.u_accel.u_mac_array.mac_is_last_ci_out;
// 8行 * 16通道 * 19bit = 2432 bit 
wire [2431:0] probe_mac_psum = u_dut.u_accel.u_mac_array.psum_out; 

// 2. 将 2432-bit 彻底展开为 [像素 p=0~7][通道 ch=0~15] 的二维数组，位宽 19-bit
logic signed [18:0] wave_mac_psum [0:7][0:15];

always_comb begin
    for (int p = 0; p < 8; p++) begin
        for (int c = 0; c < 16; c++) begin
            // 按照 [r * (TK_OUT*OUT_W) +: (TK_OUT*OUT_W)] 的底层拼接规则切片[cite: 1]
            wave_mac_psum[p][c] = $signed(probe_mac_psum[(p * 16 + c) * 19 +: 19]);
        end
    end
end

// 3. 独立的 MAC 坐标追踪器
int mac_tr_w_blk = 0;
int mac_tr_co_grp = 0;
int mac_tr_h = 0;

always @(posedge clk) begin
    // 必须等待 is_last_ci_out 为 1，才是累加完成的最终有效值[cite: 1]
    if (probe_mac_vld && probe_mac_last) begin
        
        // 抓取并打印 H=0, W=19 所在块 (W_blk=2) 的时刻
        if (mac_tr_h == 0 && mac_tr_w_blk == 2 && mac_tr_co_grp == 0) begin
            $display("\n>>> [MAC Array] 捕获到 H:0, W:16~23 原始乘加输出 (对比 W=18 和 W=19):");
            for (int c = 0; c < 16; c++) begin
                $display("    [W=18(P=2), C=%0d] = %0d  |  [W=19(P=3), C=%0d] = %0d", 
                        c, wave_mac_psum[2][c], c, wave_mac_psum[3][c]);
            end
            $display("---------------------------------------------------------------");
        end

        // --- MAC 状态机步进 ---
        mac_tr_w_blk++;
        if (mac_tr_w_blk == W_out_blocks) begin
            mac_tr_w_blk = 0;
            mac_tr_co_grp++;
            if (mac_tr_co_grp == CO_groups) begin
                mac_tr_co_grp = 0;
                mac_tr_h++;
            end
        end
    end
end

// ==========================================
// CBUF 输出特征图拆解探针 (针对 512-bit features_in)
// ==========================================
// 提取 8 个并行的像素值 (每个像素取其第 0 个通道作为代表)
logic signed [7:0] features_view [0:7];

always_comb begin
    for (int i = 0; i < 8; i++) begin
        // 每个像素占 64-bit，取该像素最低 8-bit (即 Channel 0)
        features_view[i] = $signed(u_dut.u_accel.u_mac_array.features_in[i*64 +: 8]);
    end
end
endmodule