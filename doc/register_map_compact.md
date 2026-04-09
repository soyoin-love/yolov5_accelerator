# 精简版寄存器说明

## 软件仍需写入

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

## 硬件自动推导

- 输入像素块数 `ceil(cfg_in_width / 8)`
- 输出像素块数 `ceil(cfg_out_width / 8)`
- `CBUF` 输入通道组数直接使用 `cfg_in_ch_groups`
- `CSC` 输出通道组数使用 `ceil(cfg_out_channels / 16)`
- `OBUF/WDMA/Pool/ResAdd/RBUF` 输出通道组数使用 `ceil(cfg_out_channels / 8)`

## 特别注意

- `CSC` 的输出通道组粒度是 `16`。
- `OBUF/WDMA` 以及后级输出侧模块的通道组粒度是 `8`。
- 两种粒度都由同一个 `cfg_out_channels` 在顶层分别换算，不再要求软件重复写两份。
