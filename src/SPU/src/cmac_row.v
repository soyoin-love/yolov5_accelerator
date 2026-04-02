`timescale 1ns / 1ps

module cmac_row #(
    parameter COL_NUM = 8,
    parameter N       = 8,
    parameter TK_IN   = 8,
    parameter TK_OUT  = 16,
    parameter OUT_W   = 19
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire [TK_IN*N-1:0]                 feature_in, // 64-bit
    input  wire [COL_NUM*2*TK_IN*N-1:0]       weights_in, // 1024-bit
    output wire [TK_OUT*OUT_W-1:0]            psum_out
);

    // ==========================================
    // 特征水平分布树 (Horizontal Distribution Tree) - 3 Stages
    // ==========================================
    // Stage 1: 根节点
    reg [TK_IN*N-1:0] feat_s1;
    // Stage 2: 枝节点 (左/右分发)
    //(* equivalent_register_removal = "no" *)  reg [TK_IN*N-1:0] feat_s2_l, feat_s2_r;
    (* keep = "true" *) reg [TK_IN*N-1:0] feat_s2_l, feat_s2_r;
    // Stage 3: 叶节点 (每对 PE 分发)
    //(* equivalent_register_removal = "no" *)  reg [TK_IN*N-1:0] feat_s3_c01, feat_s3_c23, feat_s3_c45, feat_s3_c67;
    (* keep = "true" *) reg [TK_IN*N-1:0] feat_s3_c01, feat_s3_c23, feat_s3_c45, feat_s3_c67;
    
    always @(posedge clk ) begin
        // if (!rst_n) begin
        //     feat_s1 <= 0; feat_s2_l <= 0; feat_s2_r <= 0;
        //     feat_s3_c01 <= 0; feat_s3_c23 <= 0; feat_s3_c45 <= 0; feat_s3_c67 <= 0;
        // end else begin
            feat_s1     <= feature_in;
            feat_s2_l   <= feat_s1;   feat_s2_r   <= feat_s1;
            feat_s3_c01 <= feat_s2_l; feat_s3_c23 <= feat_s2_l;
            feat_s3_c45 <= feat_s2_r; feat_s3_c67 <= feat_s2_r;
        end
    //end

    genvar c;
    generate
        for (c = 0; c < COL_NUM; c = c + 1) begin : COL_INST
            // 权重是顶层传进来的，已经延迟了 3 拍，这里直接使用
            wire [2*TK_IN*N-1:0] cur_col_wt = weights_in[c * (2*TK_IN*N) +: (2*TK_IN*N)];
            
            // 特征选择对应的叶节点数据，确保也是延迟了 3 拍
            wire [TK_IN*N-1:0] cur_feat = 
                (c < 2) ? feat_s3_c01 :
                (c < 4) ? feat_s3_c23 :
                (c < 6) ? feat_s3_c45 : feat_s3_c67;

            wire signed [OUT_W-1:0] psum_oc0, psum_oc1;

            cmac_8_channels #(.N(N)) u_cmac_8 (
                .clk(clk), .rst_n(rst_n),
                .features_in(cur_feat),
                .weights_oc0(cur_col_wt[TK_IN*N-1 : 0]),
                .weights_oc1(cur_col_wt[2*TK_IN*N-1 : TK_IN*N]),
                .sum_out_oc0(psum_oc0), .sum_out_oc1(psum_oc1)
            );

            assign psum_out[(2*c) * OUT_W +: OUT_W]   = psum_oc0;
            assign psum_out[(2*c+1) * OUT_W +: OUT_W] = psum_oc1;
        end
    endgenerate
endmodule