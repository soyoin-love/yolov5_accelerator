import argparse


def ceil_div(value, factor):
    """向上取整除法。"""
    return (value + factor - 1) // factor


def calc_wt_resident_en(op_mode, co_groups_x16):
    """根据当前硬件 resident 条件生成权重常驻使能。

    当前设计仅在卷积模式下使用该位，并且要求：
    1. 每个 region 已能容纳 Kx * Ky * ch_in_grp 个地址
    2. 全部 16 通道输出组数量不超过 4 个
    """
    return 1 if (op_mode == 0 and co_groups_x16 <= 4) else 0


def calc_feature_layout(width, ch_groups, bytes_per_beat=16):
    """按当前特征图 DDR 排布推导默认 stride。

    DDR 中一拍为 128bit，即 16 字节，对应 2 个空间位置。
    当前工程默认布局为：
    1. 同一行内先写完整个通道组的所有 beat
    2. 再切到同一行的下一个通道组
    3. 最后切到下一行
    """
    beats_per_row = ceil_div(width, 2)
    surface_stride = beats_per_row * bytes_per_beat
    line_stride = surface_stride * ch_groups
    return {
        "beats_per_row": beats_per_row,
        "surface_stride": surface_stride,
        "line_stride": line_stride,
    }


def generate_yolo_config(
    filename="layer_config.txt",
    W_in=80,
    H_in=80,
    C_in=3,
    C_out=16,
    Kx=6,
    Ky=6,
    Sx=2,
    Sy=2,
    Px=2,
    Py=2,
    relu_en=1,
    op_mode=0,
    pool_pad_zero=0,
    resadd_relu_en=0,
    f_base=0x00000000,
    w_base=0x00020000,
    b_base=0x00040000,
    o_base=0x00060000,
    res_base=0x00080000,
    cat_en=0,
    cat_src0_upsample=0,
    cat_src1_base=0x00000000,
    cat_src0_ch_groups=0,
    cat_src0_line_stride=0,
    cat_src1_line_stride=0,
    cat_src0_surface_stride=0,
    cat_src1_surface_stride=0,
    wt_resident_en=-1,
):
    # 输出宽高依然由软件根据卷积参数推导。
    W_out = (W_in - Kx + 2 * Px) // Sx + 1
    H_out = (H_in - Ky + 2 * Py) // Sy + 1

    # 软件层只保留总输入通道组和总输出通道数这两个基础语义。
    ci_groups = ceil_div(C_in, 8)
    co_groups_x16 = ceil_div(C_out, 16)

    # 这些和权重打包强相关的量继续放在软件层计算。
    coords_per_region = ci_groups * Kx * Ky
    rem_cout = C_out % 16
    active_banks = 8 if rem_cout == 0 else ceil_div(rem_cout, 2)
    is_odd_oc = 1 if (C_out % 2 != 0) else 0
    b_total_beats = ceil_div(C_out, 2)

    if co_groups_x16 > 1:
        wt_total_beats = (co_groups_x16 - 1) * coords_per_region * 8 + coords_per_region * active_banks
    else:
        wt_total_beats = coords_per_region * active_banks

    full_layout = calc_feature_layout(W_in, ci_groups)

    cat_en = 1 if cat_en else 0
    cat_src0_upsample = 1 if cat_src0_upsample else 0
    if cat_en:
        if cat_src0_ch_groups <= 0 or cat_src0_ch_groups >= ci_groups:
            raise ValueError(
                "cat_src0_ch_groups must be in [1, total_input_groups - 1] when cat_en=1"
            )
        cat_src1_ch_groups = ci_groups - cat_src0_ch_groups
        src0_width = ceil_div(W_in, 2) if cat_src0_upsample else W_in
        src0_layout = calc_feature_layout(src0_width, cat_src0_ch_groups)
        src1_layout = calc_feature_layout(W_in, cat_src1_ch_groups)
    else:
        cat_src1_ch_groups = 0
        src0_width = ceil_div(W_in, 2) if cat_src0_upsample else W_in
        src0_layout = calc_feature_layout(src0_width, ci_groups)
        src1_layout = {"beats_per_row": 0, "surface_stride": 0, "line_stride": 0}

    if wt_resident_en < 0:
        wt_resident_en = calc_wt_resident_en(op_mode, co_groups_x16)
    else:
        wt_resident_en = 1 if wt_resident_en else 0

    # stride 配置默认为 0，表示让硬件按标准连续布局自动推导。
    config_dict = {
        0x10: f_base,
        0x14: w_base,
        0x18: b_base,
        0x1C: o_base,
        0x20: res_base,
        0x24: (W_in << 16) | H_in,
        0x28: (W_out << 16) | H_out,
        0x2C: (ci_groups << 16) | C_out,
        0x30: (Py << 12) | (Px << 8) | (Ky << 4) | Kx,
        0x34: (Sy << 9) | (Sx << 5) | (active_banks << 1) | is_odd_oc,
        0x38: coords_per_region & 0xFFFF,
        0x3C: wt_total_beats,
        0x40: (relu_en << 16) | b_total_beats,
        0x44: (resadd_relu_en << 3) | (pool_pad_zero << 2) | (op_mode & 0x3),
        0x48: cat_src1_base,
        0x4C: ((cat_src0_upsample & 0x1) << 17) | ((cat_en & 0x1) << 16) | (cat_src0_ch_groups & 0xFFFF),
        0x50: cat_src0_line_stride,
        0x54: cat_src1_line_stride,
        0x58: cat_src0_surface_stride,
        0x5C: cat_src1_surface_stride,
        0x60: wt_resident_en,
    }

    with open(filename, "w", encoding="utf-8") as f:
        for addr in sorted(config_dict.keys()):
            f.write(f"{addr:02X} {config_dict[addr]:08X}\n")

    return {
        "W_out": W_out,
        "H_out": H_out,
        "ci_groups": ci_groups,
        "co_groups_x16": co_groups_x16,
        "coords_per_region": coords_per_region,
        "active_banks": active_banks,
        "is_odd_oc": is_odd_oc,
        "b_total_beats": b_total_beats,
        "wt_total_beats": wt_total_beats,
        "cat_en": cat_en,
        "cat_src0_upsample": cat_src0_upsample,
        "cat_src0_ch_groups": cat_src0_ch_groups,
        "cat_src1_ch_groups": cat_src1_ch_groups,
        "wt_resident_en": wt_resident_en,
        "full_layout": full_layout,
        "src0_layout": src0_layout,
        "src1_layout": src1_layout,
        "config_dict": config_dict,
    }


