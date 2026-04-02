`timescale 1ns / 1ps

module wdma_core #(
    parameter MAX_BURST  = 16, 
    parameter BANK_NUM   = 16, 
    parameter ADDR_WIDTH = 9
)(
    input  wire                      clk,
    input  wire                      rst_n,

    // CSR 配置接口
    input  wire                      cfg_start,       
    input  wire [31:0]               cfg_base_addr,   
    input  wire [15:0]               cfg_w_out,        // 直接使用精确像素宽 (如: 20)
    input  wire [15:0]               cfg_h_out,        
    input  wire [15:0]               cfg_co_groups,    

    // OBUF 交互接口
    input  wire [ADDR_WIDTH:0]       obuf_used_lines_g0, 
    input  wire [ADDR_WIDTH:0]       obuf_used_lines_g1, 
    output wire [BANK_NUM-1:0]       wdma_rd_en,      
    output wire                      wdma_rd_next_g0, 
    output wire                      wdma_rd_next_g1, 
    input  wire                      obuf_rd_vld,
    input  wire [127:0]              obuf_rd_dat,

    // MCIF 交互接口
    input  wire                      mcif_ready,      
    output wire                      mcif_valid,
    output wire [128:0]              mcif_data,
    
    input  wire                      mcif_complete, 
    output wire                      wdma_done      
);

    localparam ST_IDLE       = 3'd0;
    localparam ST_WAIT_OBUF  = 3'd1; 
    localparam ST_ARBITRATE  = 3'd2; 
    localparam ST_SEND_CMD   = 3'd3; 
    localparam ST_SEND_DATA  = 3'd4;
    localparam ST_CHECK_LOOP = 3'd5; 
    localparam ST_WAIT_DONE  = 3'd6;
    
    reg [2:0] state, next_state;
    reg [15:0] row_cnt;      
    reg [15:0] ch_grp;       
    reg [1:0]  chunk_cnt;    

    reg [31:0] cur_addr;     
    reg [15:0] rem_beats;    
    reg [7:0]  cur_burst_len;
    reg [7:0]  req_cnt;

    reg        dat_valid_r;
    reg [7:0]  data_sent_cnt; 

    // ==========================================
    // 精确的行节拍计算
    // ==========================================
    // 向上取整计算一行需要的 128-bit 节拍数. 对于 W=20, 这里是 10 拍.
    wire [15:0] total_row_beats = (cfg_w_out + 1) >> 1; 

    wire current_fifo_is_g1 = ch_grp[0]; 
    wire [15:0] min_len_req = (rem_beats > MAX_BURST) ? MAX_BURST[15:0] : rem_beats;
    
    // 安全行数判定算法：(已读偏移 + 准备请求的节拍 + 进位保护) / 4
    wire [15:0] required_lines = ({14'd0, chunk_cnt} + min_len_req + 3) >> 2  ; 
    
    // 计算当前 Burst 真实需要消耗 G0 的行数
    wire [15:0] g0_consume = (min_len_req + 7) >> 3; 
    
    // 计算当前 Burst 真实需要消耗 G1 的行数 (只有当请求长度超过 4 拍时才需要 G1)
    wire [15:0] g1_consume = (min_len_req > 16'd4) ? ((min_len_req - 16'd4 + 16'd7) >> 3) : 16'd0;

    wire obuf_ready = current_fifo_is_g1 ? (obuf_used_lines_g1 >= required_lines) 
                                        : (obuf_used_lines_g0 >= required_lines);

    //wire obuf_ready = (obuf_used_lines_g0 >= g0_consume) && (obuf_used_lines_g1 >= g1_consume);

    wire is_last_transfer = (row_cnt == cfg_h_out - 1'b1) && 
                            (ch_grp == cfg_co_groups - 1'b1) &&
                            (rem_beats == {8'd0, cur_burst_len});

    // ==========================================
    // 全局响应捕获标志 (Sticky Flag)
    // ==========================================
    reg resp_caught;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            resp_caught <= 1'b0;
        end else if (state == ST_IDLE && cfg_start) begin
            // 每次新任务启动时，清零标志位
            resp_caught <= 1'b0; 
        end else if (mcif_complete) begin
            // 只要检测到从机响应，立刻置 1 并锁死，不管当前在什么状态
            resp_caught <= 1'b1; 
        end
    end



    // ==========================================
    // AXI Outstanding 事务计数器
    // ==========================================
    reg [7:0] outstanding_aw;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= ST_IDLE;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            ST_IDLE:       if (cfg_start) next_state = ST_WAIT_OBUF;
            ST_WAIT_OBUF:  if (obuf_ready) next_state = ST_ARBITRATE;
            ST_ARBITRATE:  next_state = ST_SEND_CMD;
            ST_SEND_CMD:   if (mcif_ready) next_state = ST_SEND_DATA;
            ST_SEND_DATA:  if (data_sent_cnt == cur_burst_len - 1'b1 && dat_valid_r) next_state = ST_CHECK_LOOP;
            ST_CHECK_LOOP: begin
                if (rem_beats > 0) begin
                    next_state = ST_WAIT_OBUF; 
                end else if (ch_grp < cfg_co_groups - 1'b1) begin
                    next_state = ST_WAIT_OBUF; 
                end else begin
                    if (row_cnt == cfg_h_out - 1'b1) next_state = ST_WAIT_DONE; 
                    else next_state = ST_WAIT_OBUF; 
                end
            end
            //ST_WAIT_DONE:  if (mcif_complete) next_state = ST_IDLE;
            ST_WAIT_DONE: begin
                // 不再硬等瞬间脉冲，而是看标志位是否被置起
                if (resp_caught) next_state = ST_IDLE;
            end
            default:       next_state = ST_IDLE;
        endcase
    end

    // ==========================================
    // 强制截断弹出逻辑 (核心修改)
    // ==========================================
    wire issue_read = (state == ST_SEND_DATA) && (req_cnt < cur_burst_len) && mcif_ready;
    
    // 触发 OBUF 弹出的条件：读满了 4 拍(一个完整 FIFO 块) 或 已经读到了本行的最后一拍(强制清理对齐)
    wire force_pop_line = issue_read && ((chunk_cnt == 2'd3) || (rem_beats == 16'd1));
    
    assign wdma_rd_next_g0 = force_pop_line && (!current_fifo_is_g1);
    assign wdma_rd_next_g1 = force_pop_line && (current_fifo_is_g1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_cnt       <= 0;
            ch_grp        <= 0;
            chunk_cnt     <= 0;
            rem_beats     <= 0;
            cur_burst_len <= 0;
            req_cnt       <= 0;
            cur_addr      <= 0;
            dat_valid_r   <= 0;
            data_sent_cnt <= 0;
        end else begin
            if (state == ST_SEND_DATA) begin
                dat_valid_r <= issue_read; 
                if (dat_valid_r) data_sent_cnt <= data_sent_cnt + 1'b1;
            end else begin
                dat_valid_r <= 1'b0;
                data_sent_cnt <= 0;
            end

            case (state)
                ST_IDLE: begin
                    if (cfg_start) begin
                        row_cnt   <= 0;
                        ch_grp    <= 0;
                        cur_addr  <= cfg_base_addr;
                        rem_beats <= total_row_beats; 
                        chunk_cnt <= 0;
                    end
                end
                
                ST_ARBITRATE: begin
                    cur_burst_len <= min_len_req[7:0];
                    req_cnt       <= 0;
                end
                
                ST_SEND_CMD: begin
                    if (mcif_ready) begin
                        cur_addr  <= cur_addr + ({24'd0, cur_burst_len} << 4);
                        rem_beats <= rem_beats - {8'd0, cur_burst_len};
                    end
                end
                
                ST_SEND_DATA: begin
                    if (issue_read) begin
                        req_cnt   <= req_cnt + 1'b1;
                        chunk_cnt <= chunk_cnt + 1'b1; 
                    end
                end
                
                ST_CHECK_LOOP: begin
                    if (rem_beats == 0) begin
                        chunk_cnt <= 0; // 行切换或通道组切换时，严格归零
                        rem_beats <= total_row_beats; 
                        
                        if (ch_grp < cfg_co_groups - 1'b1) begin
                            ch_grp <= ch_grp + 1'b1; 
                        end else begin
                            ch_grp  <= 0; 
                            row_cnt <= row_cnt + 1'b1; 
                        end
                    end
                end
            endcase
        end
    end

    reg [15:0] next_rd_mask;
    always @(*) begin
        if (!current_fifo_is_g1) begin 
            case (chunk_cnt)
                2'd0: next_rd_mask = 16'h0003;
                2'd1: next_rd_mask = 16'h000C;
                2'd2: next_rd_mask = 16'h0030;
                2'd3: next_rd_mask = 16'h00C0;
            endcase
        end else begin                 
            case (chunk_cnt)
                2'd0: next_rd_mask = 16'h0300;
                2'd1: next_rd_mask = 16'h0C00;
                2'd2: next_rd_mask = 16'h3000;
                2'd3: next_rd_mask = 16'hC000;
            endcase
        end
    end
    assign wdma_rd_en = issue_read ? next_rd_mask : 16'd0;

    wire [128:0] cmd_packet;
    assign cmd_packet[128]    = 1'b1;                                
    assign cmd_packet[127:41] = 87'd0;                               
    assign cmd_packet[40]     = is_last_transfer;
    assign cmd_packet[39:32]  = cur_burst_len - 1'b1;                
    assign cmd_packet[31:0]   = cur_addr;                            
    
    wire [128:0] dat_packet;
    assign dat_packet[128]    = 1'b0;                                
    assign dat_packet[127:0]  = obuf_rd_dat;                         

    assign mcif_valid = (state == ST_SEND_CMD) || dat_valid_r;
    assign mcif_data  = (state == ST_SEND_CMD) ? cmd_packet : dat_packet;
    
    //assign wdma_done = (state == ST_WAIT_DONE) && mcif_complete;
    
    // 改为：(注意要把端口声明的 output wire wdma_done 改为 output reg wdma_done)
    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         wdma_done <= 1'b0;
    //     end else begin
    //         // 只有在等待状态且收到完成握手时，拉高一拍
    //         if ((state == ST_WAIT_DONE) && mcif_complete) begin
    //             wdma_done <= 1'b1;
    //         end else begin
    //             wdma_done <= 1'b0;
    //         end
    //     end
    // end

    // ==========================================
    // 任务完成脉冲生成 (严格保证 1 周期高电平)
    // ==========================================
    reg wdma_done_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wdma_done_reg <= 1'b0;
        end else begin
            // 当状态机到达最后一步，且确认已经抓到过响应，拉高 done
            if (state == ST_WAIT_DONE && resp_caught) begin
                wdma_done_reg <= 1'b1;
            end else begin
                wdma_done_reg <= 1'b0;
            end
        end
    end
    
    assign wdma_done = wdma_done_reg;

endmodule