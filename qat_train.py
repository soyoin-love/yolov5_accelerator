# import torch
# import torch.ao.quantization as quant
# from models.yolo import Model
import torch
import torch.ao.quantization as quant
import torch.optim as optim
from tqdm import tqdm

from models.yolo import Model
# 新增的 YOLOv5 核心组件导入
from utils.dataloaders import create_dataloader
from utils.loss import ComputeLoss
from utils.general import check_dataset

def fuse_yolov5_model(model):
    """
    遍历网络，仅执行 Conv2d + BatchNorm2d 融合。
    保留独立的 SiLU 激活层，以便后续映射至 FPGA RAM 查找表。
    """
    model.eval()

    for m in model.modules():
        if type(m).__name__ == 'Conv':
            # 确认包含所需子模块
            if hasattr(m, 'conv') and hasattr(m, 'bn'):
                # 仅融合 conv 和 bn
                quant.fuse_modules(m, ['conv', 'bn'], inplace=True)

    return model


def main():
    # ==========================================
    # 1. 准备模型与权重 (修改为 nc=4)
    # ==========================================
    cfg = 'models/yolov5n.yaml'
    model = Model(cfg, ch=3, nc=4)  # 类别数对齐你之前的 27 通道检测头

    weights_path = 'E:/IEEE2026/yolov5-7.0/yolov5-7.0/runs/train/exp9/weights/best.pt'  # 替换为你的真实权重路径
    ckpt = torch.load(weights_path, map_location='cpu')

    # 形状已匹配，直接以严格模式加载即可
    model.load_state_dict(ckpt['model'].state_dict(), strict=True)
    print(">>> 成功加载 FP32 权重 (nc=4 形状匹配完全一致)")

    # ==========================================
    # 2. 执行算子融合
    # ==========================================
    model = fuse_yolov5_model(model)
    print(">>> Conv+BN 融合完成，SiLU 已独立保留，准备映射至 LUT")
    # ==========================================
    # 2.5 加载超参数 (修复 AttributeError)
    # ==========================================
    import yaml
    # 通常使用 yolov5-nano 对应的默认超参数文件
    hyp_path = 'data/hyps/hyp.scratch-low.yaml'
    with open(hyp_path, errors='ignore') as f:
        hyp = yaml.safe_load(f)  # 加载为字典

    # 将超参数字典绑定到模型上，供 ComputeLoss 调用
    model.hyp = hyp
    print(f">>> 已加载超参数配置: {hyp_path}")
    # ==========================================
    # 3. 准备 QAT (量化感知训练) 环境
    # ==========================================
    model.train()
    model.qconfig = quant.get_default_qat_qconfig('fbgemm')
    quant.prepare_qat(model, inplace=True)
    print(">>> QAT 伪量化节点插入完成，可以开始微调！")

    # ... [上方保留原有的第1、2、3步代码] ...
    # quant.prepare_qat(model, inplace=True)
    # print(">>> QAT 伪量化节点插入完成，可以开始微调！")

    # ==========================================
    # 4. 数据加载与基础配置
    # ==========================================
    # 替换为你的车牌数据集 yaml 路径
    data_yaml = 'E:/IEEE2026/yolov5-7.0/yolov5-7.0/data/CRPD_single.yaml'
    data_dict = check_dataset(data_yaml)
    train_path = data_dict['train']

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)

    print(">>> 正在初始化 DataLoader...")
    dataloader, dataset = create_dataloader(
        train_path,
        imgsz=640,
        batch_size=16,  # 根据你的显存调整 (16 或 32)
        stride=32,  # YOLOv5 默认最大下采样步长
        single_cls=False,  # 你的类别数已修正为 4，设为 False
        pad=0.0,
        rect=False,
        workers=4
    )[0:2]

    compute_loss = ComputeLoss(model)
    # 强制约束：QAT 学习率极小，防止破坏预训练权重
    optimizer = optim.SGD(model.parameters(), lr=1e-4, momentum=0.9, weight_decay=0.0005)

    # ==========================================
    # 5. 数据校准 (Calibration)
    # ==========================================
    print(">>> 开始量化校准 (静态统计特征分布)...")
    model.train()  # 必须在 train 模式下，Observer 才会更新
    with torch.no_grad():  # 关闭梯度
        for i, (imgs, _, _, _) in enumerate(dataloader):
            imgs = imgs.to(device, non_blocking=True).float() / 255.0
            model(imgs)
            if i >= 10:  # 跑 10 个 Batch 足够统计稳定的分布范围
                break
    print(">>> 校准完成！")

    # ==========================================
    # 6. QAT 梯度微调 (Fine-tuning)
    # ==========================================
    epochs = 10  # 硬件量化微调通常 10-15 个 Epoch 即可收敛
    print(f">>> 启动 QAT 微调，总 Epoch: {epochs}")

    for epoch in range(epochs):
        model.train()
        pbar = tqdm(enumerate(dataloader), total=len(dataloader), desc=f"Epoch {epoch + 1}/{epochs}")

        for i, (imgs, targets, paths, _) in pbar:
            imgs = imgs.to(device, non_blocking=True).float() / 255.0
            targets = targets.to(device)

            # 前向传播
            pred = model(imgs)

            # 计算损失 (Box, Objectness, Class)
            loss, loss_items = compute_loss(pred, targets)

            # 反向传播与优化
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            # 更新进度条面板
            pbar.set_postfix({
                'box_loss': f"{loss_items[0].item():.4f}",
                'obj_loss': f"{loss_items[1].item():.4f}",
                'cls_loss': f"{loss_items[2].item():.4f}"
            })

    # ==========================================
    # 7. 保存最终量化权重
    # ==========================================
    save_path = 'qat_plate_model_final.pt'
    torch.save(model.state_dict(), save_path)
    print(f">>> QAT 训练结束，带伪量化节点的权重已保存至: {save_path}")
if __name__ == '__main__':
    main()