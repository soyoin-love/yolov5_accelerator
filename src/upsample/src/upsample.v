module upsample #(
    parameter DATA_WIDTH = 128,
    parameter DEPTH_W = 10,
    parameter ALMOST_FULL_THRESHOLD = 6,
    parameter ALMOST_EMPTY_THRESHOLD = 2
)(
    input  wire                     clk,
    input  wire                     rst_n,

    // 控制配置信息
    input  wire [DEPTH_W:0]         col_size,  // 原始图像单行数据块个数

    // 上游接口 (数据输入端)
    input  wire                     feature_valid,   // 上游数据有效
    input  wire [DATA_WIDTH-1:0]    feature_data,    // 上游输入数据 
    output wire                     feature_ready,   // 告诉上游：我还饿，可以继续送数据

    // 下游接口 (数据输出端)
    input  wire                     unsample_feature_ready,   // 下游准备好接收了
    output reg                      unsample_feature_valid,   // 告诉下游：我输出的数据是有效的
    output wire [DATA_WIDTH-1:0]    unsample_feature     // 放大后的输出数据 (128-bit)
);

    // 计算内部读取深度
    localparam DEPTH_R = DEPTH_W + 1;

    // FIFO 实例化连线
    wire fifo_full, fifo_almost_full;
    wire fifo_empty, fifo_almost_empty;
    wire fifo_not_ready_for_output;

    wire fifo_wren;
    wire fifo_rden;
    wire [DATA_WIDTH-1:0] fifo_rddata;
    reg  change_point;

    // =========================================================
    // 【法则 4】：只要 fifo 没有满，就可以一直写入
    // =========================================================
    // 反压上游：如果不满，就允许上游送数据 (为了系统时序安全，通常用 almost_full 反压，但这里遵循你的极限逻辑)
    assign feature_ready = ~fifo_almost_full; 
    assign fifo_wren = feature_valid && feature_ready;


    // =========================================================
    // 【法则 1 & 2】：读安全门限 (由底层的 not_ready_for_output 完美接管)
    // =========================================================
    // 读使能条件：
    // 1. FIFO 允许读 (!fifo_not_ready_for_output) -> 包含了防空和防虚拟越界
    // 2. 下游允许接 (unsample_feature_ready)
    assign fifo_rden = (!fifo_not_ready_for_output) && unsample_feature_ready;


    // =========================================================
    // 【法则 3】：由顶层控制计数，并切换真实与虚拟指针
    // =========================================================
    // 放大后的列数是原列数的 2 倍
    wire [DEPTH_R:0] double_col_size = {col_size, 1'b0}; 
    reg  [DEPTH_R:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            change_point <= 0;
        end else begin
            // 默认换行脉冲只拉高一拍，其余时间保持低电平
            change_point <= 1'b0;

            if (fifo_rden) begin
                if (cnt == double_col_size - 1) begin // 读完一行放大后的数据
                    cnt <= 0;
                    change_point <= 1'b1;             // 触发换行，传递给 FIFO
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end

    // =========================================================
    // 数据输出延时对齐
    // =========================================================
    // 因为 FIFO 内部的 RAM 读取需要 1 拍时钟延迟，
    // 所以 unsample_feature_valid 必须比 fifo_rden 晚一拍拉高，确保 unsample_feature_valid 为 1 时 unsample_feature 才是真实有效的。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            unsample_feature_valid <= 1'b0;
        end else begin
            unsample_feature_valid <= fifo_rden;
        end
    end

    assign unsample_feature = fifo_rddata;

    // =========================================================
    // 例化强力底层：upsample_fifo
    // =========================================================
    upsample_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH_W(DEPTH_W),
        .DEPTH_R(DEPTH_R),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) u_upsample_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wren(fifo_wren),
        .wrdata({feature_data,feature_data}),  //复制拼接
        .full(fifo_full),
        .almost_full(fifo_almost_full),
        .rden(fifo_rden),
        .rddata(fifo_rddata),
        .empty(fifo_empty),
        .almost_empty(fifo_almost_empty),
        .change_point(change_point),
        .col_size(col_size[DEPTH_R-1:0]),
        .not_ready_for_output(fifo_not_ready_for_output)
    );

endmodule