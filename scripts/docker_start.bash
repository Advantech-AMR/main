#!/usr/bin/env bash
# ==============================================================================
# Docker Compose Startup Script (Simplified)
# ==============================================================================
# This script manages the lifecycle of the AMR ROS 2 Docker containers.
# It reads active module configurations directly from the .env file.
#
# Usage:
#   ./scripts/docker_start.bash          # Start services based on .env
#   ./scripts/docker_start.bash --sim    # Force simulation mode
#   ./scripts/docker_start.bash --down   # Stop all services
# ==============================================================================

set -e

# Load .env file if it exists
if [ -f ".env" ]; then
  # Sourcing .env directly (ignoring comments)
  export $(grep -v '^#' .env | xargs)
fi

# Default environment values if not set
export ENABLE_WEB_CONTROLLER=${ENABLE_WEB_CONTROLLER:-false}
export SIMULATE_MODE=${SIMULATE_MODE:-false}
export APP_MODE=${APP_MODE:-auto_explore}
export WORLD_NAME=${WORLD_NAME:-my-nav-map}
export MAP_PATH=${MAP_PATH:-/worlds/virtual/my-nav-map/maps/slam_map.yaml}
export ZED_CAMERA_MODEL=${ZED_CAMERA_MODEL:-zed2i}
export ENABLE_RVIZ=${ENABLE_RVIZ:-false}

CMD="up"
USE_SIM=false

# Auto-enable simulation if SIMULATE_MODE is true in env
if [ "$SIMULATE_MODE" = "true" ]; then
  USE_SIM=true
fi

# Parse simple options
for arg in "$@"; do
  if [ "$arg" = "--down" ] || [ "$arg" = "-d" ] || [ "$arg" = "down" ] || [ "$arg" = "stop" ]; then
    CMD="down"
  elif [ "$arg" = "--sim" ] || [ "$arg" = "-s" ] || [ "$arg" = "sim" ]; then
    USE_SIM=true
  fi
done

# Verification of execution context
if [ ! -f "docker-compose.yml" ]; then
  echo "Error: docker-compose.yml not found."
  echo "Please run this script from the workspace root (main/ directory):"
  echo "  ./scripts/docker_start.bash"
  exit 1
fi

if [ "$CMD" = "down" ]; then
  echo "Stopping all Docker Compose services..."
  docker compose down
  exit 0
fi

# Force SIMULATE_MODE to true if USE_SIM flag was passed
if [ "$USE_SIM" = true ]; then
  export SIMULATE_MODE="true"
fi

# Print active configurations
echo ">>> Launching AMR Docker environment..."
echo "----------------------------------------"
echo "  Run Mode (APP_MODE):    $APP_MODE"
echo "  Simulation (Sim Mode):  $SIMULATE_MODE"
if [ "$SIMULATE_MODE" = "true" ]; then
  echo "  Virtual World:          $WORLD_NAME"
fi
echo "  Map Path:               $MAP_PATH"
if [ "$APP_MODE" = "zed_detect" ] || [ "$APP_MODE" = "zed_mapping" ]; then
  echo "  ZED Camera Model:       $ZED_CAMERA_MODEL"
  echo "  Enable RViz2:           $ENABLE_RVIZ"
fi
if [ "$APP_MODE" = "free" ]; then
  echo "  [Free Mode Startup Options]:"
  echo "    START_BASE_CONTROL:   $START_BASE_CONTROL"
  echo "    START_LIDAR:          $START_LIDAR"
  echo "    START_SLAM_TOOLBOX:   $START_SLAM_TOOLBOX"
  echo "    START_NAV2:           $START_NAV2"
  echo "    START_AUTO_EXPLORER:  $START_AUTO_EXPLORER"
  echo "    START_ZED_CAMERA:     $START_ZED_CAMERA"
  echo "    START_ZED_VISUALIZER: $START_ZED_VISUALIZER"
  echo "    START_ZED_MAPPING:    $START_ZED_MAPPING"
  echo "    ENABLE_RVIZ:          $ENABLE_RVIZ"
fi
echo "----------------------------------------"
echo "  Web Controller:         $ENABLE_WEB_CONTROLLER"
echo "----------------------------------------"

# Run docker compose
if [ "$SIMULATE_MODE" = "true" ]; then
  echo "Starting services in Simulation mode (Gazebo)..."
else
  echo "Starting core services in Physical mode..."
fi

docker compose up -d

echo "----------------------------------------"
echo "Services launched successfully! Run 'docker compose ps' to check status."
echo "----------------------------------------"
