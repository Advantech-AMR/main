#!/usr/bin/env bash
source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi

HAS_PROCESS=false

if [ "$ENABLE_FOXGLOVE" = "true" ]; then
  echo "[custom_packages] Starting Foxglove..."
  ros2 launch foxglove_bridge foxglove_bridge_launch.xml & 
fi

if [ "$APP_MODE" = "free" ]; then
  echo "[robot_base] Starting Free Mode..."

  if [ "$SIMULATE_MODE" = "true" ]; then
    echo "[robot_base] Starting Virtual Mode (Gazebo) simulation in free mode..."
    WORLD_SDF="/worlds/virtual/$WORLD_NAME/$WORLD_NAME.sdf"
    if [ ! -f "$WORLD_SDF" ]; then
      echo "Error: World SDF file $WORLD_SDF not found!"
      exit 1
    fi

    if [ "$START_SLAM_TOOLBOX" = "true" ] && [ "$START_NAV2" = "true" ]; then
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF slam:=False &
      sleep 5
      ros2 launch slam_toolbox online_async_launch.py &
    elif [ "$START_SLAM_TOOLBOX" = "true" ]; then
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF slam:=True &
    elif [ "$START_NAV2" = "true" ]; then
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF map:=$MAP_PATH slam:=False &
    else
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF slam:=False &
    fi
    HAS_PROCESS=true

  else
    echo "[robot_base] Starting Physical Mode nodes in free mode..."
    
    # 根據開關執行高階整合啟動，或獨立子節點
    if [ "$START_SLAM_TOOLBOX" = "true" ] && [ "$START_NAV2" = "true" ]; then
      ros2 launch wheeltec_launch slam_with_navigation.launch.py open_rviz:=False &
      HAS_PROCESS=true
    elif [ "$START_SLAM_TOOLBOX" = "true" ]; then
      ros2 launch wheeltec_launch slam.launch.py &
      HAS_PROCESS=true
    elif [ "$START_NAV2" = "true" ]; then
      ros2 launch wheeltec_launch navigation.launch.py map:=$MAP_PATH &
      HAS_PROCESS=true
    else
      if [ "$START_BASE_CONTROL" = "true" ]; then
        echo "[robot_base] Starting base serial EKF control..."
        ros2 launch base_control_ros2 00_base_control.launch.py &
        HAS_PROCESS=true
      fi
      if [ "$START_LIDAR" = "true" ]; then
        echo "[robot_base] Starting Lidar..."
        ros2 launch sllidar_ros2 sllidar_a2m12_launch.py &
        HAS_PROCESS=true
      fi
    fi
  fi

  if [ "$HAS_PROCESS" = "true" ]; then
    wait
  else
    echo "[robot_base] No active robot_base modules in free mode. Sleep infinity..."
    sleep infinity
  fi

elif [ "$APP_MODE" = "slam" ] || [ "$APP_MODE" = "nav2" ] || [ "$APP_MODE" = "slam_nav2" ] || [ "$APP_MODE" = "auto_explore" ]; then
  
  if [ "$SIMULATE_MODE" = "true" ]; then
    echo "[robot_base] Starting Virtual Mode (Gazebo) for $APP_MODE..."
    
    WORLD_SDF="/worlds/virtual/$WORLD_NAME/$WORLD_NAME.sdf"
    if [ ! -f "$WORLD_SDF" ]; then
      echo "Error: World SDF file $WORLD_SDF not found!"
      exit 1
    fi
    
    if [ "$APP_MODE" = "slam" ]; then
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF slam:=True
    
    elif [ "$APP_MODE" = "nav2" ]; then
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF map:=$MAP_PATH slam:=False
    
    elif [ "$APP_MODE" = "slam_nav2" ] || [ "$APP_MODE" = "auto_explore" ]; then
      ros2 launch nav2_bringup tb3_simulation_launch.py headless:=False world:=$WORLD_SDF slam:=False &
      sleep 5
      ros2 launch slam_toolbox online_async_launch.py &
      wait
    fi

  else
    echo "[robot_base] Starting Physical Mode for $APP_MODE..."
    
    if [ "$APP_MODE" = "slam" ]; then
      ros2 launch wheeltec_launch slam.launch.py
      
    elif [ "$APP_MODE" = "nav2" ]; then
      ros2 launch wheeltec_launch navigation.launch.py map:=$MAP_PATH
      
    elif [ "$APP_MODE" = "slam_nav2" ] || [ "$APP_MODE" = "auto_explore" ]; then
      ros2 launch wheeltec_launch slam_with_navigation.launch.py open_rviz:=False
    fi
  fi

elif [ "$APP_MODE" = "zed_detect" ] || [ "$APP_MODE" = "zed_mapping" ]; then
  if [ "$SIMULATE_MODE" = "true" ]; then
    echo "Error: ZED modes are physical only. Please set SIMULATE_MODE=false."
    exit 1
  fi
  if [ "$APP_MODE" = "zed_mapping" ]; then
    echo "[robot_base] zed_mapping selected. Starting SLAM and Navigation..."
    ros2 launch wheeltec_launch slam_with_navigation.launch.py open_rviz:=False
  else
    echo "[robot_base] zed_detect selected. Starting base serial control for physical robot..."
    ros2 launch base_control_ros2 00_base_control.launch.py
  fi
else
  echo "Unknown APP_MODE: $APP_MODE. Sleep infinity..."
  sleep infinity
fi
