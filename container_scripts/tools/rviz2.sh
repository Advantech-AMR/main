#!/usr/bin/env bash

# Source ROS environment
source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi

# Determine the RViz2 configuration based on the active APP_MODE and sub-mode switches
RVIZ_CONFIG=""

case "$APP_MODE" in
  "auto_explore")
    RVIZ_CONFIG="/rviz2_config/auto_explorer.rviz"
    ;;
  "zed_detect")
    RVIZ_CONFIG="/rviz2_config/zed_detect.rviz"
    ;;
  "zed_mapping")
    RVIZ_CONFIG="/rviz2_config/zed_obj_mapping_2d.rviz"
    ;;
  "slam"|"nav2"|"slam_nav2")
    RVIZ_CONFIG="/rviz2_config/wheeltec.rviz"
    ;;
  "free")
    # For free mode, we check which components are enabled
    if [ "$START_AUTO_EXPLORER" = "true" ]; then
      RVIZ_CONFIG="/rviz2_config/auto_explorer.rviz"
    elif [ "$START_ZED_MAPPING" = "true" ]; then
      RVIZ_CONFIG="/rviz2_config/zed_obj_mapping_2d.rviz"
    elif [ "$START_ZED_VISUALIZER" = "true" ] || [ "$START_ZED_CAMERA" = "true" ]; then
      RVIZ_CONFIG="/rviz2_config/zed_detect.rviz"
    elif [ "$START_SLAM_TOOLBOX" = "true" ] || [ "$START_NAV2" = "true" ]; then
      RVIZ_CONFIG="/rviz2_config/wheeltec.rviz"
    else
      # Fallback: if no specific modules are enabled, run empty RViz
      RVIZ_CONFIG=""
    fi
    ;;
  *)
    # Fallback/unknown APP_MODE
    RVIZ_CONFIG=""
    ;;
esac

if [ "$ENABLE_RVIZ" = "true" ]; then
  echo "[tools/rviz2] Starting RViz2..."
  if [ -n "$RVIZ_CONFIG" ]; then
    if [ -f "$RVIZ_CONFIG" ]; then
      echo "[tools/rviz2] Using RViz config: $RVIZ_CONFIG"
      rviz2 -d "$RVIZ_CONFIG" &
    else
      echo "[tools/rviz2] Warning: RViz config $RVIZ_CONFIG not found, launching default RViz2"
      rviz2 &
    fi
  else
    echo "[tools/rviz2] Launching default RViz2 (no config specified)"
    rviz2 &
  fi
else
  echo "[tools/rviz2] RViz2 is disabled (ENABLE_RVIZ is not true)."
fi
