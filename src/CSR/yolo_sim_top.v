`timescale 1ns / 1ps

module yolo_sim_top #(
    parameter C_M_AXI_ID_WIDTH = 2,
    parameter AXI_DATA_WIDTH   = 128,
    parameter CBUF_ADDR_W      = 10
)(
    input  wire                               clk,
    input  wire                               rst_n,

    // 配置
    input  wire                               cfg_req,
    input  wire [7:0]                         cfg_addr,
    input  wire [31:0]                        cfg_wdata,
    output reg                                cfg_ack,

    output wire                               ap_done,
    output wire                               ap_idle,

    // AXI4 Master 
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


    wire        w_cdma_start, f_cdma_start, b_cdma_start, buf_start;
    wire        csc_start, cacc_start, pool_start, r_cdma_start, rbuf_start;
    wire        resadd_start, obuf_start, wdma_start;
    wire        w_cdma_done, b_cdma_done, csc_row_done, wdma_done;

    reg         ap_start;
    reg [31:0]  cfg_f_base_addr;
    reg [31:0]  cfg_wt_base_addr;
    reg [31:0]  cfg_b_base_addr;
    reg [31:0]  cfg_wdma_base_addr;
    reg [31:0]  cfg_res_base_addr;

    reg [15:0]  cfg_in_width;
    reg [15:0]  cfg_in_height;
    reg [15:0]  cfg_out_width;
    reg [15:0]  cfg_out_height;
    reg [15:0]  cfg_in_ch_groups;
    reg [15:0]  cfg_out_channels;

    reg         cfg_cat_en;
    reg         cfg_cat_src0_upsample;
    reg [31:0]  cfg_cat_src1_base_addr;
    reg [15:0]  cfg_cat_src0_ch_groups;
    reg [31:0]  cfg_cat_src0_line_stride;
    reg [31:0]  cfg_cat_src1_line_stride;
    reg [31:0]  cfg_cat_src0_surface_stride;
    reg [31:0]  cfg_cat_src1_surface_stride;

    reg [3:0]   cfg_csc_pad_up;
    reg [3:0]   cfg_csc_pad_left;
    reg [3:0]   cfg_csc_ky;
    reg [3:0]   cfg_csc_kx;
    reg [3:0]   cfg_csc_stride_y;
    reg [3:0]   cfg_csc_stride_x;
    reg [3:0]   cfg_wt_active_banks;
    reg         cfg_wt_is_odd_oc;
    reg [15:0]  cfg_wt_coords_per_region;
    reg [27:0]  cfg_wt_total_beats;

    reg         cfg_cacc_relu_en;
    reg [15:0]  cfg_cacc_b_total_beats;

    reg [1:0]   cfg_op_mode;
    reg         cfg_pool_pad_zero;
    reg         cfg_resadd_relu_en;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ap_start <= 1'b0;
            cfg_ack  <= 1'b0;

            cfg_f_base_addr <= 32'd0;
            cfg_wt_base_addr <= 32'd0;
            cfg_b_base_addr <= 32'd0;
            cfg_wdma_base_addr <= 32'd0;
            cfg_res_base_addr <= 32'd0;

            cfg_in_width <= 16'd0;
            cfg_in_height <= 16'd0;
            cfg_out_width <= 16'd0;
            cfg_out_height <= 16'd0;
            cfg_in_ch_groups <= 16'd0;
            cfg_out_channels <= 16'd0;

            cfg_cat_en <= 1'b0;
            cfg_cat_src0_upsample <= 1'b0;
            cfg_cat_src1_base_addr <= 32'd0;
            cfg_cat_src0_ch_groups <= 16'd0;
            cfg_cat_src0_line_stride <= 32'd0;
            cfg_cat_src1_line_stride <= 32'd0;
            cfg_cat_src0_surface_stride <= 32'd0;
            cfg_cat_src1_surface_stride <= 32'd0;

            cfg_csc_pad_up <= 4'd0;
            cfg_csc_pad_left <= 4'd0;
            cfg_csc_ky <= 4'd0;
            cfg_csc_kx <= 4'd0;
            cfg_csc_stride_y <= 4'd0;
            cfg_csc_stride_x <= 4'd0;
            cfg_wt_active_banks <= 4'd0;
            cfg_wt_is_odd_oc <= 1'b0;
            cfg_wt_coords_per_region <= 16'd0;
            cfg_wt_total_beats <= 28'd0;

            cfg_cacc_relu_en <= 1'b0;
            cfg_cacc_b_total_beats <= 16'd0;

            cfg_op_mode <= 2'd0;
            cfg_pool_pad_zero <= 1'b0;
            cfg_resadd_relu_en <= 1'b0;
        end else begin
            ap_start <= 1'b0;

            if (cfg_req && !cfg_ack) begin
                cfg_ack <= 1'b1;
                case (cfg_addr)
                    8'h00: ap_start <= cfg_wdata[0];

                    8'h10: cfg_f_base_addr <= cfg_wdata;
                    8'h14: cfg_wt_base_addr <= cfg_wdata;
                    8'h18: cfg_b_base_addr <= cfg_wdata;
                    8'h1C: cfg_wdma_base_addr <= cfg_wdata;

                    8'h20: cfg_res_base_addr <= cfg_wdata;
                    8'h24: {cfg_in_width, cfg_in_height} <= cfg_wdata;
                    8'h28: {cfg_out_width, cfg_out_height} <= cfg_wdata;
                    8'h2C: {cfg_in_ch_groups, cfg_out_channels} <= cfg_wdata;

                    8'h30: {cfg_csc_pad_up, cfg_csc_pad_left, cfg_csc_ky, cfg_csc_kx} <= cfg_wdata[15:0];
                    8'h34: begin
                        cfg_csc_stride_y <= cfg_wdata[12:9];
                        cfg_csc_stride_x <= cfg_wdata[8:5];
                        cfg_wt_active_banks <= cfg_wdata[4:1];
                        cfg_wt_is_odd_oc <= cfg_wdata[0];
                    end
                    8'h38: cfg_wt_coords_per_region <= cfg_wdata[15:0];
                    8'h3C: cfg_wt_total_beats <= cfg_wdata[27:0];
                    8'h40: begin
                        cfg_cacc_relu_en <= cfg_wdata[16];
                        cfg_cacc_b_total_beats <= cfg_wdata[15:0];
                    end
                    8'h44: begin
                        cfg_op_mode <= cfg_wdata[1:0];
                        cfg_pool_pad_zero <= cfg_wdata[2];
                        cfg_resadd_relu_en <= cfg_wdata[3];
                    end
                    8'h48: cfg_cat_src1_base_addr <= cfg_wdata;

                    // virtual concat 閰嶇疆
                    8'h4C: begin
                        cfg_cat_src0_upsample <= cfg_wdata[17];
                        cfg_cat_en <= cfg_wdata[16];
                        cfg_cat_src0_ch_groups <= cfg_wdata[15:0];
                    end
                    8'h50: cfg_cat_src0_line_stride <= cfg_wdata;
                    8'h54: cfg_cat_src1_line_stride <= cfg_wdata;
                    8'h58: cfg_cat_src0_surface_stride <= cfg_wdata;
                    8'h5C: cfg_cat_src1_surface_stride <= cfg_wdata;

                    default: ;
                endcase
            end else if (!cfg_req) begin
                cfg_ack <= 1'b0;
            end
        end
    end

    // 鍏ㄥ眬鐘舵€佹満
    yolo_global_fsm u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .ap_start     (ap_start),
        .ap_done      (ap_done),
        .ap_idle      (ap_idle),
        .cfg_h_out    (cfg_out_height),
        .cfg_op_mode  (cfg_op_mode),
        .w_cdma_start (w_cdma_start),
        .f_cdma_start (f_cdma_start),
        .b_cdma_start (b_cdma_start),
        .buf_start    (buf_start),
        .csc_start    (csc_start),
        .cacc_start   (cacc_start),
        .pool_start   (pool_start),
        .r_cdma_start (r_cdma_start),
        .rbuf_start   (rbuf_start),
        .resadd_start (resadd_start),
        .obuf_start   (obuf_start),
        .wdma_start   (wdma_start),
        .w_cdma_done  (w_cdma_done),
        .b_cdma_done  (b_cdma_done),
        .csc_row_done (csc_row_done),
        .wdma_done    (wdma_done)
    );

    // 鏁版嵁閫氳矾椤跺眰
    yolo_accel_top u_accel (
        .clk                         (clk),
        .rst_n                       (rst_n),
        .w_cdma_start                (w_cdma_start),
        .f_cdma_start                (f_cdma_start),
        .b_cdma_start                (b_cdma_start),
        .buf_start                   (buf_start),
        .csc_start                   (csc_start),
        .cacc_start                  (cacc_start),
        .pool_start                  (pool_start),
        .r_cdma_start                (r_cdma_start),
        .rbuf_start                  (rbuf_start),
        .resadd_start                (resadd_start),
        .obuf_start                  (obuf_start),
        .wdma_start                  (wdma_start),
        .w_cdma_done                 (w_cdma_done),
        .b_cdma_done                 (b_cdma_done),
        .csc_row_done                (csc_row_done),
        .wdma_done                   (wdma_done),

        .cfg_wt_total_beats          (cfg_wt_total_beats),
        .cfg_wt_base_addr            (cfg_wt_base_addr),
        .cfg_wt_coords_per_region    (cfg_wt_coords_per_region),
        .cfg_wt_active_banks         (cfg_wt_active_banks),
        .cfg_wt_is_odd_oc            (cfg_wt_is_odd_oc),

        .cfg_f_base_addr             (cfg_f_base_addr),
        .cfg_in_width                (cfg_in_width),
        .cfg_in_height               (cfg_in_height),
        .cfg_in_ch_groups            (cfg_in_ch_groups),
        .cfg_cat_en                  (cfg_cat_en),
        .cfg_cat_src0_upsample       (cfg_cat_src0_upsample),
        .cfg_cat_src1_base_addr      (cfg_cat_src1_base_addr),
        .cfg_cat_src0_ch_groups      (cfg_cat_src0_ch_groups),
        .cfg_cat_src0_line_stride    (cfg_cat_src0_line_stride),
        .cfg_cat_src1_line_stride    (cfg_cat_src1_line_stride),
        .cfg_cat_src0_surface_stride (cfg_cat_src0_surface_stride),
        .cfg_cat_src1_surface_stride (cfg_cat_src1_surface_stride),

        .cfg_b_base_addr             (cfg_b_base_addr),
        .cfg_out_channels            (cfg_out_channels),
        .cfg_out_width               (cfg_out_width),
        .cfg_out_height              (cfg_out_height),

        .cfg_csc_kx                  (cfg_csc_kx),
        .cfg_csc_ky                  (cfg_csc_ky),
        .cfg_csc_stride_x            (cfg_csc_stride_x),
        .cfg_csc_stride_y            (cfg_csc_stride_y),
        .cfg_csc_pad_left            (cfg_csc_pad_left),
        .cfg_csc_pad_up              (cfg_csc_pad_up),
        .cfg_csc_active_banks        (cfg_wt_active_banks),

        .cfg_cacc_b_total_beats      (cfg_cacc_b_total_beats),
        .cfg_cacc_relu_en            (cfg_cacc_relu_en),

        .cfg_wdma_base_addr          (cfg_wdma_base_addr),
        .cfg_res_base_addr           (cfg_res_base_addr),
        .cfg_op_mode                 (cfg_op_mode),
        .cfg_pool_pad_zero           (cfg_pool_pad_zero),
        .cfg_resadd_relu_en          (cfg_resadd_relu_en),

        .M_AXI_AWID                  (M_AXI_AWID),
        .M_AXI_AWADDR                (M_AXI_AWADDR),
        .M_AXI_AWLEN                 (M_AXI_AWLEN),
        .M_AXI_AWSIZE                (M_AXI_AWSIZE),
        .M_AXI_AWBURST               (M_AXI_AWBURST),
        .M_AXI_AWLOCK                (M_AXI_AWLOCK),
        .M_AXI_AWCACHE               (M_AXI_AWCACHE),
        .M_AXI_AWPROT                (M_AXI_AWPROT),
        .M_AXI_AWQOS                 (M_AXI_AWQOS),
        .M_AXI_AWVALID               (M_AXI_AWVALID),
        .M_AXI_AWREADY               (M_AXI_AWREADY),
        .M_AXI_WDATA                 (M_AXI_WDATA),
        .M_AXI_WSTRB                 (M_AXI_WSTRB),
        .M_AXI_WLAST                 (M_AXI_WLAST),
        .M_AXI_WVALID                (M_AXI_WVALID),
        .M_AXI_WREADY                (M_AXI_WREADY),
        .M_AXI_BID                   (M_AXI_BID),
        .M_AXI_BRESP                 (M_AXI_BRESP),
        .M_AXI_BVALID                (M_AXI_BVALID),
        .M_AXI_BREADY                (M_AXI_BREADY),
        .M_AXI_ARID                  (M_AXI_ARID),
        .M_AXI_ARADDR                (M_AXI_ARADDR),
        .M_AXI_ARLEN                 (M_AXI_ARLEN),
        .M_AXI_ARSIZE                (M_AXI_ARSIZE),
        .M_AXI_ARBURST               (M_AXI_ARBURST),
        .M_AXI_ARLOCK                (M_AXI_ARLOCK),
        .M_AXI_ARCACHE               (M_AXI_ARCACHE),
        .M_AXI_ARPROT                (M_AXI_ARPROT),
        .M_AXI_ARQOS                 (M_AXI_ARQOS),
        .M_AXI_ARVALID               (M_AXI_ARVALID),
        .M_AXI_ARREADY               (M_AXI_ARREADY),
        .M_AXI_RID                   (M_AXI_RID),
        .M_AXI_RDATA                 (M_AXI_RDATA),
        .M_AXI_RRESP                 (M_AXI_RRESP),
        .M_AXI_RLAST                 (M_AXI_RLAST),
        .M_AXI_RVALID                (M_AXI_RVALID),
        .M_AXI_RREADY                (M_AXI_RREADY)
    );

endmodule
