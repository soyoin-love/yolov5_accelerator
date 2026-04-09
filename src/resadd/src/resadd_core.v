`timescale 1ns / 1ps

// 残差加法计算核心。
// 对 8 个像素、每像素 8 个通道同时做 INT8 饱和加法。
// 本模块改为 1 拍时序逻辑：输入有效后的下一个时钟周期输出结果。
module resadd_core #(
    parameter PIXEL_NUM = 8,
    parameter CH_NUM    = 8
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          in_vld,
    input  wire [PIXEL_NUM*CH_NUM*8-1:0] src0_dat,
    input  wire [PIXEL_NUM*CH_NUM*8-1:0] src1_dat,
    input  wire                          cfg_relu_en,
    output reg                           sum_vld,
    output reg  [PIXEL_NUM*CH_NUM*8-1:0] sum_dat
);

    integer i;
    reg signed [8:0] add_s;
    reg [PIXEL_NUM*CH_NUM*8-1:0] sum_dat_nxt;

    always @(*) begin
        sum_dat_nxt = {(PIXEL_NUM*CH_NUM*8){1'b0}};

        for (i = 0; i < PIXEL_NUM*CH_NUM; i = i + 1) begin
            // 第一版只做同 scale 的残差加法，不引入乘 scale 和 requant。
            add_s = $signed(src0_dat[i*8 +: 8]) + $signed(src1_dat[i*8 +: 8]);

            if (cfg_relu_en && add_s[8]) begin
                sum_dat_nxt[i*8 +: 8] = 8'sd0;
            end else if (add_s > 9'sd127) begin
                sum_dat_nxt[i*8 +: 8] = 8'sd127;
            end else if (add_s < -9'sd128) begin
                sum_dat_nxt[i*8 +: 8] = -8'sd128;
            end else begin
                sum_dat_nxt[i*8 +: 8] = add_s[7:0];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_vld <= 1'b0;
            sum_dat <= {(PIXEL_NUM*CH_NUM*8){1'b0}};
        end else begin
            sum_vld <= in_vld;

            if (in_vld) begin
                sum_dat <= sum_dat_nxt;
            end
        end
    end

endmodule
