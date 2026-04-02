`timescale 1ns / 1ps


//加了新端口注意
module obuf_dat_top_tb();

    // ==========================================
    // 1. 参数化配置
    // ==========================================
    parameter BANK_NUM    = 8;
    parameter DATA_WIDTH  = 64;
    parameter ADDR_WIDTH  = 8;
    parameter TEST_ROUNDS = 50; // 测试的 CACC 写回次数 (每次写回 2 行)

    // ==========================================
    // 2. 信号声明
    // ==========================================
    logic                               clk;
    logic                               rst_n;
    logic                               start;

    // 写侧接口
    logic                               cacc_wr_vld;   
    logic [BANK_NUM*128-1:0]            cacc_wr_dat;   
    logic                               obuf_can_write;

    // 读侧接口
    logic [BANK_NUM-1:0]                wdma_rd_en;
    logic                               wdma_rd_next_addr;
    logic                               obuf_can_read;
    logic                               obuf_rd_vld;
    logic [127:0]                       obuf_rd_dat;

    // 验证计分板变量
    int unsigned expected_wr_row = 0;
    int unsigned expected_rd_row = 0;
    int unsigned read_chunk_cnt  = 0;

    // ==========================================
    // 3. DUT 例化
    // ==========================================
    obuf_dat_top #(
        .BANK_NUM   (BANK_NUM),
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .start             (start),
        
        .cacc_wr_vld       (cacc_wr_vld),
        .cacc_wr_dat       (cacc_wr_dat),
        .obuf_can_write    (obuf_can_write),
        
        .wdma_rd_en        (wdma_rd_en),
        .wdma_rd_next_addr (wdma_rd_next_addr),
        .obuf_can_read     (obuf_can_read),
        .obuf_rd_vld       (obuf_rd_vld),
        .obuf_rd_dat       (obuf_rd_dat)
    );

    // ==========================================
    // 4. 时钟与安全复位 (避开时钟边沿)
    // ==========================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 100MHz
    end

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        // 延迟 13ns，避开 5ns/10ns/15ns 的时钟跳变沿
        #13 rst_n = 1'b1;
        
        #27;
        @(negedge clk);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
    end

    // ==========================================
    // 5. 写激励线程 (CACC 生产者) - 下降沿驱动
    // ==========================================
    initial begin
        // 将所有局部变量声明置于块顶部
        int delay_cycles;
        logic [63:0] dat_low;
        logic [63:0] dat_high;

        cacc_wr_vld = 1'b0;
        cacc_wr_dat = '0;

        // 等待复位与 start 结束
        @(posedge rst_n);
        @(negedge start);

        for (int i = 0; i < TEST_ROUNDS; i++) begin
            delay_cycles = $urandom_range(0, 5); // 随机反压模拟
            
            repeat(delay_cycles) @(negedge clk);

            // 构造强地址绑定的 1024-bit 测试数据
            // 低 64-bit 存入当前行，高 64-bit 存入下一行。内容为 {32位行号, 32位Bank号}
            for (int b = 0; b < BANK_NUM; b++) begin
                dat_low  = {32'(expected_wr_row),     32'(b)};
                dat_high = {32'(expected_wr_row + 1), 32'(b)};
                
                cacc_wr_dat[b*128 + 63  -: 64] = dat_low;
                cacc_wr_dat[b*128 + 127 -: 64] = dat_high;
            end

            // 握手写入
            cacc_wr_vld = 1'b1;
            @(negedge clk);
            while (!obuf_can_write) @(negedge clk); // 等待 OBUF 准备好
            cacc_wr_vld = 1'b0;
            
            expected_wr_row += 2; // 每次 CACC 写回意味着压入了 2 行数据
        end
    end

    // ==========================================
    // 6. 读激励线程 (WDMA 消费者) - 下降沿驱动
    // ==========================================
    initial begin
        // 将所有局部变量声明置于块顶部
        int rd_delay;
        int page_delay;

        wdma_rd_en        = 8'd0;
        wdma_rd_next_addr = 1'b0;

        @(posedge rst_n);
        @(negedge start);

        // 总共需要读出 TEST_ROUNDS * 2 行
        while (expected_rd_row < TEST_ROUNDS * 2) begin
            @(negedge clk);
            
            if (obuf_can_read) begin
                // 一行数据需要通过 128-bit 总线分 4 次 (Chunk) 读完
                for (int chunk = 0; chunk < 4; chunk++) begin
                    rd_delay = $urandom_range(0, 3); // 模拟 AXI 总线忙碌
                    repeat(rd_delay) @(negedge clk);

                    // 驱动掩码：0000_0011 -> 0000_1100 -> 0011_0000 -> 1100_0000
                    wdma_rd_en = 8'b0000_0011 << (chunk * 2);
                    @(negedge clk);
                    wdma_rd_en = 8'd0; // 恢复静默，节省功耗
                end

                // 一行读取完毕，发出翻页脉冲
                page_delay = $urandom_range(0, 2);
                repeat(page_delay) @(negedge clk);
                
                wdma_rd_next_addr = 1'b1;
                @(negedge clk);
                wdma_rd_next_addr = 1'b0;
                
                expected_rd_row++;
            end
        end
        
        // 测试完成
        #100;
        $display("\n========================================");
        $display(" OBUF VERIFICATION PASSED SUCCESSFULLY! ");
        $display(" Total Rows Processed: %0d", expected_rd_row);
        $display("========================================\n");
        $finish;
    end

    // ==========================================
    // 7. 数据比对线程 (自动计分板) - 上升沿采样
    // ==========================================
    always @(posedge clk) begin
        // 声明置于块顶部
        logic [31:0] act_row_0, act_bank_0;
        logic [31:0] act_row_1, act_bank_1;

        if (rst_n && obuf_rd_vld) begin
            // 提取双 Bank 拼接出来的数据 (128-bit)
            // Bank N+1 在高位，Bank N 在低位
            act_row_0  = obuf_rd_dat[63:32];
            act_bank_0 = obuf_rd_dat[31:0];
            
            act_row_1  = obuf_rd_dat[127:96];
            act_bank_1 = obuf_rd_dat[95:64];

            // 调试打印
            $display("[%0t ns] READ VALID | Row: %0d | Banks: %0d & %0d", 
                    $time, act_row_0, act_bank_0, act_bank_1);

            // 严格校验
            if (act_row_0 != act_row_1) begin
                $error("[%0t ns] MISMATCH! 128-bit trunk contains different rows: %0d and %0d", 
                    $time, act_row_0, act_row_1);
                $stop;
            end
            
            if (act_bank_1 != act_bank_0 + 1) begin
                $error("[%0t ns] MISMATCH! Banks are not consecutive: %0d and %0d", 
                    $time, act_bank_0, act_bank_1);
                $stop;
            end

            // 校验是否符合顺序读取期望
            if (act_bank_0 != (read_chunk_cnt % 4) * 2) begin
                $error("[%0t ns] OUT OF ORDER! Expected Bank %0d, got %0d", 
                       $time, (read_chunk_cnt % 4) * 2, act_bank_0);
                $stop;
            end

            read_chunk_cnt++;
        end
    end

    // ==========================================
    // 8. 仿真超时看门狗
    // ==========================================
    initial begin
        #500000;
        $error("Simulation Timeout! Pipeline might be deadlocked.");
        $finish;
    end

endmodule