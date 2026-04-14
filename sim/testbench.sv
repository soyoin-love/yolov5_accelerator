`timescale 1ns / 1ps

`include "../defines.vh"

module testbench;

// =========================================================================
// 仿真顶层
// 负责例化 DUT、AXI 从内存模型，以及组织算子级回归任务。
// =========================================================================
reg         clk;
reg         rst_n;
reg         cfg_req = 0;
reg  [7:0]  cfg_addr;
reg  [31:0] cfg_wdata;
wire        cfg_ack;

wire        ap_done;
wire        ap_idle;
// =========================================================================
// 统一测试参数配置区
// 后续修改各算子测试尺寸、通道数、卷积参数时，只需要改这里。
// tasks_ops.svh 中的 task 会直接读取这些顶层变量。
// =========================================================================

// 卷积算子验证参数
int TB_CONV_IN_W        = 7;
int TB_CONV_IN_H        = 6;
int TB_CONV_IN_C        = 11;
int TB_CONV_OUT_C       = 13;
int TB_CONV_KX          = 3;
int TB_CONV_KY          = 3;
int TB_CONV_SX          = 1;
int TB_CONV_SY          = 1;
int TB_CONV_PX          = 1;
int TB_CONV_PY          = 1;
int TB_CONV_IFM_PATTERN = 4;
// 1: 由软件侧按 co_grp<=4 自动开启 resident 模式；0: 始终关闭。
bit TB_AUTO_WT_RESIDENT_EN = 1'b1;

// 池化算子验证参数
int TB_POOL_W           = 100;
int TB_POOL_H           = 100;
int TB_POOL_C           = 16;
int TB_POOL_IFM_PATTERN = 0;
// 上采样算子验证参数
int TB_UP_SRC_W         = 40;
int TB_UP_SRC_H         = 40;
int TB_UP_C             = 8;
int TB_UP_IFM_PATTERN   = 1;


// Concat 算子验证参数
int TB_CAT_W            = 40;
int TB_CAT_H            = 40;
int TB_CAT_SRC0_C       = 8;
int TB_CAT_SRC1_C       = 8;
int TB_CAT_SRC0_PATTERN = 0;
int TB_CAT_SRC1_PATTERN = 1;

// Upsample + Concat 联合验证参数
int TB_UPCAT_SRC0_W       = 40;
int TB_UPCAT_SRC0_H       = 40;
int TB_UPCAT_SRC0_C       = 40;
int TB_UPCAT_SRC1_C       = 40;
int TB_UPCAT_SRC0_PATTERN = 2;
int TB_UPCAT_SRC1_PATTERN = 1;

// 残差算子验证参数
int TB_RESADD_W            = 60;
int TB_RESADD_H            = 60;
int TB_RESADD_C            = 16;
int TB_RESADD_SRC0_PATTERN = 2;
int TB_RESADD_SRC1_PATTERN = 3;

    // 这组参数供旧版卷积验证流程使用。
    int Win = 80, Hin = 80, CHin = 3, CHout = 16;
    int Kx = 6, Ky = 6, Sx = 2, Sy = 2, Px = 2, Py = 2;

    bit relu_en = 1;

    int Wout, Hout;

    // DDR 空间划分，供不同输入/输出与辅助张量使用。
    logic [31:0] IFM_BASE  = 32'h0000_0000;
    logic [31:0] WT_BASE   = 32'h0002_0000;
    logic [31:0] BIAS_BASE = 32'h0004_0000;
    logic [31:0] OFM_BASE  = 32'h0006_0000;
    logic [31:0] AUX_BASE  = 32'h0008_0000;
    logic [31:0] RES_BASE  = 32'h000A_0000;


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
// 软件参考模型数组
// tasks.svh 与 tasks_ops.svh 会直接使用这些全局数组。
// =========================================================================
logic signed [7:0]  ref_ifm    [0:127][0:127][0:127]; //[hi][wi][ic]
logic signed [7:0]  ref_ifm_aux[0:127][0:127][0:127]; //[hi][wi][ic]
logic signed [7:0]  ref_wt    [0:127][0:127][0:7][0:7];  //[oc][ic][ky][kx]
logic signed [63:0] ref_bias  [0:127]; //1*1*[oc]
logic signed [17:0] ref_scale [0:127]; //1*1*[oc]
logic [7:0]         ref_shift [0:127]; //1*1*[oc]
logic signed [7:0]  ref_ofm   [0:127][0:127][0:127];  //[oc][wi][ic]

