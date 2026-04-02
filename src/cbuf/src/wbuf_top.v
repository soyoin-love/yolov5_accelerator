`timescale 1ns / 1ps
//读出需要四个时钟周期
module wbuf_dat_top #(
    parameter BANK_NUM   = 8,
    parameter DATA_WIDTH = 128,  
    parameter ADDR_WIDTH = 10,   
    parameter REGION_W   = 8     
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // ==========================================
    // 1. W_CDMA 写端口 
    // ==========================================
    input  wire [BANK_NUM-1:0]                wr_bank_en,     
    input  wire [REGION_W-1:0]                wr_offset,      
    input  wire [127:0]                       wr_dat,
    input  wire                               wr_region_done, 
    output wire                               wbuf_can_write, 

    // ==========================================
    // 2. F_CSC 读控制端口 (接口已更新)
    // ==========================================
    input  wire [BANK_NUM-1:0]                csc_wt_rd_en,   
    input  wire                               csc_step_en,    
    input  wire                               csc_offset_clr, // 新增：单像素窗口算完
    input  wire                               csc_region_done,// 新增：当前通道组彻底算完
    output wire                               wbuf_can_read,  

    // ==========================================
    // 3. CMAC 阵列数据输出
    // ==========================================
    output wire                               rd_dat_vld,
    output wire [BANK_NUM*DATA_WIDTH-1:0]     rd_dat_out
);

    // ==========================================================
    // A. 4 区域环形缓存 (Ring Buffer) 流控指针
    // ==========================================================
    reg [2:0] wr_region_ptr; 
    reg [2:0] rd_region_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_region_ptr <= 0;
            rd_region_ptr <= 0;
        end else begin
            if (wr_region_done) 
                wr_region_ptr <= wr_region_ptr + 1'b1;
            
            // 当前通道组算完，彻底抛弃当前权重区域
            if (csc_step_en && csc_region_done) 
                rd_region_ptr <= rd_region_ptr + 1'b1;
        end
    end

    wire [2:0] valid_regions = wr_region_ptr - rd_region_ptr;

    // 【核心修复】安全的前瞻扣除逻辑，防止溢出产生幽灵触发
    wire consuming_last_beat = csc_step_en && csc_region_done;
    wire [2:0] effective_valid_regions = consuming_last_beat ? (valid_regions - 1'b1) : valid_regions;

    assign wbuf_can_write = (valid_regions < 4); 
    assign wbuf_can_read  = (effective_valid_regions > 0); 

    wire [ADDR_WIDTH-1:0] wr_addr = {wr_region_ptr[1:0], wr_offset};

    // ==========================================================
    // B. Stage 1: 地址生成与流水线打拍
    // ==========================================================
    reg [REGION_W-1:0]    rd_offset;
    reg [BANK_NUM-1:0]    rd_en_p1;
    reg [ADDR_WIDTH-1:0]  rd_addr_p1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rd_offset  <= 0;
            rd_en_p1   <= 0;
            rd_addr_p1 <= 0;
        end else begin
            rd_en_p1   <= csc_step_en ? csc_wt_rd_en : 8'h00;
            rd_addr_p1 <= {rd_region_ptr[1:0], rd_offset}; 

            if (csc_step_en) begin
                if (csc_offset_clr) rd_offset <= 0; // 单个窗口扫描完毕，复位等下一个像素块复用
                else rd_offset <= rd_offset + 1'b1;  
            end
        end
    end


    // ==========================================================
    // C. Stage 2: 8 个 Bank 物理例化 (T3 吐出原始数据)
    // ==========================================================
    reg [BANK_NUM-1:0] bank_rd_vld;
    wire [BANK_NUM*DATA_WIDTH-1:0] raw_rd_dat; 
    wire [BANK_NUM*DATA_WIDTH-1:0] comb_rd_dat_out;

    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : W_BANK_INST
            wbuf u_bank (
                .clka  (clk),
                .ena   (1'b1),               
                .wea   (wr_bank_en[b]),      
                .addra (wr_addr),            
                .dina  (wr_dat),             
                .clkb  (clk),
                .enb   (rd_en_p1[b]),        
                .addrb (rd_addr_p1),         
                .doutb (raw_rd_dat[b * DATA_WIDTH +: DATA_WIDTH]) 
            );

            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) bank_rd_vld[b] <= 1'b0;
                else bank_rd_vld[b] <= rd_en_p1[b];
            end

            assign comb_rd_dat_out[b * DATA_WIDTH +: DATA_WIDTH] = 
                bank_rd_vld[b] ? raw_rd_dat[b * DATA_WIDTH +: DATA_WIDTH] : {DATA_WIDTH{1'b0}};
        end
    endgenerate

    wire comb_rd_dat_vld = bank_rd_vld[0];

    // ==========================================================
    // D. Stage 3: 输出管线化 (T4 与 T5)，强制对齐 CBUF 延迟
    // ==========================================================
    reg [BANK_NUM*DATA_WIDTH-1:0] rd_dat_d1, rd_dat_d2;
    reg                           rd_vld_d1, rd_vld_d2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_dat_d1 <= 0; rd_dat_d2 <= 0;
            rd_vld_d1 <= 0; rd_vld_d2 <= 0;
        end else begin
            // 延迟 1 拍 (对应管线 T4)
            rd_dat_d1 <= comb_rd_dat_out;
            rd_vld_d1 <= comb_rd_dat_vld;
            
            // 延迟 2 拍 (对应管线 T5)
            rd_dat_d2 <= rd_dat_d1;
            rd_vld_d2 <= rd_vld_d1;
        end
    end

    // 最终输出端口对接 T5 寄存器
    assign rd_dat_out = rd_dat_d2;
    assign rd_dat_vld = rd_vld_d2;



endmodule