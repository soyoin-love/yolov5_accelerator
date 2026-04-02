`timescale 1ns / 1ps
//读出花费4个时钟周期
module cbuf_dat_top #(
    parameter BANK_NUM   = 8,       
    parameter TK_IN      = 8,       
    parameter N          = 8,       
    parameter ADDR_WIDTH = 10,     
    parameter ROW_BLOCKS = 8        
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // 全局配置寄存器
    input  wire [ADDR_WIDTH-1:0]              cfg_max_col_blocks, 
    input  wire [ADDR_WIDTH-1:0]              cfg_max_ch_groups,  
    input  wire [3:0]                         cfg_min_calc_rows,
    input  wire [15:0]                        cfg_height,

    // CDMA 写端口 (写路径保持 1 拍延迟不变)
    input  wire                               wr_en,
    input  wire [15:0]                        wr_row,      
    input  wire [15:0]                        wr_col,      
    input  wire [15:0]                        wr_ch_grp,   
    input  wire [2*TK_IN*N-1:0]               wr_dat,      
    input  wire                               wr_row_done, 
    output wire                               cbuf_can_write, 

    // CSC 读端口 (输入)
    input  wire [7:0]                         rd_en,
    input  wire [15:0]                        rd_row,      
    input  wire [15:0]                        rd_col_align, 
    input  wire [15:0]                        rd_ch_grp,   
    input  wire                               rd_row_free, 
    input  wire [3:0]                         rd_free_num, 
    
    // 读输出 (输出延迟: 4 拍)
    output wire                               cbuf_can_read,  
    output reg                                rd_dat_vld,  
    output reg  [BANK_NUM*TK_IN*N-1:0]        rd_dat_out      
);

    wire [ADDR_WIDTH-1:0] block_size = cfg_max_col_blocks * cfg_max_ch_groups;

    // ==========================================================
    // 1. 环形缓存流控指针 (无涉之时序，保持原样)
    // ==========================================================
    reg [15:0] wr_row_ptr;
    reg [15:0] rd_row_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_row_ptr <= 0;
            rd_row_ptr <= 0;
        end else begin
            if (wr_row_done) wr_row_ptr <= wr_row_ptr + 1'b1;
            if (rd_row_free) rd_row_ptr <= rd_row_ptr + rd_free_num;
        end
    end

    wire [15:0] valid_rows = wr_row_ptr - rd_row_ptr;
    assign cbuf_can_write = (valid_rows < ROW_BLOCKS);
    assign cbuf_can_read  = (valid_rows >= cfg_min_calc_rows) || 
                            ((wr_row_ptr >= cfg_height) && (valid_rows > 0));

    // ==========================================================
    // 写路径流水线 (Stage 1) - 保持不变
    // ==========================================================
    reg [ADDR_WIDTH-1:0] wr_mul_row, wr_mul_ch, wr_offset;
    reg                  wr_en_p1;
    reg [2*TK_IN*N-1:0]  wr_dat_p1;
    reg [2:0]            target_bank_0_p1, target_bank_1_p1;

    // 【新增这行代码】：将打拍后的行、通道、列偏移相加，生成真实的物理写入地址
    wire [ADDR_WIDTH-1:0] wr_addr = wr_mul_row + wr_mul_ch + wr_offset;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_mul_row <= 0; wr_mul_ch <= 0; wr_offset <= 0; wr_en_p1 <= 0;
            wr_dat_p1  <= 0; target_bank_0_p1 <= 0; target_bank_1_p1 <= 0;
        end else begin
            wr_mul_row <= wr_row[2:0] * block_size;
            wr_mul_ch  <= wr_ch_grp * cfg_max_col_blocks;
            wr_offset  <= wr_col >> 3;
            wr_en_p1   <= wr_en;
            wr_dat_p1  <= wr_dat;
            target_bank_0_p1 <= wr_col[2:0];   
            target_bank_1_p1 <= wr_col[2:0] + 1'b1;
        end
    end

    // ==========================================================
    // 读路径流水线 Stage 1 (T1): 坐标预计算与掩码路由
    // ==========================================================
    reg [ADDR_WIDTH-1:0] rd_mul_row_t1, rd_mul_ch_t1, rd_offset_base_t1;
    reg [2:0]            rd_align_offset_t1;
    reg [7:0]            rd_en_t1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_mul_row_t1 <= 0; rd_mul_ch_t1 <= 0; rd_offset_base_t1 <= 0;
            rd_align_offset_t1 <= 0; rd_en_t1 <= 0;
        end else begin
            rd_mul_row_t1      <= rd_row[2:0] * block_size;  
            rd_mul_ch_t1       <= rd_ch_grp * cfg_max_col_blocks;  
            rd_offset_base_t1  <= rd_col_align >> 3;     
            rd_align_offset_t1 <= rd_col_align[2:0];     
            
            // 掩码物理映射
            rd_en_t1[0] <= rd_en[(0 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[1] <= rd_en[(1 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[2] <= rd_en[(2 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[3] <= rd_en[(3 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[4] <= rd_en[(4 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[5] <= rd_en[(5 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[6] <= rd_en[(6 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[7] <= rd_en[(7 - rd_col_align[2:0]) & 3'b111];
        end
    end

    // ==========================================================
    // 读路径流水线 Stage 2 (T2): 基地址加法树
    // ==========================================================
    reg [ADDR_WIDTH-1:0] base_rd_addr_t2;
    reg [2:0]            rd_align_offset_t2;
    reg [7:0]            rd_en_t2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            base_rd_addr_t2    <= 0;
            rd_align_offset_t2 <= 0;
            rd_en_t2           <= 0;
        end else begin
            // 阻断加法器组合逻辑过长
            base_rd_addr_t2    <= rd_mul_row_t1 + rd_mul_ch_t1 + rd_offset_base_t1;
            rd_align_offset_t2 <= rd_align_offset_t1;
            rd_en_t2           <= rd_en_t1;
        end
    end

    // ==========================================================
    // 读路径流水线 Stage 3 (T3): Bank 独立寻址与 BRAM 读取
    // ==========================================================
    wire [BANK_NUM-1:0]         bank_wr_en;
    wire [BANK_NUM*TK_IN*N-1:0] raw_rd_dat; // T3 末尾吐出
    
    reg [2:0]                   rd_align_offset_t3;
    reg [BANK_NUM-1:0]          bank_rd_vld_t3;

    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : BANK_INST
            
            // 写逻辑 (保持 T1 的数据)
            assign bank_wr_en[b] = wr_en_p1 && ((b == target_bank_0_p1) || (b == target_bank_1_p1));
            wire [TK_IN*N-1:0] bank_wr_dat = 
                (b == target_bank_0_p1) ? wr_dat_p1[TK_IN*N-1 : 0] :
                (b == target_bank_1_p1) ? wr_dat_p1[2*TK_IN*N-1 : TK_IN*N] : {(TK_IN*N){1'b0}};

            // 【Bank独立加法器】这是一个仅由寄存器驱动的 10-bit 加法器，时序极佳
            wire [ADDR_WIDTH-1:0] b_rd_addr = base_rd_addr_t2 + ((b < rd_align_offset_t2) ? 1'b1 : 1'b0);
            //物理bank小于偏移的要读下一个RAM地址

            cbuf u_buf (
                .clka  (clk),                
                .ena   (1'b1),               
                .wea   (bank_wr_en[b]),      
                .addra (wr_addr),            
                .dina  (bank_wr_dat),        
                
                .clkb  (clk),                
                .enb   (rd_en_t2[b]),        // T2 给出读使能
                .addrb (b_rd_addr),          // T2 给出读地址
                .doutb (raw_rd_dat[b * (TK_IN*N) +: (TK_IN*N)]) // T3 吐出数据
            );
        end
    endgenerate

    // 同步控制信号到 T3
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_align_offset_t3 <= 3'd0;
            bank_rd_vld_t3     <= 8'd0;
        end else begin
            rd_align_offset_t3 <= rd_align_offset_t2;
            bank_rd_vld_t3     <= rd_en_t2;
        end
    end

    // ==========================================================
    // 读路径流水线 Stage 4 (T4): 交叉移位与最终输出寄存器
    // ==========================================================
    reg [BANK_NUM*TK_IN*N-1:0] shifted_dat;
    integer i;

    // 组合逻辑移位器
    always @(*) begin
        for (i = 0; i < BANK_NUM; i = i + 1) begin
            shifted_dat[i*(TK_IN*N) +: (TK_IN*N)] = 
                raw_rd_dat[((i + rd_align_offset_t3) & 3'b111) * (TK_IN*N) +: (TK_IN*N)];
        end
    end

    // 打入最终寄存器，斩断时序路径
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_dat_out <= 0;
            rd_dat_vld <= 1'b0;
        end else begin
            rd_dat_out <= shifted_dat;
            rd_dat_vld <= (|bank_rd_vld_t3); // 任意 Bank 有效即视为整体有效
        end
    end

endmodule