// 先 include 基础任务，再 include 算子级任务。
`include "tasks.svh"
`include "tasks_csc_stream_debug.svh"
`include "tasks_ops.svh"

// =========================================================================
// Pool 内部大数组调试映射
// 这些信号只存在于 testbench 中，便于在 ModelSim 中直接观察：
// 1. Reg_A / Reg_B 每个像素的 64bit 原始值
// 2. Reg_A / Reg_B 每个像素内 8 个通道的 8bit 值
// 3. Col_Max_Reg / Row_Max_Wire 的像素与通道拆分
// 这样无需在源模块里增加额外调试逻辑，也不会影响综合结果。
// =========================================================================
logic [63:0] tb_pool_reg_a_pix   [0:4][0:7];
logic [63:0] tb_pool_reg_b_pix   [0:4][0:7];
logic [7:0]  tb_pool_reg_a_val   [0:4][0:7][0:7];
logic [7:0]  tb_pool_reg_b_val   [0:4][0:7][0:7];
logic [63:0] tb_pool_col_max_pix [0:11];
logic [7:0]  tb_pool_col_max_val [0:11][0:7];
logic [63:0] tb_pool_row_max_pix [0:7];
logic [7:0]  tb_pool_row_max_val [0:7][0:7];

genvar tb_pool_dbg_r;
genvar tb_pool_dbg_c;
genvar tb_pool_dbg_ch;
genvar tb_pool_dbg_idx;
generate
    for (tb_pool_dbg_r = 0; tb_pool_dbg_r < 5; tb_pool_dbg_r = tb_pool_dbg_r + 1) begin : TB_POOL_DBG_ROW
        for (tb_pool_dbg_c = 0; tb_pool_dbg_c < 8; tb_pool_dbg_c = tb_pool_dbg_c + 1) begin : TB_POOL_DBG_COL
            assign tb_pool_reg_a_pix[tb_pool_dbg_r][tb_pool_dbg_c] =
                u_dut.u_accel.u_pool.Reg_A[tb_pool_dbg_r][tb_pool_dbg_c];
            assign tb_pool_reg_b_pix[tb_pool_dbg_r][tb_pool_dbg_c] =
                u_dut.u_accel.u_pool.Reg_B[tb_pool_dbg_r][tb_pool_dbg_c];

            for (tb_pool_dbg_ch = 0; tb_pool_dbg_ch < 8; tb_pool_dbg_ch = tb_pool_dbg_ch + 1) begin : TB_POOL_DBG_CH
                assign tb_pool_reg_a_val[tb_pool_dbg_r][tb_pool_dbg_c][tb_pool_dbg_ch] =
                    u_dut.u_accel.u_pool.Reg_A[tb_pool_dbg_r][tb_pool_dbg_c][tb_pool_dbg_ch*8 +: 8];
                assign tb_pool_reg_b_val[tb_pool_dbg_r][tb_pool_dbg_c][tb_pool_dbg_ch] =
                    u_dut.u_accel.u_pool.Reg_B[tb_pool_dbg_r][tb_pool_dbg_c][tb_pool_dbg_ch*8 +: 8];
            end
        end
    end

    for (tb_pool_dbg_idx = 0; tb_pool_dbg_idx < 12; tb_pool_dbg_idx = tb_pool_dbg_idx + 1) begin : TB_POOL_DBG_COLMAX
        assign tb_pool_col_max_pix[tb_pool_dbg_idx] =
            u_dut.u_accel.u_pool.Col_Max_Reg[tb_pool_dbg_idx];

        for (tb_pool_dbg_ch = 0; tb_pool_dbg_ch < 8; tb_pool_dbg_ch = tb_pool_dbg_ch + 1) begin : TB_POOL_DBG_COLMAX_CH
            assign tb_pool_col_max_val[tb_pool_dbg_idx][tb_pool_dbg_ch] =
                u_dut.u_accel.u_pool.Col_Max_Reg[tb_pool_dbg_idx][tb_pool_dbg_ch*8 +: 8];
        end
    end

    for (tb_pool_dbg_idx = 0; tb_pool_dbg_idx < 8; tb_pool_dbg_idx = tb_pool_dbg_idx + 1) begin : TB_POOL_DBG_ROWMAX
        assign tb_pool_row_max_pix[tb_pool_dbg_idx] =
            u_dut.u_accel.u_pool.Row_Max_Wire[tb_pool_dbg_idx];

        for (tb_pool_dbg_ch = 0; tb_pool_dbg_ch < 8; tb_pool_dbg_ch = tb_pool_dbg_ch + 1) begin : TB_POOL_DBG_ROWMAX_CH
            assign tb_pool_row_max_val[tb_pool_dbg_idx][tb_pool_dbg_ch] =
                u_dut.u_accel.u_pool.Row_Max_Wire[tb_pool_dbg_idx][tb_pool_dbg_ch*8 +: 8];
        end
    end
endgenerate

// =========================================================================
// AXI 从内存初始化
// 每次仿真启动时先把 memory[] 清零，避免脏数据影响结果。
// =========================================================================
initial begin
    for (int i = 0; i < `MEM_SIZE; i++) begin
        u_AXI_HP_Slave.memory[i] = 0;
    end
