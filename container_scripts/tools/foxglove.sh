#!/usr/bin/env bash

# Source ROS environment
source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi

if [ "$ENABLE_FOXGLOVE" = "true" ]; then
  echo "[tools/foxglove] Starting Foxglove..."
  ros2 launch foxglove_bridge foxglove_bridge_launch.xml &
else
  echo "[tools/foxglove] Foxglove is disabled (ENABLE_FOXGLOVE is not true)."
fi
