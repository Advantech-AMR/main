from ultralytics import YOLO

MODEL_PATH = "yolo26n.pt"

# 1. 下載 YOLO26 Nano 模型
model = YOLO(MODEL_PATH) 

# 2. 轉換為 ZED 支援的 ONNX 格式
# 關閉 dynamic=True，改用固定大小 (imgsz=512)，並加上 simplify=True
# 這可以避免 TensorRT 在優化 YOLO26 的 Attention (注意力) 層時，因動態維度推導出 0 而報錯
model.export(format="onnx", opset=12, dynamic=False, imgsz=512, simplify=True)
