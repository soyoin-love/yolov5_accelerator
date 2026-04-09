# YOLOv5-Nano 上采样集成方案

## 1. 现状判断

- 当前顶层 `cfg_op_mode` 只定义了 `conv / pool / resadd` 三种模式，`2'b11` 还空着，可扩展为 `upsample`。
- 当前顶层的数据路由也是围绕 `CBUF 读 -> 算子 -> OBUF 写 -> WDMA` 搭的。
- 当前工程里没有现成的 `concat/route` 模块，所以上采样做完以后，后续的 `concat` 仍然需要单独考虑。
- 现有 [upsample.v](e:/IEEE2027/yolov5_accelerator/src/upsample/src/upsample.v) 是按“整拍 128bit 数据块复制”来做水平复制的，更适合“1 拍 = 1 个像素块”的流式接口。
- 但当前 [wdma_core.v](e:/IEEE2027/yolov5_accelerator/src/WDMA/src/wdma_core.v) 明确把一行按 `ceil(W/2)` 个 `128bit` beat 处理，说明 1 拍里是 2 个相邻空间位置。
- 当前 [obuf_dat_top.v](e:/IEEE2027/yolov5_accelerator/src/obuf/src/obuf_dat_top.v) 也是由两个 `64bit` bank 拼成一个 `128bit` 输出拍。

## 2. 方案一：新增 `OP_UPSAMPLE`，做成独立 CBUF 算子

### 思路

- 沿用当前主架构：`F_CDMA -> CBUF -> upsample_top -> OBUF -> WDMA`。
- 新增一个 `upsample_top`，接口风格完全仿照 `pool_top / resadd_top`。
- `upsample_top` 从 `CBUF` 读入 8 个像素，做最近邻 `x2` 扩展后，写到 `OBUF`。
- 对 YOLOv5-Nano 的 2x nearest upsample，这个方案最贴近你现有工程。

### 为什么这个方案最顺

- 你现有顶层已经有 `cfg_op_mode` 选择读 CBUF 和写 OBUF 的多路复用逻辑。
- 只需要在顶层多加一组 `upsample_cbuf_rd_*` 和 `upsample_obuf_wr_*` 信号，并在 `cfg_op_mode == OP_UPSAMPLE` 时切换过去。
- `yolo_global_fsm` 里也只需要新增一个 `upsample_start` 分支，不需要引入新的 AXI 主口。
- 这个方案不强依赖你当前 [upsample.v](e:/IEEE2027/yolov5_accelerator/src/upsample/src/upsample.v)，但可以复用它“纵向重复一行”的设计思路。

### 关键实现点

- `OP_UPSAMPLE = 2'd3`。
- `cfg_in_width / cfg_in_height` 作为低分辨率输入尺寸。
- `cfg_out_width / cfg_out_height` 作为 2x 后输出尺寸。
- 上采样层不改通道数，所以软件侧让 `cfg_out_channels == 输入通道数`。
- `cfg_buf_min_calc_rows` 对上采样来说可固定看成 `1`。
- 输入 8 像素块可拆成两次写 OBUF：
  - 第 1 次输出 `{p0,p0,p1,p1,p2,p2,p3,p3}`
  - 第 2 次输出 `{p4,p4,p5,p5,p6,p6,p7,p7}`
- 纵向复制时，把同一输入行重复输出两次即可。

### 优点

- 最符合你现在的工程组织方式。
- 不需要新增专门的读 DMA。
- 便于后面继续接 `WDMA` 写回 DDR。
- 验证范围可控。

### 缺点

- 需要新写一个 `upsample_top`，当前 `upsample.v` 不能原样直接挂上。
- 后续 `concat` 还要继续设计。

## 3. 方案二：保留现有 `upsample.v`，做成独立流式层

### 思路

- 新增一个专门的 `upsample` 模式。
- 数据路由改成：`stream_rdma -> upsample -> stream_wdma`。
- 不走 `CBUF/OBUF`，而是单独做一条更轻的流式路径。

### 当前实现存在的问题

