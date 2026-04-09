`timescale 1ns / 1ps

module yolo_sim_top #(
    // AXI 物理参数，与内部一致
    parameter C_M_AXI_ID_WIDTH    = 2,
    parameter AXI_DATA_WIDTH      = 128,
    parameter CBUF_ADDR_W         = 10
)(
    input  wire                               clk,
    input  wire                               rst_n,

    // ==========================================
    // 1. 极简配置总线 (Simple Configuration Bus)
    // ==========================================
    input  wire                               cfg_req,   // 主机发起写请求
    input  wire [7:0]                         cfg_addr,  // 寄存器地址
    input  wire [31:0]                        cfg_wdata, // 写入的数据
    output reg                                cfg_ack,   // 从机写完成应答

    // 状态机反馈引脚
    output wire                               ap_done,
    output wire                               ap_idle,

    // ==========================================
    // 2. AXI4 Master 接口 (直连 Testbench 中的 DDR 模型)
    // ==========================================
    output wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_AWID,
    output wire [31:0]                        M_AXI_AWADDR,
    output wire [7:0]                         M_AXI_AWLEN,
    output wire [2:0]                         M_AXI_AWSIZE,
    output wire [1:0]                         M_AXI_AWBURST,
    output wire                               M_AXI_AWLOCK,
    output wire [3:0]                         M_AXI_AWCACHE,
    output wire [2:0]                         M_AXI_AWPROT,
    output wire [3:0]                         M_AXI_AWQOS,
    output wire                               M_AXI_AWVALID,
    input  wire                               M_AXI_AWREADY,
    
    output wire [AXI_DATA_WIDTH-1:0]          M_AXI_WDATA,
    output wire [AXI_DATA_WIDTH/8-1:0]        M_AXI_WSTRB,
    output wire                               M_AXI_WLAST,
    output wire                               M_AXI_WVALID,
    input  wire                               M_AXI_WREADY,
    
    input  wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_BID,
    input  wire [1:0]                         M_AXI_BRESP,
    input  wire                               M_AXI_BVALID,
    output wire                               M_AXI_BREADY,
    
    output wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_ARID,
    output wire [31:0]                        M_AXI_ARADDR,
    output wire [7:0]                         M_AXI_ARLEN,
    output wire [2:0]                         M_AXI_ARSIZE,
    output wire [1:0]                         M_AXI_ARBURST,
    output wire                               M_AXI_ARLOCK,
    output wire [3:0]                         M_AXI_ARCACHE,
    output wire [2:0]                         M_AXI_ARPROT,
    output wire [3:0]                         M_AXI_ARQOS,
    output wire                               M_AXI_ARVALID,
    input  wire                               M_AXI_ARREADY,
    
    input  wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_RID,
    input  wire [AXI_DATA_WIDTH-1:0]          M_AXI_RDATA,
    input  wire [1:0]                         M_AXI_RRESP,
    input  wire                               M_AXI_RLAST,
    input  wire                               M_AXI_RVALID,
    output wire                               M_AXI_RREADY
);

    // =========================================================================
    // 内部控制与握手线网
    // =========================================================================
    reg         ap_start;
    wire        w_cdma_start, f_cdma_start, b_cdma_start, buf_start;
    wire        csc_start, cacc_start, pool_start, r_cdma_start, rbuf_start, resadd_start, obuf_start, wdma_start;
    
    wire        w_cdma_done, b_cdma_done, csc_row_done, wdma_done;

    // =========================================================================
    // 内部配置寄存器组 (CSR)
    // =========================================================================
    reg [31:0]  cfg_f_base_addr, cfg_wt_base_addr, cfg_b_base_addr, cfg_wdma_base_addr, cfg_res_base_addr;
    reg [15:0]  cfg_f_width, cfg_f_height, cfg_csc_w_in, cfg_csc_h_in;
    reg [15:0]  cfg_csc_w_out, cfg_h_out, cfg_f_ch_groups, cfg_b_out_channels;
    reg [3:0]   cfg_csc_pad_up, cfg_csc_pad_left, cfg_csc_ky, cfg_csc_kx;
    reg [3:0]   cfg_csc_stride_y, cfg_csc_stride_x, cfg_wt_active_banks;
    reg         cfg_wt_is_odd_oc;
    reg [15:0]  cfg_csc_w_out_blocks, cfg_wt_coords_per_region;
    reg [CBUF_ADDR_W-1:0] cfg_buf_max_ch_groups, cfg_buf_max_col_blocks;
    reg [3:0]   cfg_buf_min_calc_rows;
    reg [27:0]  cfg_wt_total_beats;
    //reg [15:0]  cfg_wdma_total_cols, cfg_wdma_total_rows;
    reg         cfg_cacc_relu_en;
    reg [15:0]  cfg_cacc_b_total_beats;
    reg [15:0]  cfg_csc_co_groups, cfg_csc_ci_groups, cfg_wt_total_co_groups;
    reg [15:0]  cfg_out_ch_grps;
    reg [1:0]   cfg_op_mode;
    reg         cfg_pool_pad_zero;
    reg         cfg_resadd_relu_en;

    // 极简 CSR 写入逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ap_start <= 1'b0;
            cfg_ack  <= 1'b0;
            
            // 复位寄存器至安全默认值 (可根据需要修改)
            cfg_f_base_addr <= 0; cfg_wt_base_addr <= 0; cfg_b_base_addr <= 0; cfg_wdma_base_addr <= 0; cfg_res_base_addr <= 0;
            cfg_f_width <= 0; cfg_f_height <= 0; cfg_csc_w_in <= 0; cfg_csc_h_in <= 0;
            cfg_csc_w_out <= 0; cfg_h_out <= 0; cfg_f_ch_groups <= 0; cfg_b_out_channels <= 0;
            cfg_csc_pad_up <= 0; cfg_csc_pad_left <= 0; cfg_csc_ky <= 0; cfg_csc_kx <= 0;
            cfg_csc_stride_y <= 0; cfg_csc_stride_x <= 0; cfg_wt_active_banks <= 0; cfg_wt_is_odd_oc <= 0;
            cfg_csc_w_out_blocks <= 0; cfg_wt_coords_per_region <= 0;
            cfg_buf_max_ch_groups <= 0; cfg_buf_max_col_blocks <= 0; cfg_buf_min_calc_rows <= 0;
            cfg_wt_total_beats <= 0; //cfg_wdma_total_cols <= 0; cfg_wdma_total_rows <= 0;
            cfg_cacc_relu_en <= 0; cfg_cacc_b_total_beats <= 0;
            cfg_csc_co_groups <= 0; cfg_csc_ci_groups <= 0; cfg_wt_total_co_groups <= 0;
            cfg_out_ch_grps <= 0;
            cfg_op_mode <= 2'd0; cfg_pool_pad_zero <= 1'b0; cfg_resadd_relu_en <= 1'b0;
        end else begin
            ap_start <= 1'b0; // 保证 start 仅维持一拍脉冲
            
            if (cfg_req && !cfg_ack) begin
                cfg_ack <= 1'b1;
                case (cfg_addr)
                    8'h00: ap_start                   <= cfg_wdata[0];
                    8'h10: cfg_f_base_addr            <= cfg_wdata;
                    8'h14: cfg_wt_base_addr           <= cfg_wdata;
                    8'h18: cfg_b_base_addr            <= cfg_wdata;
                    8'h1C: cfg_wdma_base_addr         <= cfg_wdata;
                    8'h20: {cfg_f_width, cfg_f_height} <= cfg_wdata;
                    8'h24: {cfg_csc_w_in, cfg_csc_h_in} <= cfg_wdata;
                    8'h28: {cfg_csc_w_out, cfg_h_out}  <= cfg_wdata;
                    8'h2C: {cfg_f_ch_groups, cfg_b_out_channels} <= cfg_wdata;
                    8'h30: {cfg_csc_pad_up, cfg_csc_pad_left, cfg_csc_ky, cfg_csc_kx} <= cfg_wdata[15:0];
                    8'h34: {cfg_csc_stride_y, cfg_csc_stride_x, cfg_wt_active_banks, cfg_wt_is_odd_oc} <= {cfg_wdata[12:1], cfg_wdata[0]};
                    8'h38: {cfg_csc_w_out_blocks, cfg_wt_coords_per_region} <= cfg_wdata;
                    8'h3C: {cfg_buf_max_ch_groups, cfg_buf_max_col_blocks} <= {cfg_wdata[25:16], cfg_wdata[9:0]};
                    8'h3E: cfg_buf_min_calc_rows      <= cfg_wdata[3:0]; // 拆分地址降低打包复杂度
                    8'h40: cfg_wt_total_beats         <= cfg_wdata[27:0];
                    //8'h44: {cfg_wdma_total_cols, cfg_wdma_total_rows} <= cfg_wdata;
                    8'h48: {cfg_cacc_relu_en, cfg_cacc_b_total_beats} <= {cfg_wdata[16], cfg_wdata[15:0]};
                    8'h4C: {cfg_csc_co_groups, cfg_csc_ci_groups} <= cfg_wdata;
                    8'h50: {cfg_wt_total_co_groups,cfg_out_ch_grps}     <= cfg_wdata;
                    8'h54: begin
                        cfg_op_mode        <= cfg_wdata[1:0]; // 0: conv, 1: pool, 2: residual add
                        cfg_pool_pad_zero  <= cfg_wdata[2];
                        cfg_resadd_relu_en <= cfg_wdata[3];
                    end
                    8'h58: cfg_res_base_addr         <= cfg_wdata;
                endcase
            end else if (!cfg_req) begin
                cfg_ack <= 1'b0;
            end
        end
    end

    // =========================================================================
    // 3. 全局状态机例化 (Global FSM)
    // =========================================================================
    yolo_global_fsm u_fsm (
        .clk              (clk),
        .rst_n            (rst_n),
        .ap_start         (ap_start),
        .ap_done          (ap_done),
        .ap_idle          (ap_idle),
        .cfg_h_out        (cfg_h_out),
        .cfg_op_mode      (cfg_op_mode),

        // Start Outputs
        .w_cdma_start     (w_cdma_start),
        .f_cdma_start     (f_cdma_start),
        .b_cdma_start     (b_cdma_start),
        .buf_start        (buf_start),
        .csc_start        (csc_start),
        .cacc_start       (cacc_start),
        .pool_start       (pool_start),
        .r_cdma_start     (r_cdma_start),
        .rbuf_start       (rbuf_start),
        .resadd_start     (resadd_start),
        .obuf_start       (obuf_start),
        .wdma_start       (wdma_start),

        // Done Inputs
        .w_cdma_done      (w_cdma_done),
        .b_cdma_done      (b_cdma_done),
        .csc_row_done     (csc_row_done),
        .wdma_done        (wdma_done)
    );

    // =========================================================================
    // 4. 数据通路顶层例化 (yolo_accel_top)
    // =========================================================================
    yolo_accel_top u_accel (
        .clk                      (clk),
        .rst_n                    (rst_n),

        // 启动与反馈
        .w_cdma_start             (w_cdma_start),
        .f_cdma_start             (f_cdma_start),
        .b_cdma_start             (b_cdma_start),
        .buf_start                (buf_start),
        .csc_start                (csc_start),
        .cacc_start               (cacc_start),
        .pool_start               (pool_start),
        .r_cdma_start             (r_cdma_start),
        .rbuf_start               (rbuf_start),
        .resadd_start             (resadd_start),
        .obuf_start               (obuf_start),
        .wdma_start               (wdma_start),
        .w_cdma_done              (w_cdma_done),
        .b_cdma_done              (b_cdma_done),
        .csc_row_done             (csc_row_done), // 【确认】需保证 yolo_accel_top 输出此引脚
        .wdma_done                (wdma_done),    // 【确认】需保证 yolo_accel_top 输出此引脚

        // 配置寄存器连线
        .cfg_wt_total_beats       (cfg_wt_total_beats),
        .cfg_wt_base_addr         (cfg_wt_base_addr),
        .cfg_wt_total_co_groups   (cfg_wt_total_co_groups),
        .cfg_wt_coords_per_region (cfg_wt_coords_per_region),
        .cfg_wt_active_banks      (cfg_wt_active_banks),
        .cfg_wt_is_odd_oc         (cfg_wt_is_odd_oc),
        
        .cfg_f_base_addr          (cfg_f_base_addr),
        .cfg_f_width              (cfg_f_width),
        .cfg_f_height             (cfg_f_height),
        .cfg_f_ch_groups          (cfg_f_ch_groups),
        
        .cfg_b_base_addr          (cfg_b_base_addr),
        .cfg_b_out_channels       (cfg_b_out_channels),
        .cfg_buf_max_col_blocks   (cfg_buf_max_col_blocks),
        .cfg_buf_max_ch_groups    (cfg_buf_max_ch_groups),
        .cfg_buf_min_calc_rows    (cfg_buf_min_calc_rows),
        
        .cfg_csc_w_out            (cfg_csc_w_out),
        .cfg_csc_w_out_blocks     (cfg_csc_w_out_blocks),
        .cfg_csc_h_out            (cfg_h_out),
        .cfg_csc_w_in             (cfg_csc_w_in),
        .cfg_csc_h_in             (cfg_csc_h_in),
        .cfg_csc_co_groups        (cfg_csc_co_groups),
        .cfg_csc_ci_groups        (cfg_csc_ci_groups),
        .cfg_csc_kx               (cfg_csc_kx),
        .cfg_csc_ky               (cfg_csc_ky),
        .cfg_csc_stride_x         (cfg_csc_stride_x),
        .cfg_csc_stride_y         (cfg_csc_stride_y),
        .cfg_csc_pad_left         (cfg_csc_pad_left),
        .cfg_csc_pad_up           (cfg_csc_pad_up),
        .cfg_csc_active_banks     (cfg_wt_active_banks), // 与权重複用
        
        .cfg_cacc_b_total_beats   (cfg_cacc_b_total_beats),
        .cfg_cacc_relu_en         (cfg_cacc_relu_en),
        
        .cfg_wdma_base_addr       (cfg_wdma_base_addr),
        .cfg_out_ch_groups        (cfg_out_ch_grps),
        .cfg_op_mode              (cfg_op_mode),
        .cfg_pool_pad_zero        (cfg_pool_pad_zero),
        .cfg_res_base_addr        (cfg_res_base_addr),
        .cfg_resadd_relu_en       (cfg_resadd_relu_en),
        // .cfg_wdma_total_cols      (cfg_wdma_total_cols),
        // .cfg_wdma_total_rows      (cfg_wdma_total_rows),

        // AXI4 Master 总线直通 Testbench
        .M_AXI_AWID(M_AXI_AWID), .M_AXI_AWADDR(M_AXI_AWADDR), .M_AXI_AWLEN(M_AXI_AWLEN),
        .M_AXI_AWSIZE(M_AXI_AWSIZE), .M_AXI_AWBURST(M_AXI_AWBURST), .M_AXI_AWLOCK(M_AXI_AWLOCK),
        .M_AXI_AWCACHE(M_AXI_AWCACHE), .M_AXI_AWPROT(M_AXI_AWPROT), .M_AXI_AWQOS(M_AXI_AWQOS),
        .M_AXI_AWVALID(M_AXI_AWVALID), .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA), .M_AXI_WSTRB(M_AXI_WSTRB), .M_AXI_WLAST(M_AXI_WLAST),
        .M_AXI_WVALID(M_AXI_WVALID), .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BID(M_AXI_BID), .M_AXI_BRESP(M_AXI_BRESP), .M_AXI_BVALID(M_AXI_BVALID), .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARID(M_AXI_ARID), .M_AXI_ARADDR(M_AXI_ARADDR), .M_AXI_ARLEN(M_AXI_ARLEN),
        .M_AXI_ARSIZE(M_AXI_ARSIZE), .M_AXI_ARBURST(M_AXI_ARBURST), .M_AXI_ARLOCK(M_AXI_ARLOCK),
        .M_AXI_ARCACHE(M_AXI_ARCACHE), .M_AXI_ARPROT(M_AXI_ARPROT), .M_AXI_ARQOS(M_AXI_ARQOS),
        .M_AXI_ARVALID(M_AXI_ARVALID), .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RID(M_AXI_RID), .M_AXI_RDATA(M_AXI_RDATA), .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RLAST(M_AXI_RLAST), .M_AXI_RVALID(M_AXI_RVALID), .M_AXI_RREADY(M_AXI_RREADY)
    );

endmodule
