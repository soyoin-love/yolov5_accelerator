`timescale 1ns / 1ps

module cbuf_dat_top_tb();

    // ==========================================
    // 1. 信号定义与参数
    // ==========================================
    parameter BANK_NUM   = 8;
    parameter TK_IN      = 8;
    parameter N          = 8;
    parameter ADDR_WIDTH = 10;
    parameter ROW_BLOCKS = 8;

    logic clk;
    logic rst_n;
    logic start;

    // CSR 配置
    logic [ADDR_WIDTH-1:0] cfg_max_col_blocks;
    logic [ADDR_WIDTH-1:0] cfg_max_ch_groups;
    logic [3:0]            cfg_min_calc_rows;
    logic [15:0]           cfg_height; 

    // 写端口
    logic                  wr_en;
    logic [15:0]           wr_row;
    logic [15:0]           wr_col;
    logic [15:0]           wr_ch_grp;
    logic [127:0]          wr_dat;
    logic                  wr_row_done;
    logic                  cbuf_can_write;

    // 读端口 (【修改点1】位宽调整为 8-bit)
    logic [7:0]            rd_en;
    logic [15:0]           rd_row;
    logic [15:0]           rd_col_align;
    logic [15:0]           rd_ch_grp;
    logic                  rd_row_free;
    logic [3:0]            rd_free_num;
    logic                  cbuf_can_read;
    logic                  rd_dat_vld;
    logic [511:0]          rd_dat_out;

    // ==========================================
    // 2. DUT 例化
    // ==========================================
    cbuf_dat_top #(
        .BANK_NUM(BANK_NUM),
        .TK_IN(TK_IN),
        .N(N),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ROW_BLOCKS(ROW_BLOCKS)
    ) dut (
        .clk(clk), .rst_n(rst_n),.start(start),
        .cfg_max_col_blocks(cfg_max_col_blocks),
        .cfg_max_ch_groups(cfg_max_ch_groups),
        .cfg_min_calc_rows(cfg_min_calc_rows),
        .cfg_height(cfg_height),
        
        .wr_en(wr_en), .wr_row(wr_row), .wr_col(wr_col),
        .wr_ch_grp(wr_ch_grp), .wr_dat(wr_dat), .wr_row_done(wr_row_done),
        .cbuf_can_write(cbuf_can_write),
        
        .rd_en(rd_en), .rd_row(rd_row), .rd_col_align(rd_col_align),
        .rd_ch_grp(rd_ch_grp), .rd_row_free(rd_row_free), .rd_free_num(rd_free_num),
        .cbuf_can_read(cbuf_can_read), .rd_dat_vld(rd_dat_vld), .rd_dat_out(rd_dat_out)
    );

    // ==========================================
    // 3. 时钟与复位生成
    // ==========================================
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        #2  rst_n = 0; 
        #30 rst_n = 1;
    end

    // ==========================================
    // 4. 验证数据结构 (Scoreboard)
    // ==========================================
    logic [127:0] expected_mem [int][int][int];
    typedef struct {
        int r;
        int c;
        int cg;
        int w;
    } read_req_t;
    read_req_t req_queue[$];

    // ==========================================
    // 5. 激励任务：确定性地址写入 (保持不变)
    // ==========================================
    task automatic do_write(int w, int h, int cg);
        logic [127:0] current_dat;
        logic [63:0]  dat_even;
        logic [63:0]  dat_odd;

        for (int r = 0; r < h; r++) begin
            for (int cg_idx = 0; cg_idx < cg; cg_idx++) begin
                for (int c = 0; c < w; c += 2) begin
                    @(negedge clk);
                    while (!cbuf_can_write) @(negedge clk);

                    if ($urandom_range(0, 100) < 30) begin
                        wr_en <= 0;
                        repeat($urandom_range(1, 3)) @(negedge clk);
                    end

                    dat_even = { 16'(16'hB000 + (c % 8)),     r[15:0], 16'(c),         cg_idx[15:0] };
                    dat_odd  = { 16'(16'hB000 + (c % 8) + 1), r[15:0], 16'(c + 1),     cg_idx[15:0] };
                    current_dat = {dat_odd, dat_even}; 

                    wr_en <= 1;
                    wr_row <= r;
                    wr_col <= c;
                    wr_ch_grp <= cg_idx;
                    wr_dat <= current_dat;
                    
                    expected_mem[r][c][cg_idx] = current_dat;

                    if ((c + 2 >= w) && cg_idx == cg - 1) wr_row_done <= 1;
                    else wr_row_done <= 0;
                end
            end
            @(negedge clk);
            wr_en <= 0;
            wr_row_done <= 0;
        end
        $display("[PRODUCER] 所有 %0d 行图像写入任务已完成！", h);
    endtask

    // ==========================================
    // 6. 激励任务：读取请求
    // ==========================================
    task automatic do_read(int w, int h, int cg);
        logic [7:0] cur_rd_en; // 【新增】用于动态生成当前请求的 8-bit 掩码

        for (int r = 0; r < h; r++) begin
            @(negedge clk);
            while (!cbuf_can_read) @(negedge clk);

            for (int cg_idx = 0; cg_idx < cg; cg_idx++) begin
                for (int c = 0; c < w; c += 8) begin 
                    @(negedge clk);
                    if ($urandom_range(0, 100) < 30) begin
                        rd_en <= 8'h00; // 【修改点2】随机打断时清零全掩码
                        repeat($urandom_range(1, 3)) @(negedge clk);
                    end

                    // 【修改点3】根据越界情况，动态计算 8 个 Bank 的激活掩码
                    cur_rd_en = 8'h00;
                    for (int i = 0; i < 8; i++) begin
                        if (c + i < w) cur_rd_en[i] = 1'b1;
                    end

                    rd_en <= cur_rd_en;
                    rd_row <= r;
                    rd_col_align <= c;
                    rd_ch_grp <= cg_idx;
                    
                    req_queue.push_back('{r, c, cg_idx, w});
                end
            end
            @(negedge clk);
            rd_en <= 8'h00; // 【修改点4】单行读完后清零掩码

            rd_row_free <= 1;
            rd_free_num <= 1;
            @(negedge clk);
            rd_row_free <= 0;
        end
        $display("[CONSUMER] 所有 %0d 行图像读取请求已发完！", h);
    endtask

    
    // ==========================================
    // 7. 后台 Checker 线程
    // ==========================================
    initial begin
        forever begin
            @(negedge clk);
            if (rd_dat_vld) begin
                if (req_queue.size() > 0) begin
                    automatic read_req_t req = req_queue.pop_front();
                    logic [511:0] exp_data;
                    logic [511:0] mask; 
                    
                    exp_data = '0;
                    mask     = '0; 

                    if (req.c + 0 < req.w) begin 
                        exp_data[127:0] = expected_mem[req.r][req.c + 0][req.cg];
                        mask[127:0]     = '1; 
                    end
                    if (req.c + 2 < req.w) begin 
                        exp_data[255:128] = expected_mem[req.r][req.c + 2][req.cg];
                        mask[255:128]   = '1; 
                    end
                    if (req.c + 4 < req.w) begin 
                        exp_data[383:256] = expected_mem[req.r][req.c + 4][req.cg];
                        mask[383:256]   = '1; 
                    end
                    if (req.c + 6 < req.w) begin 
                        exp_data[511:384] = expected_mem[req.r][req.c + 6][req.cg];
                        mask[511:384]   = '1; 
                    end

                    if ((rd_dat_out & mask) !== (exp_data & mask)) begin
                        $display("\n=======================================================");
                        $display("[ERROR] 读数据不匹配！时间: %0t", $time);
                        $display("坐标 -> 行: %0d, 列首: %0d, 通道组: %0d", req.r, req.c, req.cg);
                        $display("预期 (Expected, Masked) :");
                        $display("%x", exp_data & mask);
                        $display("实际 (Actual, Masked)   :");
                        $display("%x", rd_dat_out & mask);
                        $display("=======================================================\n");
                        $stop;
                    end else begin
                        $display("[SUCCESS] T:%0t | 坐标(R:%0d, C:%0d, CG:%0d) 有效数据比对正确!", 
                                $time, req.r, req.c, req.cg);
                    end
                end
            end
        end
    end

    // ==========================================
    // 任务：运行一个完整的测试场景
    // ==========================================
    task automatic run_test_case(
        input int w,            // 图像宽度
        input int h,            // 图像高度
        input int cg,           // 通道组数 (Channel Groups)
        input int min_rows      // 启动计算所需的最小行数
    );
        $display("\n--- [启动场景] W=%0d, H=%0d, ChGrp=%0d, MinRows=%0d ---", w, h, cg, min_rows);
        
        // 1. 设置硬件配置信号
        cfg_max_col_blocks = (w + 7) / 8;
        cfg_max_ch_groups  = cg;
        cfg_min_calc_rows  = min_rows;
        cfg_height         = h;

        // 2. 触发 start 脉冲，复位 DUT 内部指针 
        start = 1;
        @(negedge clk); 
        start = 0;

        // 3. 清理上一轮的黄金模型数据
        req_queue.delete();
        expected_mem.delete();

        // 4. 并行启动读写激励
        fork
            do_write(w, h, cg);
            do_read(w, h, cg);
        join
        
        // 5. 等待所有读取比对完成
        wait(req_queue.size() == 0);
        repeat(10) @(negedge clk);
        $display("--- [场景结束] W=%0d 验证通过 ---\n", w);
    endtask

    // ==========================================
    // 8. 主测试流程
    // ==========================================
    initial begin
        // 系统初始化
        start = 0;
        wr_en = 0; rd_en = 8'h00;
        @(posedge rst_n);
        repeat(5) @(negedge clk);
        $display("\n=================== 自动化回归仿真开始 ===================");

        // 场景 1: YOLOv5-Nano 输入层 (大尺寸, 少通道)
        run_test_case(640, 640, 1, 8); 

        // 场景 2: 中间层特征图 (160x160, 多通道)
        run_test_case(160, 160, 4, 3);

        // 场景 3: 极小尺寸边界测试 (例如 8x8, 模拟对齐边缘)
        run_test_case(8, 8, 32, 1);

        // 场景 4: 极窄宽度测试 (宽度小于 8, 触发掩码逻辑) [cite: 418-422]
        run_test_case(4, 10, 2, 2);

        $display("\n=================== 所有回归测试全部通过！ ===================\n");
        $finish;
    end

endmodule