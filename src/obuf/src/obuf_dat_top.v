`timescale 1ns / 1ps

module obuf_dat_top #(
    parameter BANK_NUM   = 16,
    parameter DATA_WIDTH = 64,   // 单 Bank 64-bit
    parameter ADDR_WIDTH = 9     // 深度 512 
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // ==========================================
    // 1. 写侧接口 (来自 CACC)
    // ==========================================
    input  wire                               cacc_wr_vld,   
    input  wire [BANK_NUM-1:0]                cacc_wr_bank_en, // 16-bit 掩码，指示写入哪些 Bank,可以移WDMA选择
    input  wire [BANK_NUM*DATA_WIDTH-1:0]     cacc_wr_dat,   
    output wire                               obuf_can_write,  // 两组 FIFO 均未满时允许写入

    // ==========================================
    // 2. 读侧接口 (发往 WDMA)
    // ==========================================
    input  wire [BANK_NUM-1:0]                wdma_rd_en,      // 16-bit 读使能掩码
    input  wire                               wdma_rd_next_g0, // 弹出 Group 0 (Bank 0-7) 当前数据
    input  wire                               wdma_rd_next_g1, // 弹出 Group 1 (Bank 8-15) 当前数据
    output wire                               obuf_rd_vld,     
    output wire [127:0]                       obuf_rd_dat,     
    
    // 分别暴露两组 FIFO 的可用行数给 WDMA
    output wire [ADDR_WIDTH:0]                obuf_used_lines_g0,
    output wire [ADDR_WIDTH:0]                obuf_used_lines_g1
);

    // ==========================================
    // 双 FIFO 独立指针管理
    // ==========================================
    reg [ADDR_WIDTH:0] wr_ptr_g0, rd_ptr_g0;
    reg [ADDR_WIDTH:0] wr_ptr_g1, rd_ptr_g1;

    assign obuf_used_lines_g0 = wr_ptr_g0 - rd_ptr_g0;
    assign obuf_used_lines_g1 = wr_ptr_g1 - rd_ptr_g1;

    // 水位线控制 (预留 32 行防溢出)
    wire almost_full_g0 = (obuf_used_lines_g0 >= 9'd480);
    wire almost_full_g1 = (obuf_used_lines_g1 >= 9'd480);
    assign obuf_can_write = !almost_full_g0 && !almost_full_g1;
    

    // 写指针逻辑 (依据写掩码独立递增)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr_g0 <= 0;
            wr_ptr_g1 <= 0;
        end else if (start) begin
            wr_ptr_g0 <= 0;
            wr_ptr_g1 <= 0;
        end else if (cacc_wr_vld && obuf_can_write) begin   //两个bank不一定同时写
            if (|cacc_wr_bank_en[7:0])  wr_ptr_g0 <= wr_ptr_g0 + 1'b1;
            if (|cacc_wr_bank_en[15:8]) wr_ptr_g1 <= wr_ptr_g1 + 1'b1;
        end
    end

    // 读指针逻辑 (依据 WDMA 发来的 pop 脉冲独立递增)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr_g0 <= 0;
            rd_ptr_g1 <= 0;
        end else if (start) begin
            rd_ptr_g0 <= 0;
            rd_ptr_g1 <= 0;
        end else begin
            if (wdma_rd_next_g0) rd_ptr_g0 <= rd_ptr_g0 + 1'b1;
            if (wdma_rd_next_g1) rd_ptr_g1 <= rd_ptr_g1 + 1'b1;
        end
    end

    // ==========================================
    // 16 Bank 物理例化
    // ==========================================
    wire [DATA_WIDTH-1:0] bank_outs [0:BANK_NUM-1];

    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : OBUF_BANKS
            // 判断当前 Bank 属于哪个 Group，赋予对应的指针
            wire [8:0] wr_addr = (b < 8) ? wr_ptr_g0[8:0] : wr_ptr_g1[8:0];
            wire [8:0] rd_addr = (b < 8) ? rd_ptr_g0[8:0] : rd_ptr_g1[8:0];

            o_buf u_bank (
                .clka  (clk),
                .ena   (1'b1),
                .wea   (cacc_wr_vld && cacc_wr_bank_en[b]),
                .addra (wr_addr),
                .dina  (cacc_wr_dat[b*DATA_WIDTH +: DATA_WIDTH]),
                .clkb  (clk),
                .enb   (wdma_rd_en[b]),
                .addrb (rd_addr),
                .doutb (bank_outs[b]) 
            );
        end
    endgenerate

    // ==========================================
    // 读数据延迟与 16选2 MUX
    // ==========================================
    reg [BANK_NUM-1:0] wdma_rd_en_d1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) wdma_rd_en_d1 <= 16'd0;
        else if (start) wdma_rd_en_d1 <= 16'd0;
        else        wdma_rd_en_d1 <= wdma_rd_en;
    end

    reg [127:0] obuf_rd_dat_comb;
    always @(*) begin
        case (wdma_rd_en_d1)
            // Group 0
            16'h0003: obuf_rd_dat_comb = {bank_outs[1], bank_outs[0]};
            16'h000C: obuf_rd_dat_comb = {bank_outs[3], bank_outs[2]};
            16'h0030: obuf_rd_dat_comb = {bank_outs[5], bank_outs[4]};
            16'h00C0: obuf_rd_dat_comb = {bank_outs[7], bank_outs[6]};
            // Group 1
            16'h0300: obuf_rd_dat_comb = {bank_outs[9], bank_outs[8]};
            16'h0C00: obuf_rd_dat_comb = {bank_outs[11], bank_outs[10]};
            16'h3000: obuf_rd_dat_comb = {bank_outs[13], bank_outs[12]};
            16'hC000: obuf_rd_dat_comb = {bank_outs[15], bank_outs[14]};
            default:  obuf_rd_dat_comb = 128'd0;
        endcase
    end

    assign obuf_rd_dat = obuf_rd_dat_comb;
    assign obuf_rd_vld = (|wdma_rd_en_d1);

endmodule