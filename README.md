## 前置作業
### 載入內部的 Git 子專案
* 見 [git-manage](git-manage/)，執行 **初始化**

### 將 zed-ros2-examples 裡面的某些目錄設為不編譯
* `zed_packages/src/zed-ros2-examples/tools/benchmark/zed_benchmark`
* `zed_packages/src/zed-ros2-examples/tools/benchmark/zed_benchmark_component`
將以上兩個目錄都加上 `COLCON_IGNORE` 空文件，代表 colcon 預設不編譯這兩個套件，避免因為編譯失敗導致整個工作區無法編譯
* 以上操作可以用以下腳本替代
    ```bash
    touch zed_packages/src/zed-ros2-examples/tools/benchmark/zed_benchmark/COLCON_IGNORE zed_packages/src/zed-ros2-examples/tools/benchmark/zed_benchmark_component/COLCON_IGNORE
    ```

### 打開影像辨識功能
* 在 `zed_packages/src/zed-ros2-wrapper/zed_wrapper/config/common_stereo.yaml` 中修改 
    ```yaml
    object_detection:
      od_enabled: true # True to enable Object Detection
    ```

## Docker 佈署方式
### Docker Build
* 在專案根目錄有 Dockerfile.base，這是底層鏡像，包含 ros2 jazzy 基礎、ZED ROS2 相關套件、其他 ROS2 套件等

## 資料夾內容
* `robot_base/`: 包含 ros2 以及控制車輛的基礎套件，包含 Serial, Lidar, nav2, keyboard control, slam, rviz2 等基礎套件
* `custom_packages/`: 包含自訂套件，包含 auto_explorer, custom_boundary, map_integration, wheeltec_web_teleop 等自訂套件
* `zed_packages/`: 包含 ZED ROS2 相關套件的 source code，透過 git submodule 管理，以及一些依賴 zed packages 的自製套件 (位於 `zed_packages/src/custom-packages/`)
* `backups/`: 包含一些備份的資料夾或檔案，此目錄不會被 Git 同步

## 打開方式
### 打開純 slam mapping
```bash
docker compose exec robot_base bash -c "source /opt/ros/jazzy/setup.bash && source /workspace/install/setup.bash && ros2 launch wheeltec_launch slam.launch.py"
# 打開鍵盤遙控
docker compose exec robot_base bash -c "source /opt/ros/jazzy/setup.bash && source /workspace/install/setup.bash && ros2 run teleop_twist_keyboard teleop_twist_keyboard"
```
### 打開純 nav2
```bash
docker compose exec robot_base bash -c "source /opt/ros/jazzy/setup.bash && source /workspace/install/setup.bash && ros2 launch wheeltec_launch navigation.launch.py"
```
### 打開 slam mapping + nav2 (自動探索會使用)
```bash
docker compose exec robot_base bash -c "source /opt/ros/jazzy/setup.bash && source /workspace/install/setup.bash && ros2 launch wheeltec_launch slam_with_navigation.launch.py"
```
### 啟動自動探索
```bash
# 開啟 nav2 等底層套件
docker compose exec robot_base bash -c "source /opt/ros/jazzy/setup.bash && source /workspace/install/setup.bash && ros2 launch wheeltec_launch slam_with_navigation.launch.py"

# 開啟 auto explore node
docker compose exec custom_packages bash -c "source /opt/ros/jazzy/setup.bash && source /workspace/install/setup.bash && ros2 launch auto_explorer auto_exploration.launch.py"
```

## 控制方式
### 自動探索流程相關
* 開始/繼續: 
    ```bash
    ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'start'}"
    ```
* 暫停: 
    ```bash
    ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'pause'}"
    ```
* 中斷 / 停止
    ```bash
    ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'stop'}"
    ```
* 重設
    ```bash
    ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'reset'}"
    ```

### 手動儲存 map (關鍵!)
  ```bash
  ros2 topic pub -1 /map_control std_msgs/msg/String "{data: 'save_map'}"
  ros2 topic pub -1 /map_control std_msgs/msg/String "{data: 'save_map:my_first_map'}"  # 可以自訂檔名
  ```

### 手動控制導航點
  ```bash
  # 到 (x,y) 並且 facing angle
  ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'goto 1.0 2.5 0.0'}"

  # 到 (x,y)
  ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'goto 1.0 2.5'}"
  ```

### 儲存當下作為新的探索起點
  ```bash
  ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'save_start'}"
  ```

---

## ⚡ 一鍵啟動 (Docker Compose 自動帶起)
您可以在執行 `docker compose up -d` 時，透過**環境變數**直接控制是否開啟 `web controller`、`custom_boundary` 與 `map_integration`：

* **1. 預設模式（僅開啟 SLAM+導航底層 與 純自動探索）**：
  ```bash
  docker compose up -d
  ```

* **2. 啟動自動探索 + 網頁控制器 (Web Controller)**：
  ```bash
  ENABLE_WEB_CONTROLLER=true docker compose up -d
  ```

* **提示**：可以新增 `.env` 檔案，將前面的啟動參數都寫在裡面。