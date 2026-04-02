`timescale 1ns / 1ps

module simd_mac_dsp #(
    parameter N = 8 // 数据位宽，YOLO通常为INT8
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire signed [N-1:0]    A,   // 权重 A
    input  wire signed [N-1:0]    B,   // 权重 B
    input  wire signed [N-1:0]    C,   // 输入特征图 C (复用乘数)
    
    output reg  signed [2*N-1:0]  P_A, // 输出结果 A * C
    output reg  signed [2*N-1:0]  P_B  // 输出结果 B * C
);

    // ==========================================
    // Stage 1: 预处理 (对应 4.2.3 & 4.2.1)
    // 获取 |C|，以及拼接 A 和 B
    // ==========================================
    reg sign_C_s1;
    reg [N:0]   abs_C_s1;      // 用 N+1 位存 |C|，防止 -128 溢出为 0
    reg [3*N:0] packed_AB_s1;  // 拼接后的 25bit (对于 N=8)
    reg sign_A_s1;
    reg sign_B_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sign_C_s1    <= 1'b0;
            abs_C_s1     <= 0;
            packed_AB_s1 <= 0;
            sign_A_s1    <= 1'b0;
            sign_B_s1    <= 1'b0;
        end else begin
            // 1. 记录 C 的符号位 (Sign_C)
            sign_C_s1 <= C[N-1];

            // 2. 求 |C| 的"骚操作"公式: |C| = (C ^ mask) + carry_in
            // 注意：扩充了一位防止 C = -128 (8'h80) 时取反加一溢出
            abs_C_s1 <= ({C[N-1], C} ^ {(N+1){C[N-1]}}) + C[N-1];

            // 3. 将 A 和 B 作为无符号数拼接到一起 (25bit)
            // {A (N bits), 中间补零 (N+1 bits), B (N bits)}
            packed_AB_s1 <= {A, {(N+1){1'b0}}, B};

            // 传递 A 和 B 的符号位，留给 Stage 3 修正用
            sign_A_s1 <= A[N-1];
            sign_B_s1 <= B[N-1];
        end
    end

    // ==========================================
    // Stage 2: DSP 核心计算 (当做无符号数乘法)
    // ==========================================
    // 34 bits (对于 N=8)，底层综合工具会自动将其映射为 DSP 块
    (* use_dsp = "yes" *)  reg [4*N+1:0] dsp_mult_out_s2; 
    reg sign_C_s2;
    reg sign_A_s2;
    reg sign_B_s2;
    reg [N:0] abs_C_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dsp_mult_out_s2 <= 0;
            sign_C_s2       <= 1'b0;
            sign_A_s2       <= 1'b0;
            sign_B_s2       <= 1'b0;
            abs_C_s2        <= 0;
        end else begin
            // DSP 硬核乘法：无符号数 * 无符号数
            dsp_mult_out_s2 <= $unsigned(packed_AB_s1) * $unsigned(abs_C_s1);

            // 延迟打拍
            sign_C_s2 <= sign_C_s1;
            sign_A_s2 <= sign_A_s1;
            sign_B_s2 <= sign_B_s1;
            abs_C_s2  <= abs_C_s1;
        end
    end

    // ==========================================
    // Stage 3: 拆解结果与数学修正 (对应 4.2.2)
    // ==========================================
    // 提取高低位乘积，注意警戒位(Guard bit)在中间
    // B_raw 占用低 2N 位 (15:0)
    // A_raw 从 2N+1 位开始 (32:17)
    wire [2*N-1:0] raw_A = dsp_mult_out_s2[4*N   : 2*N+1];
    wire [2*N-1:0] raw_B = dsp_mult_out_s2[2*N-1 : 0];

    // 计算公式 (4-2) 的修正项：(b_{n-1} * |C| * 2^n)
    // 乘以 2^n 等价于向左移位 N 位，即在低位补零
    wire [2*N:0] correction_A = sign_A_s2 ? {abs_C_s2, {(N){1'b0}}} : 0;
    wire [2*N:0] correction_B = sign_B_s2 ? {abs_C_s2, {(N){1'b0}}} : 0;

    reg signed [2*N:0] result_temp_A_s3; 
    reg signed [2*N:0] result_temp_B_s3;
    reg sign_C_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_temp_A_s3 <= 0;
            result_temp_B_s3 <= 0;
            sign_C_s3        <= 1'b0;
        end else begin
            // "先斩后奏"：无符号结果减去修正项，得到带有正确 A/B 符号的结果
            result_temp_A_s3 <= {1'b0, raw_A} - correction_A;
            result_temp_B_s3 <= {1'b0, raw_B} - correction_B;
            sign_C_s3        <= sign_C_s2;
        end
    end

    // ==========================================
    // Stage 4: 最终输出修正 (对应 4.2.4)
    // 根据 C 的原始符号，决定是否翻转结果
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            P_A <= 0;
            P_B <= 0;
        end else begin
            // 若 Sign_C == 1，则取反加一；否则保持原样
            P_A <= sign_C_s3 ? (~result_temp_A_s3[2*N-1:0] + 1'b1) : result_temp_A_s3[2*N-1:0];
            P_B <= sign_C_s3 ? (~result_temp_B_s3[2*N-1:0] + 1'b1) : result_temp_B_s3[2*N-1:0];
        end
    end

endmodule