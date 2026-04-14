
`timescale 1ns / 1ps

module csc_dat #(
    parameter BANK_NUM = 8,
    parameter TK_IN    = 8,
    parameter N        = 8
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,

    // ==========================================
    // 0. 全局配置寄存器 (CSR)
    // ==========================================
    input  wire [15:0] cfg_w_out,        
    input  wire [15:0] cfg_w_out_blocks, 
    input  wire [15:0] cfg_h_out,        
    input  wire [15:0] cfg_w_in,         
    input  wire [15:0] cfg_h_in,         
    input  wire [15:0] cfg_co_groups,    
    input  wire [15:0] cfg_ci_groups,    
    input  wire [3:0]  cfg_kx,           
    input  wire [3:0]  cfg_ky,           
    input  wire [3:0]  cfg_stride_x,     
    input  wire [3:0]  cfg_stride_y,     
    input  wire [3:0]  cfg_pad_left,     
    input  wire [3:0]  cfg_pad_up,       
    input  wire [3:0]  cfg_active_banks,
    output wire        csc_row_done,

    // ==========================================
    // 1. 特征图 CBUF 交互接口
    // ==========================================
    input  wire        cbuf_can_read, 
    output wire [7:0]  cbuf_rd_en,         
    output wire [15:0] cbuf_rd_row,        
    output wire [15:0] cbuf_rd_col_align,  
    output wire [15:0] cbuf_rd_ch_grp,     
    output reg         cbuf_rd_row_free,   
    output reg  [3:0]  cbuf_rd_free_num,   
    input  wire [BANK_NUM*TK_IN*N-1:0] cbuf_rd_dat,

    // ==========================================
    // 2. 权重 WBUF 交互接口
    // ==========================================
    input  wire        wbuf_can_read,
    output wire [BANK_NUM-1:0] wbuf_rd_en,
    output wire        wbuf_step_en,
    output wire        wbuf_offset_clr,    
    output wire        wbuf_region_done,
    output wire [1:0]  wbuf_region_idx,

    // ==========================================
    // 3. MAC 阵列交互接口
    // ==========================================
    input  wire        mac_buf_ready, 
    output wire [BANK_NUM*TK_IN*N-1:0] mac_dat,
    output reg         mac_valid,     
    output reg  [7:0]  mac_pixel_mask,
    output reg  [15:0] mac_co_grp,    
    output reg         mac_is_last_ci 
);

    // =====================================================================
    // [Stage 0] 统一流控与 6D 循环引擎
    // =====================================================================
    reg working;
    wire h_done, h_en;
    
    assign csc_row_done = h_en;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) working <= 1'b0;
        else if (start) working <= 1'b1;
        else if (h_en && h_done) working <= 1'b0;
    end

    // 【新增】：分时复用相位控制器 (Phase Controller)
    reg stride_phase;
    wire is_stride2 = (cfg_stride_x == 4'd2);
    wire phase_done = (!is_stride2) || stride_phase;

    wire cbuf_fire = working && cbuf_can_read && wbuf_can_read && mac_buf_ready; 
    wire step_en   = cbuf_fire && phase_done; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) stride_phase <= 1'b0;
        else if (cbuf_fire && is_stride2) stride_phase <= ~stride_phase;
    end

    // 层级1: 输入通道组 (计数器仅在 step_en 完整步进时更新)
    reg [15:0] ci_grp;    wire ci_done = (ci_grp == cfg_ci_groups - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) ci_grp <= 0; else if (step_en) ci_grp <= ci_done ? 0 : ci_grp + 1'b1;
    end
    
    // 层级2: 卷积核 X
    reg [3:0] kx;         wire kx_en = step_en && ci_done; wire kx_done = (kx == cfg_kx - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) kx <= 0; else if (kx_en) kx <= kx_done ? 0 : kx + 1'b1;
    end
    
    // 层级3: 卷积核 Y
    reg [3:0] ky;         wire ky_en = kx_en && kx_done;   wire ky_done = (ky == cfg_ky - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) ky <= 0; else if (ky_en) ky <= ky_done ? 0 : ky + 1'b1;
    end
    
    // 层级4: 输出像素列条带 
    reg [15:0] w_out_blk; wire w_en = ky_en && ky_done;    wire w_done = (w_out_blk == cfg_w_out_blocks - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) w_out_blk <= 0; else if (w_en) w_out_blk <= w_done ? 0 : w_out_blk + 1'b1;
    end
    
    // 层级5: 输出通道组
    reg [15:0] co_grp;    wire co_en = w_en && w_done;     wire co_done = (co_grp == cfg_co_groups - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) co_grp <= 0; else if (co_en) co_grp <= co_done ? 0 : co_grp + 1'b1;
    end
    
    // 层级6: 输出行
    reg [15:0] h_out;     assign h_en = co_en && co_done;  assign h_done = (h_out == cfg_h_out - 1);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) h_out <= 0; else if (h_en) h_out <= h_done ? 0 : h_out + 1'b1;
    end

    wire is_acc_window_done_s0    = ci_done && kx_done && ky_done;
    wire is_co_grp_region_done_s0 = is_acc_window_done_s0 && w_done;

    wire signed [15:0] cur_lowest  = $signed({1'b0, h_out}) * $signed({1'b0, cfg_stride_y}) - $signed({1'b0, cfg_pad_up});
    wire signed [15:0] next_lowest = cur_lowest + $signed({1'b0, cfg_stride_y});
    wire signed [15:0] real_cur_lowest  = (cur_lowest < 0)  ? 16'd0 : cur_lowest;
    wire signed [15:0] real_next_lowest = (next_lowest < 0) ? 16'd0 : next_lowest;
    wire [3:0] free_num_s0 = (real_next_lowest - real_cur_lowest);

    // =====================================================================
    // [Stage 1] 坐标转换与缓存寻址打拍
    // =====================================================================
    reg [3:0] free_num_d1;
    reg       free_vld_d1;
    reg signed [15:0] in_row_d1, in_col_base_d1, out_col_base_d1;
    reg [15:0] ci_grp_d1, co_grp_d1; 
    reg step_en_d1, mac_is_last_ci_d1;
    reg wbuf_offset_clr_d1, wbuf_region_done_d1;

    // 将 stride2 相位控制与 cbuf_fire 一起打拍，供后级数据拼拍使用。
    reg cbuf_fire_d1, stride_phase_d1, is_stride2_d1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            free_num_d1 <= 0; free_vld_d1 <= 0;
            in_row_d1 <= 0; in_col_base_d1 <= 0; out_col_base_d1 <= 0;
            ci_grp_d1 <= 0; co_grp_d1 <= 0;
            step_en_d1 <= 0; mac_is_last_ci_d1 <= 0;
            wbuf_offset_clr_d1 <= 0; wbuf_region_done_d1 <= 0;
            
            cbuf_fire_d1 <= 0; stride_phase_d1 <= 0; is_stride2_d1 <= 0;
        end else begin
            free_vld_d1 <= h_en && (free_num_s0 > 0);
            free_num_d1 <= free_num_s0;
            step_en_d1  <= step_en; 
            
            cbuf_fire_d1    <= cbuf_fire;
            stride_phase_d1 <= stride_phase;
            is_stride2_d1   <= is_stride2;

            mac_is_last_ci_d1   <= is_acc_window_done_s0;
            wbuf_offset_clr_d1  <= is_acc_window_done_s0;
            wbuf_region_done_d1 <= is_co_grp_region_done_s0;

            ci_grp_d1 <= ci_grp; 
            co_grp_d1 <= co_grp;
            
            in_row_d1       <= $signed({1'b0, h_out}) * $signed({1'b0, cfg_stride_y}) - $signed({1'b0, cfg_pad_up}) + $signed({1'b0, ky});
            out_col_base_d1 <= $signed({1'b0, w_out_blk}) * 8;
            
            // 【核心修正】：如果当前是 Phase 1，基地址自动偏移 8 个输入像素
            in_col_base_d1  <= $signed({1'b0, w_out_blk}) * 8 * $signed({1'b0, cfg_stride_x}) - $signed({1'b0, cfg_pad_left}) + $signed({1'b0, kx}) + ((is_stride2 && stride_phase) ? 16'd8 : 16'd0);
        end
    end

    assign cbuf_rd_row       = in_row_d1[15:0];
    assign cbuf_rd_col_align = in_col_base_d1[15:0];
    assign cbuf_rd_ch_grp    = ci_grp_d1;

    wire [7:0] in_p_mask_c;   
    wire [7:0] out_p_mask_c;  

    genvar i;
    generate for(i=0; i<8; i=i+1) begin : MASK_GEN
        wire signed [15:0] cur_in_col = in_col_base_d1 + i;
        wire signed [15:0] cur_out_col = out_col_base_d1 + i;
        assign in_p_mask_c[i] = (in_row_d1 >= 0) && (in_row_d1 < $signed({1'b0, cfg_h_in})) &&
                                (cur_in_col >= 0) && (cur_in_col < $signed({1'b0, cfg_w_in}));
        assign out_p_mask_c[i] = (cur_out_col < $signed({1'b0, cfg_w_out}));
    end endgenerate

    // CBUF 读取：无论相位如何，只要 fire 就连续读两拍
    assign cbuf_rd_en = cbuf_fire_d1 ? in_p_mask_c : 8'd0;

    // WBUF 读取：仅在有效动作 (phase_done) 发生时读取一次
    wire [BANK_NUM-1:0] wbuf_active_mask = (co_grp_d1 == cfg_co_groups - 1) ? 
                                        ((8'h01 << cfg_active_banks) - 1'b1) : {BANK_NUM{1'b1}};                                  
    assign wbuf_rd_en       = step_en_d1 ? wbuf_active_mask : {BANK_NUM{1'b0}}; 
    assign wbuf_step_en     = step_en_d1;
    assign wbuf_offset_clr  = wbuf_offset_clr_d1;
    assign wbuf_region_done = wbuf_region_done_d1;
    // resident 模式下，WBUF 需要根据当前 16 通道组编号选择常驻 region。
    assign wbuf_region_idx  = co_grp_d1[1:0];

    // =====================================================================
    // [Stage 2] ~ [Stage 5] 控制流水线 
    // =====================================================================
    reg        mac_valid_d2, mac_is_last_ci_d2;
    reg [15:0] mac_co_grp_d2;
    reg [7:0]  in_p_mask_d2, out_p_mask_d2;

    reg        mac_valid_d3, mac_is_last_ci_d3;
    reg [15:0] mac_co_grp_d3;
    reg [7:0]  in_p_mask_d3, out_p_mask_d3;

    reg        mac_valid_d4, mac_is_last_ci_d4;
    reg [15:0] mac_co_grp_d4;
    reg [7:0]  in_p_mask_d4, out_p_mask_d4;

    reg [7:0]  in_p_mask_d5;
    
    // stride2 的相位信息继续后传，保证与 CBUF 返回数据严格对齐。
    reg cbuf_fire_d2, stride_phase_d2, is_stride2_d2;
    reg cbuf_fire_d3, stride_phase_d3, is_stride2_d3;
    reg cbuf_fire_d4, stride_phase_d4, is_stride2_d4;
    reg cbuf_fire_d5, stride_phase_d5, is_stride2_d5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cbuf_rd_row_free <= 0; cbuf_rd_free_num <= 0;
            
            mac_valid_d2 <= 0; mac_is_last_ci_d2 <= 0; mac_co_grp_d2 <= 0; in_p_mask_d2 <= 0; out_p_mask_d2 <= 0;
            mac_valid_d3 <= 0; mac_is_last_ci_d3 <= 0; mac_co_grp_d3 <= 0; in_p_mask_d3 <= 0; out_p_mask_d3 <= 0;
            mac_valid_d4 <= 0; mac_is_last_ci_d4 <= 0; mac_co_grp_d4 <= 0; in_p_mask_d4 <= 0; out_p_mask_d4 <= 0;
            in_p_mask_d5 <= 0; mac_valid <= 0; mac_pixel_mask <= 0; mac_co_grp <= 0; mac_is_last_ci <= 0;
            
            cbuf_fire_d2 <= 0; stride_phase_d2 <= 0; is_stride2_d2 <= 0;
            cbuf_fire_d3 <= 0; stride_phase_d3 <= 0; is_stride2_d3 <= 0;
            cbuf_fire_d4 <= 0; stride_phase_d4 <= 0; is_stride2_d4 <= 0;
            cbuf_fire_d5 <= 0; stride_phase_d5 <= 0; is_stride2_d5 <= 0;
        end else begin
            cbuf_rd_row_free <= free_vld_d1;
            cbuf_rd_free_num <= free_num_d1;
            
            cbuf_fire_d2 <= cbuf_fire_d1; stride_phase_d2 <= stride_phase_d1; is_stride2_d2 <= is_stride2_d1;
            cbuf_fire_d3 <= cbuf_fire_d2; stride_phase_d3 <= stride_phase_d2; is_stride2_d3 <= is_stride2_d2;
            cbuf_fire_d4 <= cbuf_fire_d3; stride_phase_d4 <= stride_phase_d3; is_stride2_d4 <= is_stride2_d3;
            cbuf_fire_d5 <= cbuf_fire_d4; stride_phase_d5 <= stride_phase_d4; is_stride2_d5 <= is_stride2_d4;

            mac_valid_d2      <= step_en_d1; 
            mac_is_last_ci_d2 <= mac_is_last_ci_d1; 
            mac_co_grp_d2     <= co_grp_d1;
            in_p_mask_d2      <= in_p_mask_c;
            out_p_mask_d2     <= out_p_mask_c;

            mac_valid_d3      <= mac_valid_d2; 
            mac_is_last_ci_d3 <= mac_is_last_ci_d2; 
            mac_co_grp_d3     <= mac_co_grp_d2;
            in_p_mask_d3      <= in_p_mask_d2;
            out_p_mask_d3     <= out_p_mask_d2;

            mac_valid_d4      <= mac_valid_d3; 
            mac_is_last_ci_d4 <= mac_is_last_ci_d3; 
            mac_co_grp_d4     <= mac_co_grp_d3;
            in_p_mask_d4      <= in_p_mask_d3;
            out_p_mask_d4     <= out_p_mask_d3;

            in_p_mask_d5   <= in_p_mask_d4; 
            mac_valid      <= mac_valid_d4;
            mac_pixel_mask <= out_p_mask_d4; 
            mac_co_grp     <= mac_co_grp_d4; 
            mac_is_last_ci <= mac_is_last_ci_d4;
        end
    end

    // =====================================================================
    // [Stage 5] CBUF 数据到达与 16选8 交叉拼装逻辑
    // =====================================================================
    reg [BANK_NUM*TK_IN*N-1:0] saved_cbuf_dat;
    reg [7:0]                  saved_in_p_mask;

    // 当 Phase 0 的数据先抵达时，将其暂存到寄存器中
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            saved_cbuf_dat  <= 0;
            saved_in_p_mask <= 0;
        end else if (cbuf_fire_d5 && is_stride2_d5 && !stride_phase_d5) begin
            saved_cbuf_dat  <= cbuf_rd_dat;
            saved_in_p_mask <= in_p_mask_d5;
        end
    end

    wire [BANK_NUM*TK_IN*N-1:0] clean_mac_dat;
    
    generate for(i=0; i<8; i=i+1) begin : DAT_ASSEMBLY
        wire [TK_IN*N-1:0] pixel_dat;
        wire pixel_mask;

        if (i < 4) begin
            // 组装前 4 个像素：取 Phase 0 数据的偶数抽头
            assign pixel_dat  = is_stride2_d5 ? saved_cbuf_dat[(i*2)*TK_IN*N +: TK_IN*N] : cbuf_rd_dat[i*TK_IN*N +: TK_IN*N];
            assign pixel_mask = is_stride2_d5 ? saved_in_p_mask[i*2] : in_p_mask_d5[i];
        end else begin
            // 组装后 4 个像素：取 Phase 1 数据（当前打进来的数据）的偶数抽头
            assign pixel_dat  = is_stride2_d5 ? cbuf_rd_dat[((i-4)*2)*TK_IN*N +: TK_IN*N] : cbuf_rd_dat[i*TK_IN*N +: TK_IN*N];
            assign pixel_mask = is_stride2_d5 ? in_p_mask_d5[(i-4)*2] : in_p_mask_d5[i];
        end

        // 终极清洗：将无效越界的假像素强行刷成 0，杜绝内部污染
        assign clean_mac_dat[i*TK_IN*N +: TK_IN*N] = pixel_mask ? pixel_dat : {(TK_IN*N){1'b0}};
    end endgenerate
    
    assign mac_dat = clean_mac_dat;

endmodule
