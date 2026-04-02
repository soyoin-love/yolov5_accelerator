`timescale 1ns / 1ps

module b_cdma_tb;

    // --- 参数定义 ---
    parameter CLK_PERIOD         = 10;
    parameter BANK_NUM           = 8;
    parameter AXI_DATA_WIDTH     = 128;
    parameter MAX_BURST_LEN      = 256;
    parameter LOG2_MAX_BURST_LEN = 8;
    parameter BBUF_ADDR_W        = 9;

    // --- 信号声明 ---
    logic                             clk;
    logic                             rst_n;
    logic                             start;
    logic                             done;

    logic [31:0]                      cfg_b_base_addr;
    logic [15:0]                      cfg_out_channels;

    logic                             rd_req_vld;
    logic                             rd_req_rdy;
    logic [31 + LOG2_MAX_BURST_LEN:0] rd_req_pd;

    logic                             rd_resp_vld;
    logic                             rd_resp_rdy;
    logic [AXI_DATA_WIDTH-1:0]        rd_resp_pd;

    logic [BANK_NUM-1:0]              bbuf_wr_en;
    logic [BBUF_ADDR_W-1:0]           bbuf_wr_addr;
    logic [BANK_NUM*64-1:0]           bbuf_wr_dat;

    // --- 验证平台内部结构 ---
    longint req_addr_q[$];
    int     req_len_q[$];
    
    // 模拟 BBUF 的存储，用于最终自动比对
    logic [63:0] ref_bbuf [0:BANK_NUM-1][0:(1<<BBUF_ADDR_W)-1];

    // --- 例化 DUT ---
    b_cdma_top #(
        .BANK_NUM(BANK_NUM),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .MAX_BURST_LEN(MAX_BURST_LEN),
        .LOG2_MAX_BURST_LEN(LOG2_MAX_BURST_LEN),
        .BBUF_ADDR_W(BBUF_ADDR_W)
    ) dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .start           (start),
        .done            (done),
        .cfg_b_base_addr (cfg_b_base_addr),
        .cfg_out_channels(cfg_out_channels),
        .rd_req_vld      (rd_req_vld),
        .rd_req_rdy      (rd_req_rdy),
        .rd_req_pd       (rd_req_pd),
        .rd_resp_vld     (rd_resp_vld),
        .rd_resp_rdy     (rd_resp_rdy),
        .rd_resp_pd      (rd_resp_pd),
        .bbuf_wr_en      (bbuf_wr_en),
        .bbuf_wr_addr    (bbuf_wr_addr),
        .bbuf_wr_dat     (bbuf_wr_dat)
    );

    // --- 时钟生成 ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // --- MCIF 请求接口随机反压与监测 (下降沿触发) ---
    
    // always @(negedge clk) begin
    //     if (!rst_n) begin
    //         rd_req_rdy <= 1'b0;
    //     end else begin
    //         // 随机模拟 MCIF 接收命令的反压，70% 概率 Ready
    //         rd_req_rdy <= ($urandom() % 100) < 70;
            
    //         // 采样到握手
    //         if (rd_req_vld && rd_req_rdy) begin
    //             automatic logic [7:0]  cmd_len  = rd_req_pd[39:32];
    //             automatic logic [31:0] cmd_addr = rd_req_pd[31:0];
    //             req_addr_q.push_back(cmd_addr);
    //             req_len_q.push_back(cmd_len);
    //             $display("[时间 %0t] [MCIF 接收命令] 起始地址: %0h, 突发长度减1: %0d", $time, cmd_addr, cmd_len);
    //         end
    //     end
    // end

    // --- MCIF 请求接口随机反压 (下降沿驱动) ---
    always @(negedge clk) begin
        if (!rst_n) begin
            rd_req_rdy <= 1'b0;
        end else begin
            // 随机模拟 MCIF 接收命令的反压，70% 概率 Ready
            rd_req_rdy <= ($urandom() % 100) < 70;
        end
    end

    // --- MCIF 请求接口状态监测 (上升沿监测) ---
    always @(posedge clk) begin
        if (rst_n && rd_req_vld && rd_req_rdy) begin
            automatic logic [7:0]  cmd_len  = rd_req_pd[39:32];
            automatic logic [31:0] cmd_addr = rd_req_pd[31:0];
            req_addr_q.push_back(cmd_addr);
            req_len_q.push_back(cmd_len);
            $display("[时间 %0t] [MCIF 接收命令] 起始地址: %0h, 突发长度减1: %0d", $time, cmd_addr, cmd_len);
        end
    end


    // --- MCIF 响应数据驱动线程 (后台执行) ---
    initial begin
        rd_resp_vld = 1'b0;
        rd_resp_pd  = '0;
        forever begin
            @(negedge clk);
            if (req_len_q.size() > 0) begin
                automatic longint cur_addr = req_addr_q.pop_front();
                automatic int     cur_len  = req_len_q.pop_front();
                
                for (int i = 0; i <= cur_len; i++) begin
                    // 模拟 DDR 读取延迟与数据链路反压 (0~2周期随机延迟)
                    automatic int delay = $urandom_range(0, 2);
                    repeat(delay) @(negedge clk);
                    
                    rd_resp_vld <= 1'b1;
                    // 数据与地址强映射：高64位=基址+8，低64位=基址
                    // 这样即使错位，也能一眼看出是哪个地址的数据写错了 Bank
                    rd_resp_pd  <= {cur_addr + 64'd8, cur_addr};
                    
                    @(negedge clk);
                    while (!(rd_resp_vld && rd_resp_rdy)) @(negedge clk);
                    rd_resp_vld <= 1'b0;
                    cur_addr += 16; // 1 beat = 16 bytes (128bit)
                end
            end
        end
    end

    // --- BBUF 写入行为监测 (上升沿监测) ---
    always @(posedge clk) begin
        if (rst_n && (|bbuf_wr_en)) begin
            for (int i = 0; i < BANK_NUM; i++) begin
                if (bbuf_wr_en[i]) begin
                    ref_bbuf[i][bbuf_wr_addr] = bbuf_wr_dat[i*64 +: 64];
                    // 关闭详细打印以防刷屏，调试时可打开
                    // $display("[时间 %0t] [BBUF 写入] Bank: %0d, Addr: %0d, 数据: %0h", $time, i, bbuf_wr_addr, bbuf_wr_dat[i*64 +: 64]);
                end
            end
        end
    end

    // --- 测试场景执行 Task ---
    task automatic run_test_case(input int channels, input logic [31:0] base_addr);
        automatic int total_beats = (channels + 1) / 2; // 向上取整
        automatic int expected_writes;
        
        $display("==========================================================");
        $display("[测试开始] 输出通道数: %0d, 需传输 Beat 数: %0d, DDR基址: %0h", channels, total_beats, base_addr);
        
        // 清理参考模型
        for (int i = 0; i < BANK_NUM; i++)
            for (int j = 0; j < (1<<BBUF_ADDR_W); j++)
                ref_bbuf[i][j] = 64'h0;

        // 发送启动命令 (下降沿驱动避开时钟边沿)
        @(negedge clk);
        cfg_out_channels <= channels;
        cfg_b_base_addr  <= base_addr;
        start            <= 1'b1;
        @(negedge clk);
        start            <= 1'b0;

        // 等待结束
        @(posedge clk);
        while (!done) @(posedge clk);
        $display("[时间 %0t] [模块报告完成] 准备进行数据一致性校验...", $time);

        // --- 校验逻辑 ---
        // 根据路由逻辑推导：每 4 拍占一个地址
        for (int beat = 0; beat < total_beats; beat++) begin
            automatic int   addr_idx = beat / 4;
            automatic int   bank_grp = beat % 4; // 0,1,2,3 分别对应 bank 01, 23, 45, 67
            automatic logic [63:0] expected_data_low  = base_addr + beat * 16;
            automatic logic [63:0] expected_data_high = base_addr + beat * 16 + 8;
            
            automatic int bank_low  = bank_grp * 2;
            automatic int bank_high = bank_grp * 2 + 1;

            if (ref_bbuf[bank_low][addr_idx] !== expected_data_low) begin
                $error("[校验失败] Beat: %0d, Bank: %0d, Addr: %0d, 期望: %0h, 实际: %0h", 
                        beat, bank_low, addr_idx, expected_data_low, ref_bbuf[bank_low][addr_idx]);
            end
            
            // 针对奇数通道的特殊处理：最后一拍的最高 64-bit 可能在协议层面被视为无意义(或被CACC掩码忽略)，
            // 但根据目前代码 `bbuf_wr_dat = {4{rd_resp_pd}}`，无论偶奇，都会原样写入。因此校验同样需通过。
            if (ref_bbuf[bank_high][addr_idx] !== expected_data_high) begin
                $error("[校验失败] Beat: %0d, Bank: %0d, Addr: %0d, 期望: %0h, 实际: %0h", 
                        beat, bank_high, addr_idx, expected_data_high, ref_bbuf[bank_high][addr_idx]);
            end
        end
        $display("[测试通过] 所有期望的数据映射已正确写入 BBUF！");
        $display("==========================================================\n");
    endtask

    // --- 主测试流程 ---
    initial begin
        // 1. 系统复位
        rst_n = 1'b0;
        start = 1'b0;
        cfg_out_channels = '0;
        cfg_b_base_addr  = '0;
        
        // 错位复位释放 (确保避开上升沿和下降沿)
        #(CLK_PERIOD * 3 + CLK_PERIOD / 4);
        rst_n = 1'b1;
        $display("[系统初始化] 复位已释放");
        #(CLK_PERIOD * 5);

        // 2. 依次执行测试场景
        // 场景 a: 常规对齐 (32通道，16 beats，恰好被8整除)
        run_test_case(.channels(32), .base_addr(32'h1000_0000));

        // 场景 b: 奇数通道 (15通道，8 beats，通道数%8余7，不为偶数)
        run_test_case(.channels(15), .base_addr(32'h2000_0000));

        // 场景 c: 非8倍数通道 (18通道，9 beats，最后余2个通道，存在掩码留空)
        run_test_case(.channels(18), .base_addr(32'h3000_0000));

        // 场景 d: 大数据量极限跨界 (600通道，300 beats，跨越 256 beats 边界)
        run_test_case(.channels(600), .base_addr(32'h4000_0000));

        // 场景 e: 极小数据量边界 (1通道，1 beat)
        run_test_case(.channels(1), .base_addr(32'h5000_0000));

        #(CLK_PERIOD * 10);
        $display("[完成] 仿真测试流程结束。");
        $finish;
    end

endmodule