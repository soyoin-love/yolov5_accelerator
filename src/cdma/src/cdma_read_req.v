`timescale 1ns / 1ps

module cdma_read_req #(
    parameter ROW_BLOCKS = 8  // 环形缓存最大行数
)(
    input  wire        clk,
    input  wire        rst_n,

    // 控制与配置信号
    input  wire        start,
    input  wire [31:0] cfg_base_addr,
    input  wire [15:0] cfg_width,     // 图像宽度 (建议补齐为偶数) yolov5一定是偶数
    input  wire [15:0] cfg_height,    // 图像高度
    input  wire [15:0] cfg_ch_groups, // 输入通道组数

    // 来自 CSC 的释放信号 (用于补充 Credit)
    input  wire        rd_row_free,
    input  wire [3:0]  rd_free_num,

    // MCIF 请求接口
    input  wire        mcif_req_rdy,  // MCIF 准备好接收请求
    output wire        mcif_req_vld,
    output wire [39:0] mcif_req_pd    // [39:32] ARLEN, [31:0] ADDR
    
);

    // ==========================================
    // 1. Credit 令牌管理 (Ring Buffer 流控)
    // ==========================================
    reg [4:0] row_credits; // 当前可用的空行区块数
    wire      req_row_done; // 本模块请求完了一整行
    

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_credits <= 0;
        end else if (start) begin
            row_credits <= ROW_BLOCKS; // 启动时满令牌
        end else begin
            case ({rd_row_free, req_row_done})
                2'b10: row_credits <= row_credits + rd_free_num;
                2'b01: row_credits <= row_credits - 1'b1;
                2'b11: row_credits <= row_credits + rd_free_num - 1'b1;
            endcase
        end
    end

    // ==========================================
    // 2. 请求状态机与坐标追踪
    // ==========================================
    reg [15:0] req_row;
    reg [15:0] req_ch_grp;
    reg [15:0] req_col_beat; // 已经请求的节拍数 (1节拍 = 2像素)
    reg [31:0] current_addr;

    //wire [15:0] total_beats_per_line = cfg_width >> 1; // 假设 width 为偶数
    wire [15:0] total_beats_per_line = (cfg_width+1) >> 1;  //即使是奇数也一定能传完
    wire [15:0] beats_rem = total_beats_per_line - req_col_beat;
    
    // 核心：自动切分超过 256 拍的长突发
    wire [8:0]  cur_burst_len = (beats_rem > 16'd256) ? 9'd256 : beats_rem[8:0];
    
    // 封包打包：[39:32] 突发次数减1, [31:0] 起始地址
    assign mcif_req_pd = { (cur_burst_len[7:0] - 8'd1), current_addr };
    
    // 发送条件：有可用空行 + 还没发完 + mcif 就绪
    assign mcif_req_vld = (row_credits > 0) && (req_row < cfg_height);


    // ==========================================
    // 1. 进位/握手标志信号 (关键级联逻辑)
    // ==========================================
    // 成功发起一次 AXI 读请求 (MCIF 握手成功)
    wire req_ack       = mcif_req_vld && mcif_req_rdy;
    
    // 当前请求覆盖到了这一行（当前通道组）的边界
    //wire col_beat_last = req_ack && (req_col_beat + cur_burst_len >= total_beats_per_line);
    //改为当前行剩余beat数小于256
    wire col_beat_last = req_ack && (beats_rem <= 16'd256);   //

    // 当前请求覆盖到了这一行所有通道组的边界 (准备切换到下一行)
    wire ch_grp_last   = col_beat_last && (req_ch_grp == cfg_ch_groups - 1);


    // ==========================================
    // 2. 地址追踪器 (Address Tracker)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_addr <= 32'd0;
        end else if (start) begin
            current_addr <= cfg_base_addr;
        end else if (req_ack) begin
            // 每次请求成功，地址按字节偏移自增：突发长度 * 16字节
            current_addr <= current_addr + { {20{1'b0}}, cur_burst_len, 4'd0 }; 
        end
    end


    // ==========================================
    // 3. 列节拍计数器 (Column Beat Counter)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            req_col_beat <= 16'd0;
        end else if (req_ack) begin
            if (col_beat_last)
                req_col_beat <= 16'd0;
            else
                req_col_beat <= req_col_beat + cur_burst_len;
        end
    end


    // ==========================================
    // 4. 通道组计数器 (Channel Group Counter)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            req_ch_grp <= 16'd0;
        end else if (col_beat_last) begin
            if (ch_grp_last)
                req_ch_grp <= 16'd0;
            else
                req_ch_grp <= req_ch_grp + 1'b1;
        end
    end


    // ==========================================
    // 5. 行计数器 (Row Counter)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            req_row <= 16'd0;
        end else if (ch_grp_last) begin
            req_row <= req_row + 1'b1;
        end
    end

    // 产生一行请求完毕的标志脉冲，用于扣除 credit
    assign req_row_done = (req_ack) && 
                        (col_beat_last) &&
                        (req_ch_grp == cfg_ch_groups - 1);

endmodule