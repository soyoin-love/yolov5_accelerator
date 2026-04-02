`timescale 1ns / 1ps

module cdma_top_tb();

    // ==========================================
    // 1. 参数与信号定义
    // ==========================================
    parameter ROW_BLOCKS = 8;
    parameter TK_IN      = 8;
    parameter N          = 8;

    logic clk;
    logic rst_n;
    logic start;

    // CSR 配置
    logic [31:0] cfg_base_addr;
    logic [15:0] cfg_width;
    logic [15:0] cfg_height;
    logic [15:0] cfg_ch_groups;

    // CSC 交互
    logic        rd_row_free;
    logic [3:0]  rd_free_num;

    // MCIF AXI 请求端
    logic        mcif_req_rdy;
    logic        mcif_req_vld;
    logic [39:0] mcif_req_pd;

    // MCIF AXI 接收端
    logic        mcif_rx_vld;
    logic [127:0] mcif_rx_dat;
    logic        mcif_rx_rdy;

    // CBUF 写入端
    logic        wr_en;
    logic [15:0] wr_row;
    logic [15:0] wr_col;
    logic [15:0] wr_ch_grp;
    logic [127:0] wr_dat;
    logic        wr_row_done;

    // ==========================================
    // 2. DUT 例化
    // ==========================================
    cdma_top #(
        .ROW_BLOCKS(ROW_BLOCKS), .TK_IN(TK_IN), .N(N)
    ) dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .cfg_base_addr(cfg_base_addr), .cfg_width(cfg_width),
        .cfg_height(cfg_height), .cfg_ch_groups(cfg_ch_groups),
        .rd_row_free(rd_row_free), .rd_free_num(rd_free_num),
        .mcif_req_rdy(mcif_req_rdy), .mcif_req_vld(mcif_req_vld), .mcif_req_pd(mcif_req_pd),
        .mcif_rx_vld(mcif_rx_vld), .mcif_rx_dat(mcif_rx_dat), .mcif_rx_rdy(mcif_rx_rdy),
        .wr_en(wr_en), .wr_row(wr_row), .wr_col(wr_col),
        .wr_ch_grp(wr_ch_grp), .wr_dat(wr_dat), .wr_row_done(wr_row_done)
    );

    // ==========================================
    // 3. 时钟与复位生成
    // ==========================================
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 1; start = 0;
        rd_row_free = 0; rd_free_num = 0;
        #2  rst_n = 0; 
        #30 rst_n = 1; 
    end

    // ==========================================
    // 4. 数据结构与队列 (Scoreboard)
    // ==========================================
    // AXI 物理内存模型 (按 16 字节地址映射)
    logic [127:0] golden_mem [longint];   //longint 64位关联数组,动态分配内存
    // Checker 预期的 CBUF 写入数据
    logic [127:0] expected_cbuf [int][int][int]; 

    // AXI 请求队列
    typedef struct {
        longint addr;
        int     len;
    } axi_req_t;
    axi_req_t axi_req_q[$];

    // ==========================================
    // 5. 黄金模型初始化任务
    // ==========================================
    task automatic init_test(int w, int h, int cg, logic [31:0] base_addr);
        longint cur_addr = base_addr;
        logic [63:0] dat_even, dat_odd;
        
        // 清空历史数据
        golden_mem.delete();
        expected_cbuf.delete();
        axi_req_q.delete();

        // 模拟物理连续内存的生成
        for (int r = 0; r < h; r++) begin
            for (int cg_idx = 0; cg_idx < cg; cg_idx++) begin
                for (int c = 0; c < w; c += 2) begin
                    // 偶数像素定妆
                    dat_even = { 16'hB000 + 16'(c % 8), 16'(r), 16'(c), 16'(cg_idx) };
                    // 奇数像素定妆 (边界保护)
                    if (c + 1 < w) 
                        dat_odd = { 16'hB000 + 16'((c + 1) % 8), 16'(r), 16'(c + 1), 16'(cg_idx) };
                    else 
                        dat_odd = 64'd0;

                    golden_mem[cur_addr] = {dat_odd, dat_even};
                    expected_cbuf[r][c][cg_idx] = {dat_odd, dat_even};
                    
                    cur_addr += 16; // 步进 16 字节 (128-bit)
                end
            end
        end

        // 驱动 CSR 寄存器
        cfg_width = w;
        cfg_height = h;
        cfg_ch_groups = cg;
        cfg_base_addr = base_addr;

        // 打一拍 start 脉冲
        @(negedge clk);
        start <= 1;
        @(negedge clk);
        start <= 0;
    endtask

    // // ==========================================
    // // 6. 后台线程 A：AXI 读请求接收 (Slave Req)
    // // ==========================================
    // initial begin
    //     mcif_req_rdy = 0;
    //     forever begin
    //         @(negedge clk);
    //         // 模拟总线背压：80% 概率 Ready
    //         mcif_req_rdy <= ($urandom_range(0, 100) < 80); 
            
    //         if (mcif_req_vld && mcif_req_rdy) begin
    //             // ARLEN 是突发次数减 1，所以真实长度要 +1
    //             axi_req_q.push_back('{mcif_req_pd[31:0], mcif_req_pd[39:32] + 1});
    //         end
    //     end
    // end

    // ==========================================
    // 6. 后台线程 A：AXI 读请求接收 (Slave Req)
    // ==========================================
    
    //SV中激励可以在下降沿,但是监控一定要是在上升沿
    // 线程 A.1：产生背压激励 (在下降沿跳变，保证喂给硬件的建立保持时间)
    initial begin
        mcif_req_rdy = 0;
        forever begin
            @(negedge clk);
            mcif_req_rdy <= ($urandom_range(0, 100) < 80); 
        end
    end

    // 线程 A.2：抓取握手指令 (严格在上升沿与硬件同步采样！)
    always @(posedge clk) begin
        if (mcif_req_vld && mcif_req_rdy) begin
            axi_req_q.push_back('{mcif_req_pd[31:0], mcif_req_pd[39:32] + 1});
        end
    end

    // ==========================================
    // 7. 后台线程 B：AXI 数据响应发送 (Slave Resp)
    // ==========================================
    initial begin
        mcif_rx_vld = 0;
        mcif_rx_dat = 0;
        forever begin
            @(negedge clk);
            if (axi_req_q.size() > 0) begin
                automatic axi_req_t req = axi_req_q.pop_front();
                automatic longint current_send_addr = req.addr;

                for (int i = 0; i < req.len; i++) begin
                    mcif_rx_vld <= 1;
                    if (golden_mem.exists(current_send_addr))
                        mcif_rx_dat <= golden_mem[current_send_addr];
                    else
                        mcif_rx_dat <= 128'hDEADBEEF_DEADBEEF; // 越界访问报错值

                    // 等待 DUT 的 ready 握手 (必须严格在 negedge 判断)
                    do begin
                        @(negedge clk);
                    end while (mcif_rx_rdy !== 1'b1);

                    current_send_addr += 16;
                    mcif_rx_vld <= 0; // 成功发完一拍拉低

                    // 模拟 AXI 总线随机的数据停顿间隔
                    if ($urandom_range(0, 100) < 20) begin
                        repeat($urandom_range(1, 3)) @(negedge clk);
                    end
                end
            end
        end
    end

    // ==========================================
    // 8. 后台线程 C：CBUF 写入验证 (Scoreboard Checker)
    // ==========================================
    int total_beats_checked = 0;
    initial begin
        forever begin
            @(negedge clk);
            if (wr_en) begin
                automatic logic [127:0] exp_dat = expected_cbuf[wr_row][wr_col][wr_ch_grp];
                
                if (wr_dat !== exp_dat) begin
                    $display("\n=======================================================");
                    $display("[ERROR] 写入数据不匹配！时间: %0t", $time);
                    $display("坐标 -> 行: %0d, 列: %0d, 通道组: %0d", wr_row, wr_col, wr_ch_grp);
                    $display("预期 (Expected) : %x", exp_dat);
                    $display("实际 (Actual)   : %x", wr_dat);
                    $display("=======================================================\n");
                    $stop; 
                end else begin
                    total_beats_checked++;
                end
            end
        end
    end

    // ==========================================
    // 9. 辅助任务：模拟 CSC 释放 Credit 令牌
    // ==========================================
    task automatic simulate_csc(int total_h);
        int rows_done = 0;
        while (rows_done < total_h) begin
            @(negedge clk);
            // 捕捉到一整行写入完成
            if (wr_en && wr_row_done) begin
                rows_done++;
                // 派生一个不阻塞的独立线程去延迟释放令牌
                fork
                    begin
                        int delay = $urandom_range(5, 20); // 模拟 CSC 运算耗时
                        repeat(delay) @(negedge clk);
                        rd_row_free <= 1;
                        rd_free_num <= 1;
                        @(negedge clk);
                        rd_row_free <= 0;
                    end
                join_none
            end
        end
        $display("[INFO] 模拟 CSC 已成功释放全部 %0d 行的流控令牌！", total_h);
    endtask

    // ==========================================
    // 10. 主测试流程
    // ==========================================
    initial begin
        @(posedge rst_n);
        repeat(5) @(negedge clk);
        $display("\n=================== CDMA 仿真验证开始 ===================");

        // ---------------------------------------------------
        // Test Case 1: 经典偶数宽度层 (无长突发截断)
        // ---------------------------------------------------
        $display("\n--- [Test Case 1] W=32, H=10, ChGrp=2 ---");
        init_test(32, 10, 2, 32'h1000_0000);
        simulate_csc(10); // 阻塞等待所有行全部搬运完毕
        
        repeat(20) @(negedge clk);
        $display("[SUCCESS] Test Case 1 完美通过！已比对 %0d 拍数据。", total_beats_checked);
        total_beats_checked = 0;

        // ---------------------------------------------------
        // Test Case 2: 奇数宽度层 (严酷考验尾部对齐与死锁)
        // ---------------------------------------------------
        // $display("\n--- [Test Case 2] W=55, H=8, ChGrp=4 ---");
        // // 注意：此测试能否跑通，取决于你是否把 cdma_read_req.v 里的
        // // total_beats_per_line 公式改为了 (cfg_width+1) >> 1
        // init_test(55, 8, 4, 32'h2000_0000);
        // simulate_csc(8); 

        // repeat(20) @(negedge clk);
        // $display("[SUCCESS] Test Case 2 完美通过！已比对 %0d 拍数据。", total_beats_checked);
        // total_beats_checked = 0;

        // ---------------------------------------------------
        // Test Case 3: 超大图像 (考验 256 拍长突发自动切分逻辑)
        // ---------------------------------------------------
        $display("\n--- [Test Case 3] W=640, H=5, ChGrp=1 ---");
        // W=640 意味着一行有 320 拍，超过了 AXI 最大的 256 拍限制！
        // 这一关将验证你的请求发生器是否能自动切分成 256 + 64 两次请求！
        init_test(640, 5, 1, 32'h3000_0000);
        simulate_csc(5);

        repeat(20) @(negedge clk);
        $display("[SUCCESS] Test Case 3 完美通过！已比对 %0d 拍数据。", total_beats_checked);

        $display("\n=================== 所有仿真全部通过！太牛了！ ===================\n");
        $finish;
    end

endmodule