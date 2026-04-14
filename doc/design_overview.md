#  量化说明
1.采用逐层量化,额外消耗128个dsp.量化后训练(QTR)
2.后续尝试优化为Pot量化减少dsp占用,以及剪枝



# YOLOv5 Accelerator 简要设计说明

## 1. 整体定位

本工程是一个面向 YOLO 类网络的定点加速器顶层实现，核心目标是用统一的数据通路支持以下几类算子：

- 卷积 `conv`
- 最大池化 `pool`
- 残差相加 `resadd`
- 上采样 `upsample`
- 通道拼接 `concat`

其中：

- `upsample` 不作为独立写回算子存在，而是融合在特征图装载阶段完成。
- `concat` 也不作为独立算子存在，而是融合在下一层卷积的输入装载阶段完成,且目前仅支持8的倍数通道数拼接.
- 卷积主链路采用 `CDMA -> Buffer -> CSC/SPU -> CACC -> OBUF -> WDMA` 的流式结构。

## 2. 顶层设计思路

顶层由两个部分组成：

- `yolo_global_fsm`：负责全局启动、算子模式切换、权重加载节奏控制和完成信号汇总。
- `yolo_accel_top`：负责把各个 DMA、片上缓存、计算模块和写回模块连接成完整数据通路。

整个设计的一个重要特点是：软件侧只配置“输入尺寸 / 输出尺寸 / 输入通道组 / 输出通道数”这些基础语义，顶层再把它们换算成不同模块内部真正需要的粒度。

例如：

- `CSC` 使用的是 `16` 通道一组。
- `OBUF / WDMA / Pool / ResAdd / RBUF` 使用的是 `8` 通道一组。

这样可以减少软件配置负担，也让顶层成为统一的语义转换层。

## 3. 控制与寄存器域

### 3.1 CSR 顶层

`yolo_sim_top`/`yolo_top` 对外暴露紧凑寄存器接口，负责接收软件配置并分发到各个子模块。

最重要的配置内容包括：

- 输入/输出特征图基地址
- 权重和 bias 基地址
- 输入输出尺寸
- 卷积核尺寸、步长、padding
- 输出通道数
- 算子模式 `cfg_op_mode`
- `concat / upsample / resident` 等特殊功能开关

### 3.2 全局 FSM

`yolo_global_fsm` 的职责是各模块的启动控制：

- 在启动时统一拉起各子模块的 `start`
- 根据 `op_mode` 选择启动卷积、池化或残差路径
- 在卷积模式下控制 `W_CDMA` 的首轮加载和逐行重载
- 在 `WDMA` 全部写回完成后产生 `ap_done`

关键设计点：

- 非 resident 模式下，权重按输出行节奏重载。
- resident 模式下，首轮将整层权重搬入 `WBUF`，后续各行直接复用。

## 4. 外部存储访问域

### 4.1 MCIF

`mcif_4r_4w` 是整个系统的 AXI 主接口适配层，对内提供：

- 4 路读通道
- 4 路写通道

内部再拆成：

- `mcif_rd_4r`：负责 4 路读请求仲裁、AR/R 通道驱动和按 ID 回传数据。
- `mcif_wr_4w`：负责写命令/写数据混合包拆分、AW/W/B 通道驱动和写完成反馈。

关键设计点：

- 通过轮询仲裁复用单个 AXI Master 口。


### 4.2 CDMA 域

`accel_cdma_domain_top_cat` 统一管理输入相关的 DMA 模块，主要包括：

- `w_cdma_top`：从 DDR 读取卷积权重并写入 `WBUF`
- `cdma_top_cat`：读取输入特征图，支持普通输入、上采样输入、双源 concat 输入
- `b_cdma_top`：读取 bias/scale/shift 参数并写入 `BBUF`
- `r_cdma_top`：读取残差输入并写入 `RBUF`

关键设计点：

- 特征图读通路支持 `virtual concat`，即两路输入在装载阶段直接拼接到 `CBUF`。
- `src0 upsample` 在 DMA 写入 `CBUF` 之前完成像素复制，不需要先落 DDR。
- 权重加载通路按 `co_group / kernel坐标 / bank` 三层次展开，和 `WBUF` 的组织方式严格对齐。

## 5. 片上缓存域

### 5.1 CBUF

`cbuf_dat_top` 是输入特征图行缓冲，按“行块 + 通道组 + 列块”组织。

关键设计点：

- 采用环形行缓存结构，用 `row_credits`/行指针控制可写和可读窗口。
- 读地址支持带符号列偏移，能够正确处理左侧 padding。
- 读数据经过 bank 重排后输出给 `CSC / Pool / ResAdd`。

### 5.2 WBUF

`wbuf_dat_top` 是卷积权重缓存，按 region 组织。

关键设计点：

- 非 resident 模式下，`WBUF` 作为 4-region 环形缓存使用。
- resident 模式下，首轮装满全部有效 region，后续由 `CSC` 按输出通道组索引直接选择 region。
- 读路径做了多拍流水，对齐 `CBUF` 的读延迟。

### 5.3 BBUF

`bbuf_dat_top` 用于保存每个输出通道的量化参数：

- bias
- scale
- shift

关键设计点：

- 每个 bank 存一个 64bit 参数单元。
- `B_CDMA` 按硬件打包格式写入，`CACC` 侧按输出通道组读取。

### 5.4 RBUF

