#!/usr/bin/env bash
# ==============================================================================
# Docker Compose Startup Script (Simplified)
# ==============================================================================
# This script manages the lifecycle of the AMR ROS 2 Docker containers.
# It reads active module configurations directly from the .env file.
#
# Usage:
#   ./scripts/docker_start.bash          # Start core services
#   ./scripts/docker_start.bash --sim    # Start simulation profile
#   ./scripts/docker_start.bash --down   # Stop all services
# ==============================================================================

set -e

# Load .env file for display purposes if it exists
if [ -f ".env" ]; then
  # Sourcing .env directly (ignoring comments)
  export $(grep -v '^#' .env | xargs)
fi

# Default environment values if not set
export ENABLE_WEB_CONTROLLER=${ENABLE_WEB_CONTROLLER:-false}
export ENABLE_CUSTOM_BOUNDARY=${ENABLE_CUSTOM_BOUNDARY:-false}
export ENABLE_MAP_INTEGRATION=${ENABLE_MAP_INTEGRATION:-false}

CMD="up"
USE_SIM=false

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

# Print active modules configuration
echo ">>> Launching AMR Docker environment..."
echo "----------------------------------------"
echo "  Web Controller:   $ENABLE_WEB_CONTROLLER"
echo "  Custom Boundary:  $ENABLE_CUSTOM_BOUNDARY"
echo "  Map Integration:  $ENABLE_MAP_INTEGRATION"
echo "  Simulation (Gazebo): $USE_SIM"
echo "----------------------------------------"

# Run docker compose
if [ "$USE_SIM" = true ]; then
  echo "Starting services with simulator profile (sim)..."
  docker compose --profile sim up -d
else
  echo "Starting core services (robot_base, custom_packages, zed_packages)..."
  docker compose up -d
fi

echo "----------------------------------------"
echo "Services launched successfully! Run 'docker compose ps' to check status."
echo "----------------------------------------"