end

always #5 clk = ~clk;

// =========================================================================
// 旧版卷积验证入口
// 目前默认关闭，仅在需要单独回归历史卷积流程时打开。
// =========================================================================
initial if (1'b0) begin



    clk = 0;
    rst_n = 0;
    cfg_req = 0;
    cfg_addr = 0;
    cfg_wdata = 0;


    Wout = (Win - Kx + 2 * Px) / Sx + 1;
    Hout = (Hin - Ky + 2 * Py) / Sy + 1;

    #101;
    rst_n = 1;
    #100;

    $display("\n=======================================================");
    $display(">>> YOLO 硬件加速器验证启动 (Layer: %0dx%0d_%0dc -> %0dx%0d_%0dc)", Hin, Win, CHin, Hout, Wout, CHout);
    $display("=======================================================\n");



    generate_random_ifm(IFM_BASE, Win, Hin, CHin);



    load_weights("E:/IEEE2026/yolov5-7.0/yolov5-7.0/fpga_bin_export/weights_txt/model_0_conv_weights.txt", WT_BASE, CHout, CHin, Ky, Kx);
    load_params("E:/IEEE2026/yolov5-7.0/yolov5-7.0/fpga_bin_export/params_txt/model_0_conv_params.txt", BIAS_BASE, CHout);



    simulate_conv_layer(Win, Hin, CHin, CHout, Kx, Ky, Sx, Sy, Px, Py, relu_en);



    load_config_and_run("E:/IEEE2026/yolov5-7.0/yolo_quant/layer1_config.txt");


    $display("=== [Testbench] 等待硬件计算结束 (ap_done) ===");

    wait(ap_done == 1'b1);
    $display("=== [Testbench] 硬件计算完成，结束时刻: %0t ===", $time);



    #500;



    compare_results(OFM_BASE, Wout, Hout, CHout);


    #200;
    $finish;
end

initial begin
    clk = 0;
    rst_n = 0;
    cfg_req = 0;
    cfg_addr = 0;
    cfg_wdata = 0;

    $display("\n=======================================================");
    $display(">>> YOLO 算子级验证启动: Conv / Pool / Upsample / Concat / ResAdd");
    $display("=======================================================\n");

    run_operator_regression();

    #200;
    $finish;
end

// =========================================================================
// DUT 与 AXI 从设备例化
// DUT 通过 AXI 主口访问 AXI_HP_Slave 中的 memory[]。
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


endmodule
