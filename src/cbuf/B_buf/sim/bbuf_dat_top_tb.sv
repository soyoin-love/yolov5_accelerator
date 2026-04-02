`timescale 1ns / 1ps

module bbuf_dat_top_tb;

    // --- 参数定义 ---
    parameter BANK_NUM   = 8;
    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 9;
    parameter CLK_PERIOD = 10;

    // --- 信号声明 ---
    logic                   clk;
    logic                   rst_n;

    // 写接口 (B_CDMA)
    logic [BANK_NUM-1:0]    b_cdma_wr_en;
    logic [ADDR_WIDTH-1:0]  b_cdma_wr_addr;
    logic [BANK_NUM*64-1:0] b_cdma_wr_dat;

    // 读接口 (CACC)
    logic [BANK_NUM-1:0]    cacc_rd_en;
    logic [ADDR_WIDTH-1:0]  cacc_rd_addr;
    logic                   cacc_rd_vld;
    logic [BANK_NUM*64-1:0] cacc_rd_dat;

    // --- 参考模型 (Reference Model) ---
    // 用于记录预期的 RAM 状态，便于自动比对
    logic [DATA_WIDTH-1:0] ref_mem [0:BANK_NUM-1][0:(1<<ADDR_WIDTH)-1];

    // --- 例化 DUT ---
    bbuf_dat_top #(
        .BANK_NUM(BANK_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .b_cdma_wr_en   (b_cdma_wr_en),
        .b_cdma_wr_addr (b_cdma_wr_addr),
        .b_cdma_wr_dat  (b_cdma_wr_dat),
        .cacc_rd_en     (cacc_rd_en),
        .cacc_rd_addr   (cacc_rd_addr),
        .cacc_rd_vld    (cacc_rd_vld),
        .cacc_rd_dat    (cacc_rd_dat)
    );

    // --- 时钟生成 ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // ==========================================
    // 监测器 Monitor (严格上升沿触发)
    // ==========================================
    // generic_buf 的读操作有 1 拍延迟，需要打拍对齐掩码和地址
    logic [BANK_NUM-1:0]   rd_en_d1;
    logic [ADDR_WIDTH-1:0] rd_addr_d1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_en_d1   <= '0;
            rd_addr_d1 <= '0;
        end else begin
            rd_en_d1   <= cacc_rd_en;
            rd_addr_d1 <= cacc_rd_addr;
        end
    end

    // 自动数据比对逻辑
    always @(posedge clk) begin
        if (rst_n && (|rd_en_d1)) begin
            // 检查顶层 vld 信号是否正确生成
            if (!cacc_rd_vld) begin
                $error("[时间 %0t] [校验失败] 有读使能产生，但 cacc_rd_vld 为低！", $time);
            end

            // 仅校验掩码使能的 Bank
            for (int b = 0; b < BANK_NUM; b++) begin
                if (rd_en_d1[b]) begin
                    automatic logic [DATA_WIDTH-1:0] act_dat = cacc_rd_dat[b * DATA_WIDTH +: DATA_WIDTH];
                    automatic logic [DATA_WIDTH-1:0] exp_dat = ref_mem[b][rd_addr_d1];
                    if (act_dat !== exp_dat) begin
                        $error("[时间 %0t] [数据错误] 地址: %0d, Bank: %0d, 期望: %0h, 实际: %0h", 
                            $time, rd_addr_d1, b, exp_dat, act_dat);
                    end else begin
                        $display("[时间 %0t] [比对成功] 地址: %0d, Bank: %0d, 数据: %0h", 
                                $time, rd_addr_d1, b, act_dat);
                    end
                end
            end
        end
    end

    // ==========================================
    // 驱动任务 Tasks (严格下降沿触发)
    // ==========================================
    
    // 写缓冲任务
    task automatic do_write(input logic [ADDR_WIDTH-1:0] addr, input logic [BANK_NUM-1:0] mask);
        @(negedge clk);
        b_cdma_wr_en   <= mask;
        b_cdma_wr_addr <= addr;
        for (int b = 0; b < BANK_NUM; b++) begin
            if (mask[b]) begin
                automatic logic [DATA_WIDTH-1:0] valid_dat = {32'(addr), 32'(b)};
                b_cdma_wr_dat[b * DATA_WIDTH +: DATA_WIDTH] <= valid_dat;
                ref_mem[b][addr] = valid_dat; // 同步更新参考模型
            end else begin
                // 对未使能的通道注入脏数据，测试写入掩码的物理隔离性
                b_cdma_wr_dat[b * DATA_WIDTH +: DATA_WIDTH] <= 64'hDEAD_BEEF_DEAD_BEEF; 
            end
        end
        
        @(negedge clk);
        b_cdma_wr_en <= '0; // 撤销写操作
    endtask

    // 读缓冲任务
    task automatic do_read(input logic [ADDR_WIDTH-1:0] addr, input logic [BANK_NUM-1:0] mask);
        @(negedge clk);
        cacc_rd_en   <= mask;
        cacc_rd_addr <= addr;
        
        @(negedge clk);
        cacc_rd_en <= '0; // 撤销读操作
        // 注意：不在这里使用 wait 阻塞，因为 Monitor 线程会自动在后台处理比对
    endtask

    // ==========================================
    // 主测试流
    // ==========================================
    initial begin
        // 1. 系统初始化
        rst_n          = 1'b0;
        b_cdma_wr_en   = '0;
        b_cdma_wr_addr = '0;
        b_cdma_wr_dat  = '0;
        cacc_rd_en     = '0;
        cacc_rd_addr   = '0;

        for (int i = 0; i < BANK_NUM; i++)
            for (int j = 0; j < (1<<ADDR_WIDTH); j++)
                ref_mem[i][j] = '0;

        #(CLK_PERIOD * 2 + CLK_PERIOD / 4); // 错开边沿释放复位
        rst_n = 1'b1;
        $display("==== BBUF 模块仿真开始 ====");
        #(CLK_PERIOD * 2);

        // 场景 A: 满通道常规读写 (输出通道是 8 的倍数)
        $display("\n--- 场景 A: 满通道 (Mask 8'hFF) 写入与读取 ---");
        do_write(9'd10, 8'hFF);
        #(CLK_PERIOD * 2);
        do_read(9'd10, 8'hFF);
        #(CLK_PERIOD * 4);

        // 场景 B: 奇数通道或非8倍数 (例如只写低 3 个 Bank，Mask 8'b0000_0111)
        // 重点测试高位注入的 DEADBEEF 是否会污染 RAM
        $display("\n--- 场景 B: 局部通道 (Mask 8'h07) 掩码写入与读取 ---");
        do_write(9'd20, 8'h07);
        #(CLK_PERIOD * 2);
        do_read(9'd20, 8'h07);
        #(CLK_PERIOD * 4);

        // 场景 C: 互斥写入与完整读取测试 (测试 Bank 隔离)
        // 先写高 4 个 Bank，再写低 4 个 Bank，最后全读
        $display("\n--- 场景 C: 互斥写入与全掩码读取 ---");
        do_write(9'd30, 8'hF0); 
        #(CLK_PERIOD * 2);
        do_write(9'd30, 8'h0F); 
        #(CLK_PERIOD * 2);
        do_read(9'd30, 8'hFF);
        #(CLK_PERIOD * 4);

        // 场景 D: 极限场景 (连续流水线读写)
        $display("\n--- 场景 D: 背靠背无间隙连续操作 ---");
        do_write(9'd40, 8'hAA);
        do_write(9'd41, 8'h55);
        do_read(9'd40, 8'hAA);
        do_read(9'd41, 8'h55);
        #(CLK_PERIOD * 6);

        $display("\n==== 仿真测试结束 ====");
        $finish;
    end

endmodule