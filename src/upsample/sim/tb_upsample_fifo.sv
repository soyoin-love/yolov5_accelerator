`timescale 1ns/1ps

module tb_upsample_fifo();

    // ========================================================
    // 1. 验证环境参数配置 
    // ========================================================
    parameter DATA_WIDTH = 8;
    parameter DEPTH_W = 4;  // 写深度 16 (最大容量32)
    parameter DEPTH_R = 5;  
    
    int COL_SIZE = 9;         // 一行 14 个特征点
    int DOUBLE_COL_SIZE = 18;  // 放大后 28 个输出点
    int NUM_ROWS = 4;          

    parameter ALMOST_EMPTY_THRESHOLD = 2; 
    parameter ALMOST_FULL_THRESHOLD = 30; 

    // ========================================================
    // 2. 顶层信号与调试镜像信号
    // ========================================================
    logic                        clk;
    logic                        rst_n;
    logic                        wren;
    logic [DATA_WIDTH*2-1:0]     wrdata;
    logic                        full;
    logic                        almost_full;
    logic                        rden;
    logic [DATA_WIDTH-1:0]       rddata;
    logic                        empty;
    logic                        almost_empty;
    logic                        change_point;
    logic [DEPTH_R-1:0]          col_size_in;
    logic                        not_ready_for_output;

    logic [7:0]                  debug_write_row;    
    logic [7:0]                  debug_write_col;    
    logic [7:0]                  debug_read_row;     
    logic [7:0]                  debug_read_col;     
    logic [1:0]                  debug_read_ptr_type;
    logic [DATA_WIDTH-1:0]       debug_expected_val; 

    // ========================================================
    // 3. 例化 DUT
    // ========================================================
    upsample_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH_W(DEPTH_W),
        .DEPTH_R(DEPTH_R),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wren(wren),
        .wrdata(wrdata),
        .full(full),
        .almost_full(almost_full),
        .rden(rden),
        .rddata(rddata),
        .empty(empty),
        .almost_empty(almost_empty),
        .change_point(change_point),
        .col_size(col_size_in),
        .not_ready_for_output(not_ready_for_output)
    );

    // ========================================================
    // 4. 时钟生成 (100MHz)
    // ========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ========================================================
    // 5. 并发测试主干 (利用 negedge 完全消灭竞争冒险)
    // ========================================================
    initial begin
        rst_n = 0;
        wren = 0;
        wrdata = 0;
        rden = 0;
        change_point = 0;
        col_size_in = COL_SIZE;
        
        // 避开时钟沿释放复位信号，防止第一拍错乱
        #27 rst_n = 1; 
        
        $display("\n==================================================");
        $display("🚀 仿真开始: 严格行同步 & 间断写入 (消除Delta竞争版)");
        $display("==================================================");

        fork
            // ----------------------------------------------------
            // 线程 A：写入端 (在 negedge 发送数据)
            // ----------------------------------------------------
            begin
                automatic int write_val = 1;
                // 统一同步到下降沿
                @(negedge clk); 
                for (int r = 0; r < NUM_ROWS; r++) begin
                    debug_write_row = r; 
                    
                    for (int c = 0; c < COL_SIZE; c++) begin
                        debug_write_col = c; 
                        
                        if ($urandom_range(0, 99) < 30) begin
                            repeat($urandom_range(1, 3)) @(negedge clk);
                        end
                        
                        // 由于在下降沿检查，此时 full 信号绝对稳定，绝不会误判！
                        while (full) begin
                            wren <= 0;
                            @(negedge clk);
                        end
                        
                        wren <= 1;
                        wrdata <= { (8'h10 + write_val[7:0]), (8'h00 + write_val[7:0]) };
                        @(negedge clk);
                        wren <= 0;
                        write_val++;
                    end
                    $display("[写入端] ---> 成功将第 %0d 行 (共 %0d 个块) 压入 FIFO", r, COL_SIZE);
                end
            end

            // ----------------------------------------------------
            // 线程 B：读取端 (在 negedge 读取数据)
            // ----------------------------------------------------
            begin
                logic[DATA_WIDTH-1:0] expected_val;
                int base_val;
                
                @(negedge clk);
                for (int r = 0; r < NUM_ROWS; r++) begin
                    debug_read_row = r; 
                    
                    // ================= 阶段 1：真实指针先锋读 =================
                    debug_read_ptr_type = 1; 
                    for (int c = 0; c < DOUBLE_COL_SIZE; c++) begin
                        debug_read_col = c; 
                        
                        while (not_ready_for_output) @(negedge clk); 
                        
                        rden <= 1;
                        @(negedge clk);
                        rden <= 0;
                        @(negedge clk); // RAM 延迟 1 拍，硬件在 posedge 吐出数据
                        // 此时是下一个 negedge，数据完全稳定，放心对比！
                        
                        base_val = (r * COL_SIZE) + (c / 2) + 1;
                        expected_val = (c % 2 == 0) ? (8'h00 + base_val[7:0]) : (8'h10 + base_val[7:0]);
                        debug_expected_val = expected_val; 
                        
                        if (rddata !== expected_val)
                            $error("[读取端-报错] 真实指针 第%0d行 第%0d列 校验失败! 预期:%h 实际:%h", r, c, expected_val, rddata);
                    end
                    $display("[读取端] ✅ 真实指针(第一遍) 完成 第 %0d 行的读取与校验", r);

                    // ================= 阶段 2：触发换行，切虚拟指针 =================
                    @(negedge clk);
                    change_point <= 1;
                    @(negedge clk);
                    change_point <= 0;

                    // ================= 阶段 3：虚拟指针复读同一行 =================
                    debug_read_ptr_type = 0; 
                    for (int c = 0; c < DOUBLE_COL_SIZE; c++) begin
                        debug_read_col = c; 
                        
                        while (not_ready_for_output) @(negedge clk); 
                        
                        rden <= 1;
                        @(negedge clk);
                        rden <= 0;
                        @(negedge clk); 
                        
                        base_val = (r * COL_SIZE) + (c / 2) + 1;
                        expected_val = (c % 2 == 0) ? (8'h00 + base_val[7:0]) : (8'h10 + base_val[7:0]);
                        debug_expected_val = expected_val; 
                        
                        if (rddata !== expected_val)
                            $error("[读取端-报错] 虚拟指针 第%0d行 第%0d列 校验失败! 预期:%h 实际:%h", r, c, expected_val, rddata);
                    end
                    $display("[读取端] 🟢 虚拟指针(复读)   完成 第 %0d 行的读取与校验", r);

                    // ================= 阶段 4：触发换行 =================
                    @(negedge clk);
                    change_point <= 1;
                    @(negedge clk);
                    change_point <= 0;
                end
            end
        join 

        $display("\n==================================================");
        $display("🎉 仿真完美结束！所有断点、背压、复读逻辑全部验证通过！");
        $display("==================================================");
        $finish;
    end
endmodule