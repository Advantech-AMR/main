#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi

HAS_PROCESS=false

if [ "$APP_MODE" = "free" ]; then
  if [ "$SIMULATE_MODE" = "true" ]; then
    if [ "$START_ZED_CAMERA" = "true" ] || [ "$START_ZED_MAPPING" = "true" ] || [ "$START_ZED_VISUALIZER" = "true" ]; then
      echo "Error: ZED nodes are physical only. Cannot start ZED in simulation mode."
      exit 1
    fi
  fi

  if [ "$START_ZED_CAMERA" = "true" ]; then
    echo "[zed_packages] Starting ZED Camera..."
    ros2 launch zed_wrapper zed_camera.launch.py camera_model:=$ZED_CAMERA_MODEL &
    HAS_PROCESS=true
  fi

  if [ "$START_ZED_MAPPING" = "true" ]; then
    echo "[zed_packages] Starting ZED Object Mapping..."
    ros2 launch zed_obj_mapping mapping_all.launch.py &
    HAS_PROCESS=true
  fi

  if [ "$START_ZED_VISUALIZER" = "true" ]; then
    echo "[zed_packages] Starting ZED Visualizer..."
    ros2 launch zed_obj_det_visualizer visualizer.launch.py &
    HAS_PROCESS=true
  fi

  if [ "$ENABLE_RVIZ" = "true" ]; then
    echo "[zed_packages] Starting RViz2..."
    rviz2 &
    HAS_PROCESS=true
  fi

  if [ "$HAS_PROCESS" = "true" ]; then
    wait
  else
    echo "[zed_packages] No active ZED modules in free mode. Sleep infinity..."
    sleep infinity
  fi

elif [ "$APP_MODE" = "zed_detect" ]; then
  if [ "$SIMULATE_MODE" = "true" ]; then
    echo "Error: ZED modes are physical only. Exiting..."
    exit 1
  fi
  echo "[zed_packages] Starting ZED Object Detection..."
  ros2 launch zed_wrapper zed_camera.launch.py camera_model:=$ZED_CAMERA_MODEL &
  
  if [ "$ENABLE_RVIZ" = "true" ]; then
    echo "[zed_packages] Launching RViz2 and ZED Visualizer..."
    rviz2 -d /rviz2_config/zed_detect.rviz &
    ros2 launch zed_obj_det_visualizer visualizer.launch.py &
  fi
  wait
  
elif [ "$APP_MODE" = "zed_mapping" ]; then
  if [ "$SIMULATE_MODE" = "true" ]; then
    echo "Error: ZED modes are physical only. Exiting..."
    exit 1
  fi
  echo "[zed_packages] Starting ZED Object Mapping..."
  ros2 launch zed_wrapper zed_camera.launch.py camera_model:=$ZED_CAMERA_MODEL &
  ros2 launch zed_obj_mapping mapping_all.launch.py &
  
  if [ "$ENABLE_RVIZ" = "true" ]; then
    echo "[zed_packages] Launching RViz2..."
    rviz2 -d /rviz2_config/zed_obj_mapping_2d.rviz &
  fi
  wait
  
else
  echo "[zed_packages] ZED mode not selected. Sleep infinity..."
  sleep infinity
fi