`rbuf_dat_top` 是残差输入专用行缓存，服务于 `ResAdd`。

关键设计点：

- 与 `CBUF` 分离，避免残差输入和主特征流互相干扰。
- 使用双端口 RAM，支持读写并行。
- 只保留较小的 `ROW_BLOCKS`，满足残差加法的行级滑动窗口需求。

## 6. 卷积计算域

### 6.1 CSC

`csc_dat` 是卷积调度器，负责把二维卷积的遍历过程展开成硬件可执行的时序流。

它主要完成：

- 输出像素块遍历
- 卷积核坐标遍历
- 输入通道组遍历
- 输出通道组遍历
- `CBUF` 读请求生成
- `WBUF` 读步进控制
- MAC 控制信号同步

关键设计点：

- 把卷积六层循环映射为硬件计数器链。
- `stride=2` 时通过相位控制，把两个半拍读回的数据重新拼成连续输出像素块。
- 对 `pixel mask` 做前向传播，保证边界像素不会污染内部计算。

### 6.2 SPU / MAC 阵列

`cmac_array`、`cmac_row`、`cmac_8_channels`、`simd_mac_dsp` 共同构成卷积乘加阵列。

关键设计点：

- `8 x 8` 的阵列结构一次处理 `8` 个像素位置和 `16` 个输出通道。
- 特征和权重分别通过分布树打拍广播，避免过长组合路径。
- 每个计算单元复用同一组输入特征，对两组权重同时做乘法，提高 DSP 利用率。

## 7. 累加与量化域

### 7.1 CACC Core

`cacc_core` 负责接收来自 MAC 阵列的部分和，并在输入通道维度上做累加。

关键设计点：

- 使用多 bank 环形累加存储，避免上一块结果还没量化时阻塞下一块输入。
- `mac_is_last_ci` 到来时，将当前 bank 标记为可量化输出。
- 输出像素 mask 和输出通道组信息会和累加结果一起保留下来。

### 7.2 参数预取与 Requant

`bbuf_prefetcher` 和 `cacc_requant` 共同完成量化过程。

关键设计点：

- `bbuf_prefetcher` 在最后一个输入通道组被接收时，提前去 `BBUF` 取回对应的 bias/scale/shift。
- `cacc_requant` 先乘 scale、再加 bias、再右移、再做饱和截断。
- 量化后的结果按 `8` 通道组拆成两半，写入 `OBUF` 的两个 group。

## 8. 其他算子域

### 8.1 Pool

`pool_top` 实现 `5x5 / stride=1` 的最大池化。

关键设计点：

- 通过 `SIDE_A / SIDE_B` 两个半窗口缓存复用相邻块数据。
- 读请求和计算过程尽量重叠，减少等待 `CBUF` 返回数据的空泡。
- 先做列方向最大值，再做行方向最大值，最后写回 `OBUF`。

### 8.2 ResAdd

`resadd_top` 与 `resadd_core` 实现残差加法。

关键设计点：

- `CBUF` 和 `RBUF` 两路输入分别独立预取，并进入各自 FIFO。
- 当两路 FIFO 都有数据时，再同步弹出送入 `resadd_core`。
- `resadd_core` 做逐通道 INT8 饱和加法，并支持可选 ReLU。

### 8.3 Upsample / Concat

上采样和拼接不作为独立后处理模块，而是融合在 `cdma_top_cat` 内。

关键设计点：

- 上采样采用 `nearest x2`
- `src0` 可先上采样再与 `src1` 做通道拼接
- 硬件支持默认 stride 自动推导，也支持软件手工配置 stride

这种做法的好处是：

- 避免中间结果写回 DDR
- 降低带宽消耗
- 让后续卷积直接消费拼接后的输入

## 9. 输出缓存与写回域

### 9.1 OBUF

`obuf_dat_top` 是输出特征图缓存，按两个 group 管理：

- Group0：前 8 个通道
- Group1：后 8 个通道

关键设计点：

- `CACC / Pool / ResAdd` 都统一写入 `OBUF`
- `WDMA` 按 group 和 chunk 从 `OBUF` 读取
- 两组 FIFO 水位对外可见，便于 `WDMA` 判断是否具备连续写回条件

### 9.2 WDMA

`wdma_core` 负责把 `OBUF` 中的数据重新组织成 DDR 连续布局并写回。

关键设计点：

- 按输出宽度自动计算每行所需 beat 数
- 支持 odd width 场景下最后一个 beat 的高 64bit 补零
- 写命令和写数据按 burst 组织，通过 `MCIF` 发往外部存储

## 10. 仿真与软件支撑

### 10.1 Testbench

`sim/testbench.sv` 是统一仿真顶层，负责：

- 例化 DUT
- 例化 AXI DDR 从模型
- 调用算子级回归任务
- 保存软件参考数组并做结果比对

### 10.2 任务库

`sim/tasks.svh` 和 `sim/tasks_ops.svh` 提供：

- 寄存器写入任务
- 输入/权重/参数装载任务
- 卷积、池化、上采样、concat、resadd 的软件参考模型
- 算子级回归入口

### 10.3 配置脚本

`generate_yolo_config_compact.py` 用于从网络层参数生成紧凑寄存器配置。

关键设计点：

- 软件只需要关心基础网络参数
- 权重拍数、bias 拍数、通道组数量、resident 开关等由脚本自动推导
- 能和当前硬件寄存器语义保持一致