- 当前 [upsample.v](e:/IEEE2027/yolov5_accelerator/src/upsample/src/upsample.v) 的 `wrdata({feature_data, feature_data})` 是复制整拍 `128bit`。
- 但当前主数据格式里，一拍 `128bit` 对应两个相邻空间位置，而不是一个位置。
- 所以如果直接拿来用，水平复制会变成：
  - 输入 `{p0,p1}`
  - 输出 `{p0,p1}, {p0,p1}`
- 而不是最近邻需要的：
  - `{p0,p0}, {p1,p1}`

### 如果坚持复用这个算子，需要怎么改

- 要么把算子的粒度改成 `64bit` 单像素块，再加打包/解包模块。
- 要么把算子内部改成对 `128bit` 的上下两个 `64bit` 半拍分别复制。
- 同时还要补一条独立的流式读写 DMA。

### 优点

- 你已经有现成源码，可复用部分逻辑。
- 可以不占用 `CBUF` 和 `OBUF`。

### 缺点

- 需要额外做流式 RDMA/WDMA。
- 还要修正当前算子的粒度问题。
- 和主架构耦合较弱，后面维护会分叉。

## 4. 方案三：把上采样融合到下一层的 `CDMA/CBUF` 装载路径

### 思路

- 不单独把上采样结果写回 DDR。
- 下一层卷积装载输入时，直接把低分辨率特征图在 `CDMA` 侧扩成高分辨率，再写进 `CBUF`。
- 如果继续往前做一步，还可以把 `concat` 也融合进装载过程。

### 这个方案最适合什么目标

- 目标是降低 DDR 往返带宽。
- 目标是把 `upsample + concat + next conv` 尽量做成一体化流水。

### 需要改动的地方

- `cdma_top` 需要支持“读一份输入，写两倍坐标”。
- 如果要同时做 `concat`，还需要双源读取：
  - 一路读上采样分支
  - 一路读 lateral 分支
- `CBUF` 写入侧需要支持按通道偏移写入。

### 优点

- 性能和带宽最好。
- 最接近最终高效实现。

### 缺点

- 改动最大。
- 联动 `CDMA/CBUF/FSM/寄存器`。
- 不适合第一步就做。

## 5. 方案四：不做独立上采样算子，改模型实现

### 可选方式

- 反卷积 `deconv(stride=2)`
- `pixel shuffle`
- 软件侧在 PS 上做 resize

### 适用边界

- 如果允许重新训练/重新导出网络，可以考虑反卷积或 `pixel shuffle`。
- 如果只想快速跑通功能，也可以暂时放在 PS 侧做 resize。

### 不足

- 反卷积和 `pixel shuffle` 会改变原始 YOLOv5-Nano 结构。
- PS 做 resize 会带来额外 DDR 带宽和 CPU 参与，不适合长期方案。

## 6. 对你当前工程的建议

### 第一推荐

- 先做“方案一：独立 `upsample_top`”。
- 原因是它最符合你当前 `F_CDMA -> CBUF -> 算子 -> OBUF -> WDMA` 的主框架。
- 这条路也最容易和后续 `concat` 方案衔接。

### 第二推荐

- 如果你特别想复用现有 [upsample.v](e:/IEEE2027/yolov5_accelerator/src/upsample/src/upsample.v)，那就走“方案二”，但要先修正它的粒度问题。

### 长期推荐

- 最终高效版本应往“方案三：把上采样和 concat 融入下一层装载路径”靠。
- 但这个更适合在你先把功能版本跑通之后再做。

## 7. 如果你选方案一，我建议的落地顺序

1. 在 `cfg_op_mode` 中加入 `OP_UPSAMPLE = 2'd3`。
2. 在 `yolo_global_fsm` 中加入 `upsample_start`。
3. 在 `yolo_top` 中加入 `upsample_top` 例化。
4. 把 `cbuf_rd_*` 和 `obuf_wr_*` 的 mux 扩成四选一。
5. 让 `upsample_top` 直接读 `CBUF`、写 `OBUF`。
6. 先不做 `concat`，先把单独上采样层写回 DDR 跑通。
7. 第二步再决定 `concat` 是放在软件排布层，还是放进硬件 `CDMA` 里做。
