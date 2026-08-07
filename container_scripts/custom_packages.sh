#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi

USE_SIM_TIME_ARG="use_sim_time:=false"
if [ "$SIMULATE_MODE" = "true" ]; then
  USE_SIM_TIME_ARG="use_sim_time:=true"
fi

HAS_PROCESS=false

LAUNCHED_AUTO_EXPLORER=false
if [ "$APP_MODE" = "auto_explore" ] || { [ "$APP_MODE" = "free" ] && [ "$START_AUTO_EXPLORER" = "true" ]; }; then
  echo "[custom_packages] Starting Auto Explorer..."
  ros2 launch auto_explorer auto_exploration.launch.py $USE_SIM_TIME_ARG &
  LAUNCHED_AUTO_EXPLORER=true
  HAS_PROCESS=true
  if [ "$SIMULATE_MODE" = "true" ]; then
    sleep 15
    ros2 topic pub -1 /exploration_control std_msgs/msg/String "{data: 'start'}"
  fi
fi

if [ "$ENABLE_WEB_CONTROLLER" = "true" ]; then
  echo "[custom_packages] Starting Web Controller..."
  ros2 run wheeltec_web_teleop web_server &
  HAS_PROCESS=true
fi

if [ "$HAS_PROCESS" = "true" ]; then
  wait
else
  echo "[custom_packages] No active modules. Sleep infinity..."
  sleep infinity
fi
