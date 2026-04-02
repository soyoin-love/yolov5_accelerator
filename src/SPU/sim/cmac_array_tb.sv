`timescale 1ns / 1ps

module cmac_array_tb();

    // ==========================================
    // 1. 参数与信号定义
    // ==========================================
    parameter ROW_NUM = 8;
    parameter COL_NUM = 8;
    parameter N       = 8;
    parameter TK_IN   = 8;
    parameter TK_OUT  = 16;
    parameter OUT_W   = 19;
    
    logic                               clk;
    logic                               rst_n;

    logic [ROW_NUM*TK_IN*N-1:0]         features_in;
    logic [COL_NUM*2*TK_IN*N-1:0]       weights_in;

    logic                               mac_valid_in;
    logic [7:0]                         mac_pixel_mask_in;
    logic [15:0]                        mac_co_grp_in;
    logic                               mac_is_last_ci_in;

    logic [ROW_NUM*TK_OUT*OUT_W-1:0]    psum_out;
    logic                               mac_valid_out;
    logic [7:0]                         mac_pixel_mask_out;
    logic [15:0]                        mac_co_grp_out;
    logic                               mac_is_last_ci_out;

    logic                               cacc_ready;   
    logic                               mac_buf_ready;

    // ==========================================
    // 2. DUT 例化
    // ==========================================
    cmac_array #(
        .ROW_NUM(ROW_NUM), .COL_NUM(COL_NUM), .N(N),
        .TK_IN(TK_IN), .TK_OUT(TK_OUT), .OUT_W(OUT_W)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .features_in(features_in), .weights_in(weights_in),
        .mac_valid_in(mac_valid_in), .mac_pixel_mask_in(mac_pixel_mask_in),
        .mac_co_grp_in(mac_co_grp_in), .mac_is_last_ci_in(mac_is_last_ci_in),
        .psum_out(psum_out),
        .mac_valid_out(mac_valid_out), .mac_pixel_mask_out(mac_pixel_mask_out),
        .mac_co_grp_out(mac_co_grp_out), .mac_is_last_ci_out(mac_is_last_ci_out),
        .cacc_ready(cacc_ready), .mac_buf_ready(mac_buf_ready)
    );

    // ==========================================
    // 3. 时钟与异步复位 (精确错开边沿)
    // ==========================================
    always #5 clk = ~clk; // 10ns 周期，跳变沿在 0, 5, 10...

    initial begin
        clk = 0;
        rst_n = 1;
        #3  rst_n = 0; // 在 3ns 复位，避开边沿
        #14 rst_n = 1; // 在 17ns 释放复位，避开边沿
    end

    // ==========================================
    // 4. 软件 Golden Model 结构
    // ==========================================
    typedef logic signed [N-1:0] feat_arr_t [ROW_NUM][TK_IN];
    typedef logic signed [N-1:0] wt_arr_t   [TK_OUT][TK_IN];

    typedef struct {
        logic signed [OUT_W-1:0] psum [ROW_NUM][TK_OUT];
        logic [7:0]              mask;
        logic [15:0]             co_grp;
        logic                    last_ci;
    } exp_res_t;

    exp_res_t exp_queue[$];

    // ==========================================
    // 5. 核心驱动与计算 Task
    // ==========================================
    task automatic calc_golden(
        input feat_arr_t f_mat,
        input wt_arr_t   w_mat,
        input logic [7:0]  mask,
        input logic [15:0] co_grp,
        input logic        last_ci
    );
        automatic exp_res_t exp;
        exp.mask    = mask;
        exp.co_grp  = co_grp;
        exp.last_ci = last_ci;

        for (int r = 0; r < ROW_NUM; r++) begin
            for (int oc = 0; oc < TK_OUT; oc++) begin
                automatic int temp_sum = 0;
                for (int ic = 0; ic < TK_IN; ic++) begin
                    temp_sum += f_mat[r][ic] * w_mat[oc][ic];
                end
                exp.psum[r][oc] = temp_sum[OUT_W-1:0];
            end
        end
        exp_queue.push_back(exp);
    endtask

    task automatic drive_stimulus(
        input feat_arr_t f_mat,
        input wt_arr_t   w_mat,
        input logic [7:0]  mask,
        input logic [15:0] co_grp,
        input logic        last_ci
    );
        calc_golden(f_mat, w_mat, mask, co_grp, last_ci);

        @(negedge clk); // 下降沿驱动
        mac_valid_in      <= 1'b1;
        mac_pixel_mask_in <= mask;
        mac_co_grp_in     <= co_grp;
        mac_is_last_ci_in <= last_ci;

        for (int r = 0; r < ROW_NUM; r++) begin
            for (int ic = 0; ic < TK_IN; ic++) begin
                features_in[(r*TK_IN + ic)*N +: N] <= f_mat[r][ic];
            end
        end

        for (int c = 0; c < COL_NUM; c++) begin
            for (int ic = 0; ic < TK_IN; ic++) begin
                weights_in[(c*2*TK_IN + ic)*N +: N]           <= w_mat[2*c][ic];
                weights_in[(c*2*TK_IN + TK_IN + ic)*N +: N]   <= w_mat[2*c+1][ic];
            end
        end
    endtask

    task automatic drive_idle();
        @(negedge clk);
        mac_valid_in <= 1'b0;
    endtask

    // ==========================================
    // 6. 验证流编排
    // ==========================================
    initial begin
        automatic feat_arr_t f_test;
        automatic wt_arr_t   w_test;

        features_in = '0; weights_in = '0;
        mac_valid_in = 0; mac_pixel_mask_in = 0; mac_co_grp_in = 0; mac_is_last_ci_in = 0;
        cacc_ready = 1;

        @(posedge rst_n);
        repeat(5) @(negedge clk);
        $display("\n[TEST] 仿真开始...");

        // --- 测试场景 1: 基础通路 ---
        for (int r = 0; r < ROW_NUM; r++) 
            for (int ic = 0; ic < TK_IN; ic++) f_test[r][ic] = $urandom_range(0, 255) - 128;
        for (int oc = 0; oc < TK_OUT; oc++) 
            for (int ic = 0; ic < TK_IN; ic++) w_test[oc][ic] = $urandom_range(0, 255) - 128;
        drive_stimulus(f_test, w_test, 8'hFF, 16'd1, 1'b0);
        drive_idle();

        // --- 测试场景 2: 极值防溢出 ---
        for (int r = 0; r < ROW_NUM; r++) 
            for (int ic = 0; ic < TK_IN; ic++) f_test[r][ic] = -128;
        for (int oc = 0; oc < TK_OUT; oc++) 
            for (int ic = 0; ic < TK_IN; ic++) w_test[oc][ic] = -128;
        drive_stimulus(f_test, w_test, 8'h55, 16'd2, 1'b1);
        drive_idle();

        // --- 测试场景 3: 连续背靠背数据流测试 ---
        $display("[TEST] 开始背靠背连续 20 拍压测...");
        for (int step = 0; step < 20; step++) begin
            for (int r = 0; r < ROW_NUM; r++) 
                for (int ic = 0; ic < TK_IN; ic++) f_test[r][ic] = $urandom_range(0, 255) - 128;
            for (int oc = 0; oc < TK_OUT; oc++) 
                for (int ic = 0; ic < TK_IN; ic++) w_test[oc][ic] = $urandom_range(0, 255) - 128;
            
            drive_stimulus(f_test, w_test, 8'hAA, 16'd100 + step[15:0], 1'b0);
        end
        drive_idle();

        // --- 排空与安全检查 ---
        $display("[TEST] 所有激励下发完毕，等待队列校验清空...");
        
        fork
            begin
                // 正常的退出路径：一直等到预期队列比对为空
                wait(exp_queue.size() == 0);
            end
            begin
                // 超时强制退出路径：防挂死
                repeat(100) @(negedge clk);
                $display("\n[FATAL] 仿真超时！队列中仍有 %0d 个预期结果未完成比对，可能发生数据丢失。", exp_queue.size());
                $stop;
            end
        join_any
        disable fork; // 清除未触发的线程

        repeat(5) @(negedge clk);
        $display("\n=======================================================");
        $display("[SUCCESS] 完美！所有阵列计算和管道均验证通过。");
        $display("=======================================================\n");
        $finish;
    end

    // ==========================================
    // 7. Checker / Monitor (上升沿采样对比)
    // ==========================================
    always @(posedge clk) begin
        if (rst_n && mac_valid_out) begin
            if (exp_queue.size() == 0) begin
                $error("[FATAL] 硬件输出了 valid 信号，但软件预期队列为空！时间：%0t", $time);
                $stop;
            end else begin
                automatic exp_res_t exp = exp_queue.pop_front();
                automatic logic mismatch = 0;

                if (mac_pixel_mask_out !== exp.mask || mac_co_grp_out !== exp.co_grp || mac_is_last_ci_out !== exp.last_ci) begin
                    $display("[ERROR] 控制信号未对齐！时间：%0t", $time);
                    mismatch = 1;
                end

                for (int r = 0; r < ROW_NUM; r++) begin
                    for (int oc = 0; oc < TK_OUT; oc++) begin
                        automatic logic signed [OUT_W-1:0] act_psum = psum_out[(r*TK_OUT + oc)*OUT_W +: OUT_W];
                        
                        if (act_psum !== exp.psum[r][oc]) begin
                            $display("[ERROR] T=%0t | 数据错误 -> 行:%0d, 输出通道:%0d | 预期:%d, 实际:%d", 
                                    $time, r, oc, exp.psum[r][oc], act_psum);
                            mismatch = 1;
                        end
                    end
                end

                if (!mismatch) begin
                    $display("[SUCCESS] T=%0t | Psum 比对通过! (Co_Grp=%0d, 剩余待校验: %0d)", 
                            $time, mac_co_grp_out, exp_queue.size());
                end else begin
                    $display("=================================================");
                    $stop; 
                end
            end
        end
    end

endmodule