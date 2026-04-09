import math


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
    # 输出尺寸仍在软件层计算，避免硬件侧重复做复杂推导。
    W_out = (W_in - Kx + 2 * Px) // Sx + 1
    H_out = (H_in - Ky + 2 * Py) // Sy + 1

    # 输入通道组按 8 通道一组。
    ci_groups = math.ceil(C_in / 8.0)

    # 下面这些量仍然保留在软件层，便于兼容现有权重/偏置组织方式。
    co_groups_x16 = math.ceil(C_out / 16.0)
    coords_per_region = ci_groups * Kx * Ky

    rem_cout = C_out % 16
    if rem_cout == 0:
        active_banks = 8
    else:
        active_banks = math.ceil(rem_cout / 2.0)

    is_odd_oc = 1 if (C_out % 2 != 0) else 0
    b_total_beats = math.ceil(C_out / 2.0)

    if co_groups_x16 > 1:
        wt_total_beats = (co_groups_x16 - 1) * coords_per_region * 8 + coords_per_region * active_banks
    else:
        wt_total_beats = coords_per_region * active_banks

    config_dict = {}
    config_dict[0x10] = f_base
    config_dict[0x14] = w_base
    config_dict[0x18] = b_base
    config_dict[0x1C] = o_base

    # 统一输入/输出宽高。
    config_dict[0x20] = (W_in << 16) | H_in
    config_dict[0x28] = (W_out << 16) | H_out

    # 只保留一份输入 8 通道组，以及一份输出总通道数。
    config_dict[0x2C] = (ci_groups << 16) | C_out

    config_dict[0x30] = (Py << 12) | (Px << 8) | (Ky << 4) | Kx
    config_dict[0x34] = (Sy << 9) | (Sx << 5) | (active_banks << 1) | is_odd_oc

    # 0x38 只保留低 16 bit 的 coords_per_region，高 16 bit 的输出块数已改为硬件自动换算。
    config_dict[0x38] = coords_per_region & 0xFFFF
    config_dict[0x40] = wt_total_beats
    config_dict[0x48] = (relu_en << 16) | b_total_beats

    # cfg_op_mode / cfg_pool_pad_zero / cfg_resadd_relu_en
    config_dict[0x54] = (resadd_relu_en << 3) | (pool_pad_zero << 2) | (op_mode & 0x3)
    config_dict[0x58] = res_base

    with open(filename, "w", encoding="utf-8") as f:
        for addr in sorted(config_dict.keys()):
            f.write(f"{addr:02X} {config_dict[addr]:08X}\n")

    print(f"已生成精简版配置文件: {filename}")


if __name__ == "__main__":
    generate_yolo_config()
