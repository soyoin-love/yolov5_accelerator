`timescale 1ns / 1ps

module cacc_core #(
    parameter PIXEL_NUM  = 8,   // 并行处理的像素个数 (N=8)
    parameter OUT_CH_NUM = 16,  // 并行处理的输出通道数 (TK_OUT=16)
    parameter PSUM_W     = 19,
    parameter ACC_W      = 27
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // MAC 阵列输入
    input  wire                               mac_valid,
    input  wire [7:0]                         mac_pixel_mask,
    input  wire                               mac_is_last_ci,
    input  wire [PIXEL_NUM*OUT_CH_NUM*PSUM_W-1:0] psum_in,

    // 握手与反压
    input  wire                               requant_ready,
    output wire                               cacc_ready,

    // 输出接口 (发往量化模块)
    output reg                                quant_vld,
    output reg  [7:0]                         quant_pixel_mask,
    output wire [PIXEL_NUM*OUT_CH_NUM*ACC_W-1:0]  quant_data_in
);
    reg signed [ACC_W-1:0] acc_mem [0:1][0:PIXEL_NUM-1][0:OUT_CH_NUM-1];
    reg wr_bank, rd_bank;
    reg is_first_ci;
    reg [1:0] bank_full;

    assign cacc_ready = ~bank_full[wr_bank];

    // // 状态切换与 bank_full 控制
    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         wr_bank <= 0; rd_bank <= 0; is_first_ci <= 1; bank_full <= 0;
    //     end else if (start) begin
    //         wr_bank <= 0; rd_bank <= 0; is_first_ci <= 1; bank_full <= 0;
    //     end else begin
    //         // 写入侧状态更新
    //         if (mac_valid && cacc_ready) begin
    //             is_first_ci <= mac_is_last_ci;
    //             if (mac_is_last_ci) begin
    //                 bank_full[wr_bank] <= 1'b1;
    //                 wr_bank <= ~wr_bank;
    //             end
    //         end
    //         // 读出侧状态清除
    //         if (quant_vld && requant_ready) begin
    //             bank_full[rd_bank] <= 1'b0;
    //         end
    //     end
    // end

    // ---------------------------------------------------------
    // 块 1: 状态切换与 bank_full 控制 (移除 rd_bank)
    // ---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_bank <= 0; is_first_ci <= 1; bank_full <= 0;
        end else if (start) begin
            wr_bank <= 0; is_first_ci <= 1; bank_full <= 0;
        end else begin
            // 写入侧状态更新
            if (mac_valid && cacc_ready) begin
                is_first_ci <= mac_is_last_ci;
                if (mac_is_last_ci) begin
                    bank_full[wr_bank] <= 1'b1;
                    wr_bank <= ~wr_bank;
                end
            end
            // 读出侧状态清除
            if (quant_vld && requant_ready) begin
                bank_full[rd_bank] <= 1'b0;
            end
        end
    end

    // 累加计算逻辑
    integer p, ch;
    always @(posedge clk) begin
        if (mac_valid && cacc_ready) begin
            for (p = 0; p < PIXEL_NUM; p = p + 1) begin
                for (ch = 0; ch < OUT_CH_NUM; ch = ch + 1) begin
                    if (is_first_ci) 
                        acc_mem[wr_bank][p][ch] <= $signed(psum_in[(p*OUT_CH_NUM+ch)*PSUM_W +: PSUM_W]);
                    else             
                        acc_mem[wr_bank][p][ch] <= acc_mem[wr_bank][p][ch] + $signed(psum_in[(p*OUT_CH_NUM+ch)*PSUM_W +: PSUM_W]);
                end
            end
        end
    end

    // Mask 寄存
    reg [7:0] meta_mask [0:1];
    always @(posedge clk) begin
        if (mac_valid && is_first_ci) begin
            meta_mask[wr_bank] <= mac_pixel_mask;
        end
    end

    // // 量化触发控制
    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         quant_vld <= 0;
    //     end else if (start) begin
    //         quant_vld <= 0;
    //     end else begin
    //         if (bank_full[rd_bank] && !quant_vld) begin
    //             quant_vld <= 1'b1;
    //             quant_pixel_mask <= meta_mask[rd_bank];
    //         end else if (quant_vld && requant_ready) begin
    //             quant_vld <= 1'b0;
    //             rd_bank <= ~rd_bank;
    //         end
    //     end
    // end

    // ---------------------------------------------------------
    // 块 2: 量化触发控制 (集中处理 rd_bank)
    // ---------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            quant_vld <= 1'b0;
            quant_pixel_mask <= 8'b0; 
            rd_bank <= 1'b0;             // 将 rd_bank 的复位移到这里
        end else if (start) begin
            quant_vld <= 1'b0;
            quant_pixel_mask <= 8'b0;
            rd_bank <= 1'b0;             // 将 rd_bank 的初始化移到这里
        end else begin
            if (bank_full[rd_bank] && !quant_vld) begin
                quant_vld <= 1'b1;
                quant_pixel_mask <= meta_mask[rd_bank];
            end else if (quant_vld && requant_ready) begin
                quant_vld <= 1'b0;
                rd_bank <= ~rd_bank;     // rd_bank 的翻转逻辑保留在这里
            end
        end
    end


    // 输出赋值
    genvar gp, gch;
    generate
        for (gp = 0; gp < PIXEL_NUM; gp = gp + 1) begin : OUT_P
            for (gch = 0; gch < OUT_CH_NUM; gch = gch + 1) begin : OUT_CH
                assign quant_data_in[(gp*OUT_CH_NUM+gch)*ACC_W +: ACC_W] = acc_mem[rd_bank][gp][gch];
            end
        end
    endgenerate

endmodule