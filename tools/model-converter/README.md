## Model Converter
> 此資料夾裡面有可以把模型轉換成 onnx 的工具

### Setup
```bash
# Switch path to this place
# cd tools/model-converter/
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Execute
1. 編輯 `yolo_export.py`
  ```python
  MODEL_PATH = "<你的 .pt 模型路徑>"
  ```
2. 執行 `yolo_export.py`
  ```bash
  python yolo_export.py
  ```
3. 將輸出的 `.onnx` 模型權重檔案複製到專案根目錄底下 `object_detection_models/`

### Test ONNX Model
1. 編輯 `test_onnx.py`
  ```python
  ONNX_PATH = "<YOUR_MODEL_PATH>"
  IMG_PATH = "<YOUR_IMAGE_PATH>"
  ```
2. 執行 `test_onnx.py`