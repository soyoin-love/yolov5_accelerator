`timescale 1ns / 1ps

module w_cdma_recv_data #(
    parameter BANK_NUM       = 8,
    parameter REGION_W       = 8,
    parameter AXI_DATA_WIDTH = 128
)(
    input  wire                               clk,
    input  wire                               rst_n,

    // ==========================================
    // CSR 配置
    // ==========================================
    input  wire                               start,
    // [新配置] 对应第 6 层循环：输出通道组的总数
    input  wire [15:0]                        cfg_total_co_groups, 
    // [新配置] 对应第 5,4,3 层乘积：一个输出通道组包含的坐标点总数 (ci_grp * ky * kx)
    input  wire [15:0]                        cfg_coords_per_region,
    // 最后一组实际使用的 Bank 数量
    input  wire [3:0]                         cfg_active_banks,  
    // 最后一组的最后一个 Bank 是否为奇数通道
    input  wire                               cfg_is_odd_oc,     

    output wire                               done,

    // MCIF 读响应
    input  wire                               rd_resp_vld,
    output wire                               rd_resp_rdy,
    input  wire [AXI_DATA_WIDTH-1:0]          rd_resp_pd,

    // WBUF 写接口
    input  wire                               wbuf_can_write,
    output reg  [BANK_NUM-1:0]                wbuf_wr_bank_en,
    output reg  [REGION_W-1:0]                wbuf_wr_offset,
    output reg  [AXI_DATA_WIDTH-1:0]          wbuf_wr_dat,
    output reg                                wbuf_wr_region_done
);

    // ==========================================
    // 嵌套循环计数器定义
    // ==========================================
    reg [15:0] co_grp_cnt;
    reg [15:0] coord_cnt;
    reg [3:0]  bank_cnt;

    // 边界条件判定
    wire is_last_co_grp = (co_grp_cnt == cfg_total_co_groups - 1);
    wire is_last_coord  = (coord_cnt  == cfg_coords_per_region - 1);
    
    // 【核心修正】只有最后一组 co_grp 采用动态 Bank 数量，其余全是 8 
    wire [3:0] current_active_banks = is_last_co_grp ? cfg_active_banks : 4'd8;
    wire is_last_bank = (bank_cnt == current_active_banks - 1);

    wire data_handshake = rd_resp_vld && rd_resp_rdy;
    
    // 只有三个维度全部抵达终点，才是真正的搬运结束
    assign done = data_handshake && is_last_co_grp && is_last_coord && is_last_bank;

    reg working;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) working <= 1'b0;
        else if (start) working <= 1'b1;
        else if (done)  working <= 1'b0;
    end

    assign rd_resp_rdy = working && wbuf_can_write;

    // ==========================================
    // 0. 定义各层级递进脉冲 (Cascading Pulses)
    // ==========================================
    // 只有在数据握手成功时，底层的脉冲才可能触发
    wire bank_done  = data_handshake && is_last_bank;
    wire coord_done = bank_done      && is_last_coord;
    wire all_done   = coord_done     && is_last_co_grp;

    // ==========================================
    // 1. 第 1 & 2 层循环：Bank 计数器 (0 ~ current_active_banks-1)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            bank_cnt <= 0;
        end else if (data_handshake) begin
            if (is_last_bank) bank_cnt <= 0;
            else              bank_cnt <= bank_cnt + 1'b1;
        end
    end

    // ==========================================
    // 2. 第 3, 4, 5 层循环：坐标计数器 (0 ~ coords_per_region-1)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            coord_cnt <= 0;
        end else if (bank_done) begin // 只有当一个 Bank 组（16通道）写完，坐标才进位
            if (is_last_coord) coord_cnt <= 0;
            else               coord_cnt <= coord_cnt + 1'b1;
        end
    end

    // ==========================================
    // 3. 第 6 层循环：输出通道组计数器 (0 ~ total_co_groups-1)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            co_grp_cnt <= 0;
        end else if (coord_done) begin // 只有当一个区域（36/9个坐标点）写完，co_grp 才进位
            if (is_last_co_grp) co_grp_cnt <= 0;
            else                co_grp_cnt <= co_grp_cnt + 1'b1;
        end
    end

    // ==========================================
    // 4. 物理地址与区域完成信号
    // ==========================================
    // 写偏移地址随坐标同步更新
    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n || start) begin
    //         wbuf_wr_offset <= 0;
    //     end else if (bank_done) begin
    //         if (is_last_coord) wbuf_wr_offset <= 0;
    //         else               wbuf_wr_offset <= wbuf_wr_offset + 1'b1;
    //     end
    // end

    // 【修正】写偏移地址必须与 wr_dat 严格对齐打一拍。直接在握手时采样 coord_cnt 即可。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wbuf_wr_offset <= 0;
        end else if (data_handshake) begin
            wbuf_wr_offset <= coord_cnt[REGION_W-1:0];
        end
    end


    // 区域完成信号：当最后一个坐标的最后一个 Bank 写完时发出
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wbuf_wr_region_done <= 1'b0;
        end else begin
            wbuf_wr_region_done <= coord_done; 
        end
    end

    // ==========================================
    // 硬件极限清洗补零逻辑
    // ==========================================
    // 必须且仅在: 最后一组 co_grp + 最后一个 coord + 最后一个 Bank，才触发补零
    wire need_pad_zero = cfg_is_odd_oc && is_last_co_grp && is_last_bank;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wbuf_wr_dat     <= 0;
            wbuf_wr_bank_en <= 0;
        end else if (data_handshake) begin
            wbuf_wr_dat     <= need_pad_zero ? {64'd0, rd_resp_pd[63:0]} : rd_resp_pd;
            wbuf_wr_bank_en <= (8'h01 << bank_cnt);
        end else begin
            wbuf_wr_bank_en <= 8'h00;
        end
    end

endmodule