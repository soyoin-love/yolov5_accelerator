# 精简版寄存器说明

## 软件必写寄存器

| 地址 | 含义 |
| --- | --- |
| `0x10` | 输入特征图基地址 `cfg_f_base_addr` |
| `0x14` | 权重基地址 `cfg_wt_base_addr` |
| `0x18` | 偏置基地址 `cfg_b_base_addr` |
| `0x1C` | 输出特征图基地址 `cfg_wdma_base_addr` |
| `0x20` | `{cfg_in_width, cfg_in_height}` |
| `0x28` | `{cfg_out_width, cfg_out_height}` |
| `0x2C` | `{cfg_in_ch_groups, cfg_out_channels}` |
| `0x30` | `{cfg_csc_pad_up, cfg_csc_pad_left, cfg_csc_ky, cfg_csc_kx}` |
| `0x34` | `{cfg_csc_stride_y, cfg_csc_stride_x, cfg_wt_active_banks, cfg_wt_is_odd_oc}` |
| `0x38` | `cfg_wt_coords_per_region[15:0]` |
| `0x40` | `cfg_wt_total_beats` |
| `0x48` | `{cfg_cacc_relu_en, cfg_cacc_b_total_beats}` |
| `0x54` | `{cfg_resadd_relu_en, cfg_pool_pad_zero, cfg_op_mode}` |
| `0x58` | 残差输入基地址 `cfg_res_base_addr` |

## virtual concat 可选寄存器

| 地址 | 含义 |
| --- | --- |
| `0x5C` | 第二片输入特征图基地址 `cfg_cat_src1_base_addr` |
| `0x60` | `{cfg_cat_en, cfg_cat_src0_ch_groups}`，其中 `cfg_cat_src0_ch_groups` 表示第一片输入占用的 8 通道组个数 |
| `0x64` | `cfg_cat_src0_line_stride`，写 `0` 表示按标准布局自动推导 |
| `0x68` | `cfg_cat_src1_line_stride`，写 `0` 表示按标准布局自动推导 |
| `0x6C` | `cfg_cat_src0_surface_stride`，写 `0` 表示按标准布局自动推导 |
| `0x70` | `cfg_cat_src1_surface_stride`，写 `0` 表示按标准布局自动推导 |

## virtual concat 语义

- `concat` 不作为独立算子存在，而是融入下一层卷积的特征装载过程。
- `cfg_in_ch_groups` 表示拼接后的总输入通道组数。
- `cfg_cat_src0_ch_groups` 表示第一片输入占用的前半段通道组数。
- 第二片输入占用的通道组数由硬件自动按 `cfg_in_ch_groups - cfg_cat_src0_ch_groups` 计算。
- 当 `cfg_cat_en = 0` 时，上述 concat 寄存器全部忽略，功能与普通卷积输入一致。

## stride 地址公式

在 `cfg_cat_en = 1` 时，CDMA 读地址按下式生成：

```text
addr = base
     + row    * line_stride
     + ch_grp * surface_stride
     + beat   * 16
```

其中：

- `base` 为 `cfg_f_base_addr` 或 `cfg_cat_src1_base_addr`
- `line_stride` 为一整行所有通道组跨过的字节数
- `surface_stride` 为同一行相邻通道组跨过的字节数
- `beat` 为同一通道组内的 128bit 读拍序号

## 硬件自动推导

- 输入每行 beat 数：`ceil(cfg_in_width / 2)`
- 默认 `surface_stride`：`ceil(cfg_in_width / 2) * 16`
- 默认 `line_stride`：`默认 surface_stride * 当前源通道组数`
- 输入像素块数：`ceil(cfg_in_width / 8)`
- 输出像素块数：`ceil(cfg_out_width / 8)`
- `CSC` 输出通道组：`ceil(cfg_out_channels / 16)`
- `OBUF/WDMA/Pool/ResAdd/RBUF` 输出通道组：`ceil(cfg_out_channels / 8)`

## 特别注意

- `CSC` 的输出通道组粒度是 `16`。
- `OBUF/WDMA/Pool/ResAdd/RBUF` 的输出通道组粒度是 `8`。
- 这两种粒度都由同一个 `cfg_out_channels` 在顶层分别换算，软件侧不需要重复配置。
- 对标准连续布局，软件层通常只需要配置 `0x5C` 和 `0x60`，其余 concat stride 寄存器写 `0` 即可。
