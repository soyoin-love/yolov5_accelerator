`timescale 1ns / 1ps

module generic_buf #(
    parameter DATA_WIDTH = 128,      // 数据位宽
    parameter ADDR_WIDTH = 10,       // 地址位宽（深度为 2^ADDR_WIDTH）
    parameter RAM_STYLE  = "block"   // 硬件实现风格："block" 或 "distributed"
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // 写端口 (Write Port)
    input  wire                   wr_en,
    input  wire [ADDR_WIDTH-1:0]  wr_addr,
    input  wire [DATA_WIDTH-1:0]  wr_dat,

    // 读端口 (Read Port)
    input  wire                   rd_en,
    input  wire [ADDR_WIDTH-1:0]  rd_addr,
    output reg                    rd_dat_vld, // 读有效信号，延迟 rd_en 一拍
    output wire [DATA_WIDTH-1:0]  rd_dat      // 读出的数据
);

    // 计算实际深度
    localparam DEPTH = 1 << ADDR_WIDTH;

    // 存储阵列定义，沿用原工程的 ram_style 属性声明 
    (* ram_style = RAM_STYLE *) 
    reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];

    // 读数据寄存器，用于实现 1 周期读取延迟 
    reg [DATA_WIDTH-1:0] rd_dat_r;

    // 写逻辑：同步写入 [cite: 123]
    always @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= wr_dat;
        end
    end

    // 读数据逻辑：同步读取并存入寄存器 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_dat_r <= {DATA_WIDTH{1'b0}};
        end else if (rd_en) begin
            rd_dat_r <= mem[rd_addr];
        end
    end

    // 读有效信号逻辑：对 rd_en 进行打拍同步 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_dat_vld <= 1'b0;
        end else begin
            rd_dat_vld <= rd_en;
        end
    end

    // 输出读到的寄存器数据 [cite: 123]
    assign rd_dat = rd_dat_r;

endmodule