`timescale 1ns / 1ps

module bbuf_dat_top #(
    parameter BANK_NUM   = 8,
    parameter DATA_WIDTH = 64,   // 包含: {11'd0, shift[7:0], scale[17:0], bias[26:0]}
    parameter ADDR_WIDTH = 9     // 深度 512，最大支持 512 * 8 = 4096 个输出通道
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // ==========================================
    // 1. 写接口 (由 B_CDMA 驱动)
    // ==========================================
    // 采用掩码写入，完美兼容非 8 倍数输出通道，防止脏数据覆盖
    input  wire [BANK_NUM-1:0]    b_cdma_wr_en,
    input  wire [ADDR_WIDTH-1:0]  b_cdma_wr_addr,
    input  wire [BANK_NUM*64-1:0] b_cdma_wr_dat, 

    // ==========================================
    // 2. 读接口 (由 CACC 预取模块驱动)
    // ==========================================
    // 为节省功耗，读使能同样支持 Bank 独立掩码控制
    input  wire [BANK_NUM-1:0]    cacc_rd_en,
    input  wire [ADDR_WIDTH-1:0]  cacc_rd_addr,
    output wire                   cacc_rd_vld,
    output wire [BANK_NUM*64-1:0] cacc_rd_dat
);

    reg [BANK_NUM-1:0] bank_rd_vld;

    // genvar b;
    // generate
    //     for (b = 0; b < BANK_NUM; b = b + 1) begin : BBUF_BANKS
    //         generic_buf #(
    //             .DATA_WIDTH (DATA_WIDTH),
    //             .ADDR_WIDTH (ADDR_WIDTH),
    //             .RAM_STYLE  ("block") // 综合工具会自动映射为一个 RAM36E2
    //         ) u_bank (
    //             .clk        (clk),
    //             .rst_n      (rst_n),
                
    //             .wr_en      (b_cdma_wr_en[b]),
    //             .wr_addr    (b_cdma_wr_addr),
    //             .wr_dat     (b_cdma_wr_dat[b * DATA_WIDTH +: DATA_WIDTH]),
                
    //             .rd_en      (cacc_rd_en[b]),
    //             .rd_addr    (cacc_rd_addr),
    //             .rd_dat_vld (bank_rd_vld[b]),
    //             .rd_dat     (cacc_rd_dat[b * DATA_WIDTH +: DATA_WIDTH])
    //         );
    //     end
    // endgenerate

    genvar b;
generate
    for (b = 0; b < BANK_NUM; b = b + 1) begin : BBUF_BANKS
        
        // 1. 实例化 Xilinx BRAM IP (bbuf)
        bbuf u_bank (
            // 写端口 (Port A)
            .clka  (clk),
            .ena   (1'b1),                                 // 使能常开，由 wea 控制写入
            .wea   (b_cdma_wr_en[b]),                      // 写使能
            .addra (b_cdma_wr_addr),                       // 写地址
            .dina  (b_cdma_wr_dat[b * DATA_WIDTH +: DATA_WIDTH]), // 写数据切片

            // 读端口 (Port B)
            .clkb  (clk),
            .enb   (cacc_rd_en[b]),                        // 读使能
            .addrb (cacc_rd_addr),                         // 读地址
            .doutb (cacc_rd_dat[b * DATA_WIDTH +: DATA_WIDTH])  // 读数据切片输出
        );

        // 2. 手动对齐读有效信号 (bank_rd_vld)
        // BRAM 默认有 1 拍读取延迟，所以有效信号需随 cacc_rd_en 打一拍
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n)
                bank_rd_vld[b] <= 1'b0;
            else
                bank_rd_vld[b] <= cacc_rd_en[b];
        end

    end
endgenerate

    // 任一 Bank 响应即代表当前节拍读数据有效
    assign cacc_rd_vld = (|bank_rd_vld);

endmodule