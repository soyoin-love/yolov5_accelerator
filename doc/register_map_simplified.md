# 精简后的寄存器配置

## 软件仍需显式写入

| 地址 | 寄存器 | 说明 |
| --- | --- | --- |
| `0x00` | `ap_start` | 启动一次计算 |
| `0x10` | `cfg_f_base_addr` | 输入特征图基地址 |
| `0x14` | `cfg_wt_base_addr` | 权重基地址 |
| `0x18` | `cfg_b_base_addr` | 偏置/量化参数基地址 |
| `0x1C` | `cfg_wdma_base_addr` | 输出特征图基地址 |
| `0x20` | `{cfg_in_width, cfg_in_height}` | 统一输入宽高 |
| `0x24` | `{cfg_in_width, cfg_in_height}` | 兼容旧版地址，语义等同 `0x20` |
| `0x28` | `{cfg_out_width, cfg_out_height}` | 统一输出宽高 |
| `0x2C` | `{cfg_in_ch_groups, cfg_out_channels}` | 输入通道组数按 `8` 一组；输出写总通道数 |
| `0x30` | `{cfg_csc_pad_up, cfg_csc_pad_left, cfg_csc_ky, cfg_csc_kx}` | 填充与卷积核尺寸 |
| `0x34` | `{cfg_csc_stride_y, cfg_csc_stride_x, cfg_wt_active_banks, cfg_wt_is_odd_oc}` | 步长和权重最后一组有效 bank 信息 |
| `0x38` | `cfg_wt_coords_per_region` | 只使用低 `16` bit |
| `0x40` | `cfg_wt_total_beats` | 权重总 beat 数，继续由软件计算 |
| `0x48` | `{cfg_cacc_relu_en, cfg_cacc_b_total_beats}` | ReLU 与 CACC 预取 beat |
| `0x54` | `{cfg_resadd_relu_en, cfg_pool_pad_zero, cfg_op_mode}` | 模式控制 |
| `0x58` | `cfg_res_base_addr` | 残差输入基地址 |

## 仍保留兼容写口，但硬件已不再依赖

| 地址 | 说明 |
| --- | --- |
| `0x3C` | 旧版 `cfg_buf_max_ch_groups/cfg_buf_max_col_blocks`，现在由硬件自动换算 |
| `0x3E` | 旧版 `cfg_buf_min_calc_rows`，现在由硬件按 `Ky` 自动换算 |
| `0x4C` | 旧版 `cfg_csc_co_groups/cfg_csc_ci_groups`，现在只兼容低 `16` bit 的输入通道组写入 |
| `0x50` | 旧版 `cfg_wt_total_co_groups/cfg_out_ch_groups`，现在改为硬件自动换算 |

## 顶层硬件自动换算项

| 内部量 | 公式 |
| --- | --- |
| `cfg_csc_w_in / cfg_csc_h_in` | `cfg_in_width / cfg_in_height` |
| `cfg_csc_w_out_blocks` | `ceil(cfg_out_width / 8)` |
| `cfg_cbuf_max_col_blocks` | `ceil(cfg_in_width / 8)` |
| `cfg_cbuf_max_ch_groups` | `cfg_in_ch_groups` |
| `cfg_rbuf_max_col_blocks` | `ceil(cfg_out_width / 8)` |
| `cfg_rbuf_max_ch_groups` | `ceil(cfg_out_channels / 8)` |
| `cfg_csc_ci_groups` | `cfg_in_ch_groups` |
| `cfg_csc_co_groups` | `ceil(cfg_out_channels / 16)` |
| `cfg_wt_total_co_groups` | `ceil(cfg_out_channels / 16)` |
| `cfg_out_ch_groups` | `ceil(cfg_out_channels / 8)` |

## 特别说明

- `CSC` 里的输出通道组仍然是 `16` 通道一组。
- `OBUF/WDMA/Pool/ResAdd/RBUF` 侧的输出通道组仍然是 `8` 通道一组。
- 这两个粒度没有被混用，只是统一由 `cfg_out_channels` 在顶层分别换算。
