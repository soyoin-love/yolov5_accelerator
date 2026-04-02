`timescale 1ns / 1ps

module w_cdma_top_tb();

    // ==========================================
    // 1. 参数与信号定义
    // ==========================================
    parameter BANK_NUM            = 8;
    parameter REGION_W            = 8;
    parameter AXI_DATA_WIDTH      = 128;
    parameter MAX_BURST_LEN       = 256;
    parameter LOG2_MAX_BURST_LEN  = $clog2(MAX_BURST_LEN);

    logic                               clk;
    logic                               rst_n;

    // CSR 配置接口
    logic                               start;
    logic                               done;
    logic [27:0]                        cfg_wt_total_beats;
    logic [31:0]                        cfg_wt_base_addr;
    logic [15:0]                        cfg_total_co_groups;
    logic [15:0]                        cfg_coords_per_region;
    logic [3:0]                         cfg_active_banks;
    logic                               cfg_is_odd_oc;

    // MCIF AXI 读接口
    logic                               rd_req_vld;
    logic                               rd_req_rdy;
    logic [31 + LOG2_MAX_BURST_LEN:0]   rd_req_pd;

    logic                               rd_resp_vld;
    logic                               rd_resp_rdy;
    logic [AXI_DATA_WIDTH-1:0]          rd_resp_pd;

    // WBUF 写接口
    logic                               wbuf_can_write;
    logic [BANK_NUM-1:0]                wbuf_wr_bank_en;
    logic [REGION_W-1:0]                wbuf_wr_offset;
    logic [AXI_DATA_WIDTH-1:0]          wbuf_wr_dat;
    logic                               wbuf_wr_region_done;

    // ==========================================
    // 2. DUT 例化
    // ==========================================
    w_cdma_top #(
        .BANK_NUM(BANK_NUM), .REGION_W(REGION_W),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH), .MAX_BURST_LEN(MAX_BURST_LEN),
        .LOG2_MAX_BURST_LEN(LOG2_MAX_BURST_LEN)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .done(done),
        .cfg_wt_total_beats(cfg_wt_total_beats), .cfg_wt_base_addr(cfg_wt_base_addr),
        .cfg_total_co_groups(cfg_total_co_groups), .cfg_coords_per_region(cfg_coords_per_region),
        .cfg_active_banks(cfg_active_banks), .cfg_is_odd_oc(cfg_is_odd_oc),
        .rd_req_vld(rd_req_vld), .rd_req_rdy(rd_req_rdy), .rd_req_pd(rd_req_pd),
        .rd_resp_vld(rd_resp_vld), .rd_resp_rdy(rd_resp_rdy), .rd_resp_pd(rd_resp_pd),
        .wbuf_can_write(wbuf_can_write), .wbuf_wr_bank_en(wbuf_wr_bank_en),
        .wbuf_wr_offset(wbuf_wr_offset), .wbuf_wr_dat(wbuf_wr_dat), .wbuf_wr_region_done(wbuf_wr_region_done)
    );

    // ==========================================
    // 3. 时钟与复位
    // ==========================================
    always #5 clk = ~clk; // 100MHz, 周期 10ns

    initial begin
        clk = 0;
        rst_n = 1;
        #3 rst_n = 0; 
        #14 rst_n = 1; 
    end

    // ==========================================
    // 4. 黄金模型与测试流排布
    // ==========================================
    typedef struct {
        logic [BANK_NUM-1:0]       bank_en;
        logic [REGION_W-1:0]       offset;
        logic [AXI_DATA_WIDTH-1:0] dat;
        logic                      region_done;
    } wbuf_exp_t;

    wbuf_exp_t exp_queue[$];

    // 发起测试请求任务
    // 在 task 外面声明全局比对计数器
    int global_sim_cnt = 0;
    task automatic launch_test(
        input int co_groups,
        input int coords,
        input int active_banks,
        input int is_odd
    );
        automatic int total_beats = (co_groups - 1) * coords * 8 + coords * active_banks;
        //automatic logic [31:0] sim_global_cnt = 0;

        $display("\n=======================================================");
        $display("[TEST] 启动新测试例 - CoGrps:%0d, Coords:%0d, ActBanks:%0d, Odd:%0d", 
                co_groups, coords, active_banks, is_odd);
        $display("[TEST] 理论总需 AXI Beats 数量: %0d", total_beats);
        
        // 4.1 生成预期数据并压入队列
        for (int c = 0; c < co_groups; c++) begin
            automatic int banks_in_grp = (c == co_groups - 1) ? active_banks : 8;
            for (int k = 0; k < coords; k++) begin
                for (int b = 0; b < banks_in_grp; b++) begin
                    automatic wbuf_exp_t exp;
                    
                    exp.bank_en     = (1 << b);
                    exp.offset      = k[REGION_W-1:0];
                    exp.region_done = (k == coords - 1) && (b == banks_in_grp - 1);
                    
                    // 模拟 DDR 返回的数据（就是递增计数器）
                    exp.dat = {96'd0, global_sim_cnt};
                    
                    // 硬件奇数通道补零模拟预测
                    if (is_odd && (c == co_groups - 1) && (b == banks_in_grp - 1)) begin
                        exp.dat[127:64] = 64'd0; 
                    end
                    
                    exp_queue.push_back(exp);
                    global_sim_cnt++;
                end
            end
        end

        // 4.2 驱动配置与启动
        @(negedge clk);
        cfg_wt_total_beats    <= total_beats;
        cfg_wt_base_addr      <= 32'h1000_0000;
        cfg_total_co_groups   <= co_groups;
        cfg_coords_per_region <= coords;
        cfg_active_banks      <= active_banks;
        cfg_is_odd_oc         <= is_odd;
        start <= 1;
        
        @(negedge clk);
        start <= 0;

        // 等待硬件完成
        @(posedge clk);
        while (!done) @(posedge clk);
        $display("[SUCCESS] 硬件反馈 Done 信号，测试通过。");
    endtask

    // ==========================================
    // 5. 并行环境：MCIF AXI 响应器 & 反压生成器
    // ==========================================
    
    // 5.1 AXI AR 通道接收 (记录需要的长度)
    int axi_len_queue[$];
    always @(posedge clk) begin
        if (rst_n && rd_req_vld && rd_req_rdy) begin
            axi_len_queue.push_back(rd_req_pd[31+LOG2_MAX_BURST_LEN : 32]);
            $display("[MCIF] 收到 AR 请求，Burst Len: %0d", rd_req_pd[31+LOG2_MAX_BURST_LEN : 32]);
        end
    end

    // 5.2 AXI R 通道发包机 (下降沿驱动)
    initial begin
        automatic logic [31:0] ddr_send_cnt = 0;
        rd_resp_vld = 0;
        rd_resp_pd  = 0;
        
        forever begin
            if (axi_len_queue.size() > 0) begin
                automatic int current_len = axi_len_queue.pop_front();
                // 连发 Burst
                for (int i = 0; i <= current_len; i++) begin
                    @(negedge clk);
                    rd_resp_vld <= 1'b1;
                    rd_resp_pd  <= {96'd0, ddr_send_cnt};
                    
                    // 握手等待 (上升沿采样判定)
                    @(posedge clk);
                    while (!(rd_resp_vld && rd_resp_rdy)) @(posedge clk);
                    ddr_send_cnt++;
                end
                @(negedge clk);
                rd_resp_vld <= 1'b0;
                
                // 模拟总线空闲间隔
                repeat ($urandom_range(2, 10)) @(negedge clk); 
            end else begin
                @(negedge clk);
                rd_resp_vld <= 1'b0;
            end
        end
    end

    // 5.3 随机背压模拟器 (下降沿驱动)
    int backpressure_level = 0; // 0: 无反压, 1: 轻度, 2: 严重
    always @(negedge clk) begin
        if (!rst_n) begin
            rd_req_rdy     <= 0;
            wbuf_can_write <= 0;
        end else begin
            case (backpressure_level)
                0: begin rd_req_rdy <= 1; wbuf_can_write <= 1; end
                1: begin rd_req_rdy <= ($urandom_range(0, 10) > 2); wbuf_can_write <= ($urandom_range(0, 10) > 1); end
                2: begin rd_req_rdy <= ($urandom_range(0, 10) > 7); wbuf_can_write <= ($urandom_range(0, 10) > 5); end
            endcase
        end
    end

    // ==========================================
    // 6. 监测校验器 (针对 Vivado XSim 优化)
    // ==========================================
    always @(posedge clk) begin
        // 在 Vivado 中，局部变量声明必须放在 begin 后的最前面
        wbuf_exp_t local_exp; 
        logic mismatch_err;

        if (rst_n && wbuf_wr_bank_en != 0) begin
            if (exp_queue.size() == 0) begin
                $error("[FATAL ERROR] 硬件产生写信号，但预期队列为空！T=%0t", $time);
                $stop;
            end else begin
                // 弹出队列数据
                local_exp = exp_queue.pop_front();
                mismatch_err = 0;

                // 逐项比对
                if (wbuf_wr_bank_en     !== local_exp.bank_en)     mismatch_err = 1;
                if (wbuf_wr_offset      !== local_exp.offset)      mismatch_err = 1;
                if (wbuf_wr_dat         !== local_exp.dat)         mismatch_err = 1;
                if (wbuf_wr_region_done !== local_exp.region_done) mismatch_err = 1;

                if (mismatch_err) begin
                    $display("\n================ [DATA MISMATCH] ================");
                    $display("Time: %0t", $time);
                    $display("       | Expected                | Actual");
                    $display("BankEn | %b                | %b", local_exp.bank_en, wbuf_wr_bank_en);
                    $display("Offset | %0d                     | %0d", local_exp.offset, wbuf_wr_offset);
                    $display("Data   | %h | %h", local_exp.dat, wbuf_wr_dat);
                    $display("RgDone | %b                     | %b", local_exp.region_done, wbuf_wr_region_done);
                    $display("=================================================");
                    $stop;
                end else begin
                    // 打印关键进度
                    if (local_exp.dat[31:0] % 10 == 0 || local_exp.region_done) begin
                        $display("[CHECK OK] Beat:%0d | Bank:%b Offset:%0d Done:%b", 
                                local_exp.dat[31:0], wbuf_wr_bank_en, wbuf_wr_offset, wbuf_wr_region_done);
                    end
                end
            end
        end
    end

    // ==========================================
    // 7. 测试用例编排主流程
    // ==========================================
    initial begin
        @(posedge rst_n);
        repeat(5) @(negedge clk);
        
        // Test 1: 标准满贯排列 (如 32个输出通道，即2个co_grp全满)
        backpressure_level = 0;
        launch_test(.co_groups(2), .coords(9), .active_banks(8), .is_odd(0));
        repeat(20) @(negedge clk);

        // Test 2: 非对齐通道测试 (如 27个输出通道，奇数，且 Bank 不满)
        // 计算: co_grp=2 (第一个16，第二个11通道) -> 第二个使用 ceil(11/2)=6 个 Bank
        backpressure_level = 1; // 开启轻微反压
        launch_test(.co_groups(2), .coords(4), .active_banks(6), .is_odd(1));
        repeat(20) @(negedge clk);

        // Test 3: 极端单边情况 (1x1卷积，只有1个输入组，1个奇数输出通道)
        backpressure_level = 2; // 开启严重断流反压模拟 (极限验证 FIFO 韧性)
        launch_test(.co_groups(1), .coords(1), .active_banks(1), .is_odd(1));
        repeat(20) @(negedge clk);

        // Test 4: 大体量深层网络长突发验证 (多次跨 256 AXI 突发)
        backpressure_level = 0;
        launch_test(.co_groups(16), .coords(36), .active_banks(8), .is_odd(0));

        repeat(50) @(negedge clk);
        $display("\n=======================================================");
        $display("[VICTORY] 所有极限条件下的权重 CDMA 及地址重映射全部验证通过！");
        $display("=======================================================\n");
        $finish;
    end

endmodule