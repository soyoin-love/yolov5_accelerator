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

    wire [BANK_NUM-1:0] bank_rd_vld;

    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : BBUF_BANKS
            generic_buf #(
                .DATA_WIDTH (DATA_WIDTH),
                .ADDR_WIDTH (ADDR_WIDTH),
                .RAM_STYLE  ("block") // 综合工具会自动映射为一个 RAM36E2
            ) u_bank (
                .clk        (clk),
                .rst_n      (rst_n),
                
                .wr_en      (b_cdma_wr_en[b]),
                .wr_addr    (b_cdma_wr_addr),
                .wr_dat     (b_cdma_wr_dat[b * DATA_WIDTH +: DATA_WIDTH]),
                
                .rd_en      (cacc_rd_en[b]),
                .rd_addr    (cacc_rd_addr),
                .rd_dat_vld (bank_rd_vld[b]),
                .rd_dat     (cacc_rd_dat[b * DATA_WIDTH +: DATA_WIDTH])
            );
        end
    endgenerate

    // 任一 Bank 响应即代表当前节拍读数据有效
    assign cacc_rd_vld = (|bank_rd_vld);

endmodule