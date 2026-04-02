`timescale 1ns / 1ps

//计算一次消耗:simd_dsp中消耗4个时钟周期,camc_8加法树消耗3个时钟周期
//总共7个时钟周期
module cmac_8_channels #(
    parameter N = 8 // 数据位宽 INT8
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // 共享输入特征：8个通道并排 (8 * 8 = 64 bit)
    input  wire [8*N-1:0]         features_in,

    // 独立权重A：卷积核0的 8个通道权重 (64 bit)
    input  wire [8*N-1:0]         weights_oc0,

    // 独立权重B：卷积核1的 8个通道权重 (64 bit)
    input  wire [8*N-1:0]         weights_oc1,

    // 输出：8个16bit乘积相加，最多溢出3bit，结果为19bit
    output reg  signed [2*N+2:0]  sum_out_oc0,
    output reg  signed [2*N+2:0]  sum_out_oc1
);

    // ==========================================
    // 1. 例化 8 个 SIMD DSP 引擎
    // ==========================================
    wire signed [2*N-1:0] dsp_p_a [0:7];
    wire signed [2*N-1:0] dsp_p_b [0:7];

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : DSP_ARRAY
            simd_mac_dsp #(
                .N(N)
            ) u_simd_mac (
                .clk   (clk),
                .rst_n (rst_n),
                .A     (weights_oc0[i*N +: N]), 
                .B     (weights_oc1[i*N +: N]), 
                .C     (features_in[i*N +: N]), // 共享特征
                .P_A   (dsp_p_a[i]), 
                .P_B   (dsp_p_b[i])  
            );
        end
    endgenerate

    // ==========================================
    // 2. 加法树 Stage 1: 8 变 4 (16bit + 16bit -> 17bit)
    // ==========================================
    reg signed [2*N:0] sum_oc0_s1 [0:3];
    reg signed [2*N:0] sum_oc1_s1 [0:3];
    integer j;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < 4; j = j + 1) begin
                sum_oc0_s1[j] <= 0;
                sum_oc1_s1[j] <= 0;
            end
        end else begin
            for (j = 0; j < 4; j = j + 1) begin
                sum_oc0_s1[j] <= dsp_p_a[2*j] + dsp_p_a[2*j+1];
                sum_oc1_s1[j] <= dsp_p_b[2*j] + dsp_p_b[2*j+1];
            end
        end
    end

    // ==========================================
    // 3. 加法树 Stage 2: 4 变 2 (17bit + 17bit -> 18bit)
    // ==========================================
    reg signed [2*N+1:0] sum_oc0_s2 [0:1];
    reg signed [2*N+1:0] sum_oc1_s2 [0:1];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_oc0_s2[0] <= 0; sum_oc0_s2[1] <= 0;
            sum_oc1_s2[0] <= 0; sum_oc1_s2[1] <= 0;
        end else begin
            sum_oc0_s2[0] <= sum_oc0_s1[0] + sum_oc0_s1[1];
            sum_oc0_s2[1] <= sum_oc0_s1[2] + sum_oc0_s1[3];
            
            sum_oc1_s2[0] <= sum_oc1_s1[0] + sum_oc1_s1[1];
            sum_oc1_s2[1] <= sum_oc1_s1[2] + sum_oc1_s1[3];
        end
    end

    // ==========================================
    // 4. 加法树 Stage 3: 2 变 1 最终输出 (18bit + 18bit -> 19bit)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_out_oc0 <= 0;
            sum_out_oc1 <= 0;
        end else begin
            sum_out_oc0 <= sum_oc0_s2[0] + sum_oc0_s2[1];
            sum_out_oc1 <= sum_oc1_s2[0] + sum_oc1_s2[1];
        end
    end

endmodule