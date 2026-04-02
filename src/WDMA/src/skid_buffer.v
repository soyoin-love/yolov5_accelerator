`timescale 1ns / 1ps

module skid_buffer #(
    parameter DATA_WIDTH = 129 // 默认适配 WDMA 的混合包位宽
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // 上游接口 (Upstream - 连接 WDMA Core 的输出)
    input  wire                   i_valid,
    output wire                   o_ready,
    input  wire [DATA_WIDTH-1:0]  i_data,

    // 下游接口 (Downstream - 连接 MCIF AXI 侧)
    output wire                   o_valid,
    input  wire                   i_ready,
    output wire [DATA_WIDTH-1:0]  o_data
);

    // 双层寄存器定义：主寄存器 (Main) 与 辅助寄存器 (Skid)
    reg [DATA_WIDTH-1:0] data_reg;
    reg [DATA_WIDTH-1:0] skid_reg;
    reg                  valid_reg;
    reg                  skid_valid;

    // 向前级反压：只要辅助寄存器（skid_reg）是空的，就说明还有余力接收新数据
    assign o_ready = !skid_valid;
    
    // 向后级输出：始终输出主寄存器的数据
    assign o_valid = valid_reg;
    assign o_data  = data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_reg  <= 1'b0;
            skid_valid <= 1'b0;
            data_reg   <= {DATA_WIDTH{1'b0}};
            skid_reg   <= {DATA_WIDTH{1'b0}};
        end else begin
            // ----------------------------------------------------
            // 动作 1: 下游握手成功 (下游取走了主寄存器的数据)
            // ----------------------------------------------------
            if (o_valid && i_ready) begin
                if (skid_valid) begin
                    // 辅助寄存器有积压数据，填入主寄存器，腾出辅助空间
                    valid_reg  <= 1'b1;
                    data_reg   <= skid_reg;
                    skid_valid <= 1'b0;
                end else begin
                    // 辅助寄存器为空，主寄存器变空 (除非有新数据在同一周期进入)
                    valid_reg <= 1'b0;
                end
            end

            // ----------------------------------------------------
            // 动作 2: 上游握手成功 (有新数据进来)
            // ----------------------------------------------------
            if (i_valid && o_ready) begin
                // 条件：主寄存器当前为空，或者主寄存器的数据刚好在这一拍被下游取走
                if (!valid_reg || (o_valid && i_ready && !skid_valid)) begin
                    // 数据直通，直接进入主寄存器
                    valid_reg <= 1'b1;
                    data_reg  <= i_data;
                end else begin
                    // 主寄存器满了且下游没取走，直接打入辅助寄存器 (Skid)
                    skid_valid <= 1'b1;
                    skid_reg   <= i_data;
                end
            end
        end
    end

endmodule