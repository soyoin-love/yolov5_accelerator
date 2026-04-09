`timescale 1ns / 1ps

module yolo_global_fsm (
    input  wire        clk,
    input  wire        rst_n,

    // ==========================================
    // AXI-Lite CSR 交互接口
    // ==========================================
    input  wire        ap_start,      // 软件写 1 触发 (单拍脉冲或电平)
    output reg         ap_done,       // 硬件完成中断 (单拍脉冲)
    output reg         ap_idle,       // 硬件空闲指示
    
    // 网络维度参数
    input  wire [15:0] cfg_h_out,     // 输出特征图总行数，用于比对权重重载次数
    input  wire [1:0]  cfg_op_mode,   // 0: convolution, 1: pooling, 2: residual add

    // ==========================================
    // 发往各子模块的发令枪 (Start Signals)
    // ==========================================
    output reg         w_cdma_start,
    output reg         f_cdma_start,
    output reg         b_cdma_start,
    output reg         buf_start,
    output reg         csc_start,
    output reg         cacc_start,
    output reg         pool_start,
    output reg         r_cdma_start,
    output reg         rbuf_start,
    output reg         resadd_start,
    output reg         obuf_start,
    output reg         wdma_start,

    // ==========================================
    // 接收各子模块的反馈信号 (Done Signals)
    // ==========================================
    input  wire        w_cdma_done,   // W_CDMA 单次搬运完成
    input  wire        b_cdma_done,   // (备用) B_CDMA 搬运完成
    input  wire        csc_row_done,  // CSC 算完一行的单拍脉冲
    input  wire        wdma_done      // WDMA 搬完所有数据并收到所有 BVALID
);

    // ==========================================
    // 状态机定义
    // ==========================================
    localparam ST_IDLE      = 3'd0;
    localparam ST_INIT_FIRE = 3'd1;
    localparam ST_RUNNING   = 3'd2;
    localparam ST_WAIT_DONE = 3'd3;

    localparam OP_CONV   = 2'd0;
    localparam OP_POOL   = 2'd1;
    localparam OP_RESADD = 2'd2;

    reg [2:0] state, next_state;

    // 内部控制寄存器
    reg [15:0] w_run_cnt;         // 记录权重已经加载的次数
    reg        w_cdma_busy;       // 追踪 W_CDMA 是否正在工作
    reg        w_reload_pending;  // 挂起标志：防止 csc_row_done 到来时 w_cdma 恰好还未 done 导致漏触发

    // ==========================================
    // 1. 状态流转 (State Transition)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= ST_IDLE;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        case (state)
            ST_IDLE: begin
                if (ap_start) 
                    next_state = ST_INIT_FIRE;
            end
            
            ST_INIT_FIRE: begin
                // 齐射发令枪仅维持 1 拍，随后立即进入稳态
                next_state = ST_RUNNING; 
            end
            
            ST_RUNNING: begin
                // 唯一退出条件：WDMA 彻底写完所有结果
                if (wdma_done) 
                    next_state = ST_WAIT_DONE; 
            end
            
            ST_WAIT_DONE: begin
                // 预留收尾周期，发出 ap_done 后回到 IDLE
                next_state = ST_IDLE;
            end
            
            default: next_state = ST_IDLE;
        endcase
    end

    // ==========================================
    // 2. 输出与内部计数器逻辑 (Outputs & Counters)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ap_done          <= 1'b0;
            ap_idle          <= 1'b1;
            w_cdma_start     <= 1'b0;
            f_cdma_start     <= 1'b0;
            b_cdma_start     <= 1'b0;
            buf_start        <= 1'b0;
            csc_start        <= 1'b0;
            cacc_start       <= 1'b0;
            pool_start       <= 1'b0;
            r_cdma_start     <= 1'b0;
            rbuf_start       <= 1'b0;
            resadd_start     <= 1'b0;
            obuf_start       <= 1'b0;
            wdma_start       <= 1'b0;
            
            w_run_cnt        <= 16'd0;
            w_cdma_busy      <= 1'b0;
            w_reload_pending <= 1'b0;
        end else begin
            // 默认清零脉冲信号
            w_cdma_start <= 1'b0;
            f_cdma_start <= 1'b0;
            b_cdma_start <= 1'b0;
            buf_start    <= 1'b0;
            csc_start    <= 1'b0;
            cacc_start   <= 1'b0;
            pool_start   <= 1'b0;
            r_cdma_start <= 1'b0;
            rbuf_start   <= 1'b0;
            resadd_start <= 1'b0;
            obuf_start   <= 1'b0;
            wdma_start   <= 1'b0;
            ap_done      <= 1'b0;

            // 监听 CSC 脉冲并存入挂起寄存器 (防止脉冲丢失)
            if (state == ST_RUNNING && (cfg_op_mode == OP_CONV) && csc_row_done) begin
                w_reload_pending <= 1'b1;
            end

            // 监听 W_CDMA 结束信号
            if (w_cdma_done) begin
                w_cdma_busy <= 1'b0;
            end

            case (state)
                ST_IDLE: begin
                    ap_idle          <= 1'b1;
                    w_run_cnt        <= 16'd0;
                    w_cdma_busy      <= 1'b0;
                    w_reload_pending <= 1'b0;
                end
                
                ST_INIT_FIRE: begin
                    ap_idle      <= 1'b0;
                    // 全局首次触发
                    f_cdma_start <= 1'b1;
                    buf_start    <= 1'b1;
                    obuf_start   <= 1'b1;
                    wdma_start   <= 1'b1;
                    
                    if (cfg_op_mode == OP_POOL) begin
                        pool_start  <= 1'b1;
                        w_cdma_busy <= 1'b0;
                        w_run_cnt   <= 16'd0;
                    end else if (cfg_op_mode == OP_RESADD) begin
                        // ResAdd only starts feature streams, RBUF, OBUF and WDMA.
                        r_cdma_start <= 1'b1;
                        rbuf_start   <= 1'b1;
                        resadd_start <= 1'b1;
                        w_cdma_busy  <= 1'b0;
                        w_run_cnt    <= 16'd0;
                    end else begin
                        b_cdma_start <= 1'b1;
                        csc_start    <= 1'b1;
                        cacc_start   <= 1'b1;

                        w_cdma_start <= 1'b1;
                        w_cdma_busy  <= 1'b1;
                        w_run_cnt    <= 16'd1;
                    end
                end

                ST_RUNNING: begin
                    // 【权重重载机制】
                    // 触发条件：有重载请求 pending + 当前不忙 + 还没超出行数限制
                    if (w_reload_pending && !w_cdma_busy && (w_run_cnt < cfg_h_out)) begin
                        w_cdma_start     <= 1'b1;
                        w_cdma_busy      <= 1'b1;
                        w_reload_pending <= 1'b0;          // 消耗掉挂起的请求
                        w_run_cnt        <= w_run_cnt + 1'b1;
                    end
                end

                ST_WAIT_DONE: begin
                    ap_done <= 1'b1; // 发出完成中断
                end
            endcase
        end
    end

endmodule
