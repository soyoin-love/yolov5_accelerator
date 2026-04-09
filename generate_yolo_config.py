import math
import argparse


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
):
    # 统一输入/输出宽高，块数与通道组换算交给顶层硬件完成。
    W_out = (W_in - Kx + 2 * Px) // Sx + 1
    W_out = (W_in - Kx + 2 * Px) // Sx + 1
    H_out = (H_in - Ky + 2 * Py) // Sy + 1

    # 复杂的权重/偏置 beat 推导仍保留在软件侧。
    ci_groups = math.ceil(C_in / 8.0)
    ci_groups = math.ceil(C_in / 8.0)
    co_groups_x16 = math.ceil(C_out / 16.0)
    coords_per_region = ci_groups * Kx * Ky

    rem_cout = C_out % 16
    active_banks = 8 if rem_cout == 0 else math.ceil(rem_cout / 2.0)
    is_odd_oc = 1 if (C_out % 2 != 0) else 0
    b_total_beats = math.ceil(C_out / 2.0)

    if co_groups_x16 > 1:
        wt_total_beats = (co_groups_x16 - 1) * coords_per_region * 8 + coords_per_region * active_banks
    else:
        wt_total_beats = coords_per_region * active_banks

    config_dict = {
        0x10: f_base,
        0x14: w_base,
        0x18: b_base,
        0x1C: o_base,
        0x20: (W_in << 16) | H_in,
        0x28: (W_out << 16) | H_out,
        0x2C: (ci_groups << 16) | C_out,
        0x30: (Py << 12) | (Px << 8) | (Ky << 4) | Kx,
        0x34: (Sy << 9) | (Sx << 5) | (active_banks << 1) | is_odd_oc,
        0x38: coords_per_region & 0xFFFF,
        0x40: wt_total_beats,
        0x48: (relu_en << 16) | b_total_beats,
        0x54: (resadd_relu_en << 3) | (pool_pad_zero << 2) | (op_mode & 0x3),
        0x58: res_base,
    }

    with open(filename, "w", encoding="utf-8") as f:
        for addr in sorted(config_dict.keys()):
            f.write(f"{addr:02X} {config_dict[addr]:08X}\n")

    print(f"已生成配置文件: {filename}")
'''
def build_argparser():
    """构建命令行参数。"""
    parser = argparse.ArgumentParser(description="生成精简版 YOLO 加速器寄存器配置文件")
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
    return parser


def main():
    """命令行入口。"""
    args = build_argparser().parse_args()
    generate_yolo_config(**vars(args))

'''

def build_argparser():
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
    return parser


def main():
    args = build_argparser().parse_args()
    generate_yolo_config(**vars(args))


if __name__ == "__main__":
    main()
