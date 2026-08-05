import sys
import os
import urllib.request
from pathlib import Path
from ultralytics import YOLO

ONNX_PATH = "yolo26n.onnx"
IMG_PATH = ""

def main():
    # 1. 取得 ONNX 模型路徑
    onnx_path = ONNX_PATH
    if len(sys.argv) > 1:
        onnx_path = sys.argv[1]
        
    if not os.path.exists(onnx_path):
        print(f"Error: ONNX model file '{onnx_path}' not found!")
        print("Please export the model first or run python yolo_export.py")
        sys.exit(1)
        
    print(f"Loading ONNX model from: {onnx_path}")
    # 載入 ONNX 模型 (必須指定 task="detect")
    model = YOLO(onnx_path, task="detect")
    
    # 2. 取得測試影像路徑
    image_path = IMG_PATH
    if len(sys.argv) > 2:
        image_path = sys.argv[2]
        
    if not os.path.exists(image_path):
        print(f"Test image '{image_path}' not found. Downloading a sample image...")
        # 下載 Ultralytics 官方的測試巴士圖片
        sample_url = "https://raw.githubusercontent.com/ultralytics/ultralytics/main/ultralytics/assets/bus.jpg"
        try:
            urllib.request.urlretrieve(sample_url, image_path)
            print(f"Successfully downloaded sample image to: {image_path}")
        except Exception as e:
            print(f"Failed to download sample image: {e}")
            sys.exit(1)
            
    print(f"Running inference on: {image_path}")
    
    # 3. 執行推論
    results = model(image_path)
    
    # 4. 印出偵測結果
    print("\n=== Detection Results ===")
    boxes = results[0].boxes
    if len(boxes) == 0:
        print("No objects detected.")
    else:
        for i, box in enumerate(boxes):
            class_id = int(box.cls[0])
            class_name = model.names[class_id] if hasattr(model, 'names') and class_id in model.names else f"Class {class_id}"
            conf = float(box.conf[0])
            xyxy = box.xyxy[0].tolist()
            print(f"[{i}] {class_name}: Conf={conf:.2f}, Box=[xmin={xyxy[0]:.1f}, ymin={xyxy[1]:.1f}, xmax={xyxy[2]:.1f}, ymax={xyxy[3]:.1f}]")
        
    # 5. 儲存結果圖片
    output_path = "result.jpg"
    results[0].save(filename=output_path)
    print(f"\nResult visualization saved to: {Path(output_path).resolve()}")

if __name__ == "__main__":
    main()
