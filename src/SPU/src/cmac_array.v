`timescale 1ns / 1ps

module cmac_array #(
    parameter ROW_NUM = 8,
    parameter COL_NUM = 8,
    parameter N       = 8,
    parameter TK_IN   = 8,
    parameter TK_OUT  = 16,
    parameter OUT_W   = 19,
    parameter MAC_LATENCY  = 7, 
    parameter TREE_LATENCY = 3 
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire [ROW_NUM*TK_IN*N-1:0]         features_in,
    input  wire [COL_NUM*2*TK_IN*N-1:0]       weights_in,

    input  wire                               mac_valid_in,
    input  wire [7:0]                         mac_pixel_mask_in,
    input  wire [15:0]                        mac_co_grp_in,
    input  wire                               mac_is_last_ci_in,

    output wire [ROW_NUM*TK_OUT*OUT_W-1:0]    psum_out,
    output wire                               mac_valid_out,
    output wire [7:0]                         mac_pixel_mask_out,
    output wire [15:0]                        mac_co_grp_out,
    output wire                               mac_is_last_ci_out,

    input  wire                               cacc_ready,   
    output wire                               mac_buf_ready 
);

    // ==========================================
    // A. 权重垂直分布树 (Vertical Distribution Tree) - 3 Stages
    // ==========================================
    //(* equivalent_register_removal = "no" *) reg [1023:0] wt_s1, wt_s2_t, wt_s2_b, wt_s3_01, wt_s3_23, wt_s3_45, wt_s3_67;
    (* keep = "true" *) reg [1023:0] wt_s1, wt_s2_t, wt_s2_b, wt_s3_01, wt_s3_23, wt_s3_45, wt_s3_67;
    always @(posedge clk ) begin
        // if (!rst_n) begin
        //     wt_s1 <= 0; wt_s2_t <= 0; wt_s2_b <= 0;
        //     wt_s3_01 <= 0; wt_s3_23 <= 0; wt_s3_45 <= 0; wt_s3_67 <= 0;
        // end else begin
            wt_s1    <= weights_in;
            wt_s2_t  <= wt_s1;   wt_s2_b  <= wt_s1;
            wt_s3_01 <= wt_s2_t; wt_s3_23 <= wt_s2_t;
            wt_s3_45 <= wt_s2_b; wt_s3_67 <= wt_s2_b;
        end
    // end

    // ==========================================
    // B. 阵列例化 (特征向量直接下发，由行内部树负责 3 拍对齐)
    // ==========================================
    genvar r;
    generate
        for (r = 0; r < ROW_NUM; r = r + 1) begin : ROW_INST
            cmac_row #(
                .COL_NUM(COL_NUM), .N(N), .TK_IN(TK_IN), .TK_OUT(TK_OUT), .OUT_W(OUT_W)
            ) u_cmac_row (
                .clk(clk), .rst_n(rst_n),
                .feature_in(features_in[r * (TK_IN*N) +: (TK_IN*N)]),
                .weights_in((r<2)?wt_s3_01 : (r<4)?wt_s3_23 : (r<6)?wt_s3_45 : wt_s3_67),
                .psum_out(psum_out[r * (TK_OUT*OUT_W) +: (TK_OUT*OUT_W)])
            );
        end
    endgenerate

    // 控制信号同步 (3 + 7 = 10 拍延迟)
    localparam TOTAL_LATENCY = TREE_LATENCY + MAC_LATENCY;
    reg [25:0] ctrl_pipe [0:TOTAL_LATENCY-1];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) for(i=0; i<TOTAL_LATENCY; i=i+1) ctrl_pipe[i] <= 0;
        else begin
            ctrl_pipe[0] <= {mac_valid_in, mac_pixel_mask_in, mac_co_grp_in, mac_is_last_ci_in};
            for(i=1; i<TOTAL_LATENCY; i=i+1) ctrl_pipe[i] <= ctrl_pipe[i-1];
        end
    end
    assign {mac_valid_out, mac_pixel_mask_out, mac_co_grp_out, mac_is_last_ci_out} = ctrl_pipe[TOTAL_LATENCY-1];
    assign mac_buf_ready = cacc_ready;

endmodule