def build_argparser():
    """构建命令行参数。"""
    parser = argparse.ArgumentParser(description="Generate compact YOLO accelerator register config")
    parser.add_argument("--filename", default="layer_config.txt")
    parser.add_argument("--W_in", type=int, default=80)
    parser.add_argument("--H_in", type=int, default=80)
    parser.add_argument("--C_in", type=int, default=3)
    parser.add_argument("--C_out", type=int, default=16)
    parser.add_argument("--Kx", type=int, default=6)
    parser.add_argument("--Ky", type=int, default=6)
    parser.add_argument("--Sx", type=int, default=2)
    parser.add_argument("--Sy", type=int, default=2)
    parser.add_argument("--Px", type=int, default=2)
    parser.add_argument("--Py", type=int, default=2)
    parser.add_argument("--relu_en", type=int, default=1)
    parser.add_argument("--op_mode", type=int, default=0)
    parser.add_argument("--pool_pad_zero", type=int, default=0)
    parser.add_argument("--resadd_relu_en", type=int, default=0)
    parser.add_argument("--f_base", type=lambda x: int(x, 0), default=0x00000000)
    parser.add_argument("--w_base", type=lambda x: int(x, 0), default=0x00020000)
    parser.add_argument("--b_base", type=lambda x: int(x, 0), default=0x00040000)
    parser.add_argument("--o_base", type=lambda x: int(x, 0), default=0x00060000)
    parser.add_argument("--res_base", type=lambda x: int(x, 0), default=0x00080000)

    # virtual concat 配置，默认保持关闭。
    parser.add_argument("--cat_en", type=int, default=0)
    parser.add_argument("--cat_src0_upsample", type=int, default=0)
    parser.add_argument("--cat_src1_base", type=lambda x: int(x, 0), default=0x00000000)
    parser.add_argument("--cat_src0_ch_groups", type=int, default=0)
    parser.add_argument("--cat_src0_line_stride", type=lambda x: int(x, 0), default=0)
    parser.add_argument("--cat_src1_line_stride", type=lambda x: int(x, 0), default=0)
    parser.add_argument("--cat_src0_surface_stride", type=lambda x: int(x, 0), default=0)
    parser.add_argument("--cat_src1_surface_stride", type=lambda x: int(x, 0), default=0)
    parser.add_argument("--wt_resident_en", type=int, default=-1,
                        help="-1 表示按 co_groups_x16<=4 自动判断，0/1 表示强制关闭/打开")
    return parser


def main():
    """命令行入口。"""
    args = build_argparser().parse_args()
    result = generate_yolo_config(**vars(args))

    print(f"Generated config file: {args.filename}")
    print(
        "Summary: "
        f"W_out={result['W_out']}, "
        f"H_out={result['H_out']}, "
        f"ci_groups={result['ci_groups']}, "
        f"co_groups_x16={result['co_groups_x16']}, "
        f"wt_total_beats={result['wt_total_beats']}, "
        f"wt_resident_en={result['wt_resident_en']}"
    )

    if result["cat_en"] or result["cat_src0_upsample"]:
        print(
            "Feature load: "
            f"src0_upsample={result['cat_src0_upsample']}, "
            f"src0_groups={result['cat_src0_ch_groups']}, "
            f"src1_groups={result['cat_src1_ch_groups']}, "
            f"auto_src0_line_stride=0x{result['src0_layout']['line_stride']:08X}, "
            f"auto_src1_line_stride=0x{result['src1_layout']['line_stride']:08X}, "
            f"auto_surface_stride=0x{result['src0_layout']['surface_stride']:08X}"
        )


if __name__ == "__main__":
    main()
