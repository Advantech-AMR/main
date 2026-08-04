#!/usr/bin/env bash
# ==============================================================================
# ROS 2 Workspaces Docker Compilation Script
# ==============================================================================
# This script compiles all workspaces (robot_base, zed_packages, custom_packages)
# inside their corresponding Docker Compose containers to avoid permission issues
# and ensure correct build environment.
#
# Usage:
#   ./scripts/ros_compile.bash          # Normal build inside containers
#   ./scripts/ros_compile.bash --clean   # Clean build inside containers
# ==============================================================================

set -e

# Target workspaces / docker compose services
SERVICES=("robot_base" "zed_packages" "custom_packages")

# 1. Verification of execution context
if [ ! -f "docker-compose.yml" ]; then
  echo "Error: docker-compose.yml not found."
  echo "Please run this script from the workspace root (main/ directory):"
  echo "  ./scripts/ros_compile.bash"
  exit 1
fi

# 2. Parse arguments
CLEAN_BUILD=false
for arg in "$@"; do
  if [ "$arg" = "--clean" ] || [ "$arg" = "-c" ] || [ "$arg" = "clean" ]; then
    CLEAN_BUILD=true
  fi
done

# 3. Ensure Docker containers are running
echo ">>> Checking if containers are running..."
# Check how many of the target core services are currently running
RUNNING_COUNT=$(docker compose ps --services --filter "status=running" | grep -E "^(robot_base|zed_packages|custom_packages)$" | wc -l || true)

if [ "$RUNNING_COUNT" -lt 3 ]; then
  echo ">>> Some or all core containers are not running. Starting them with scripts/docker_start.bash..."
  ./scripts/docker_start.bash
else
  echo ">>> All core containers are already running."
fi

# 4. Build workspaces sequentially inside their respective containers
for service in "${SERVICES[@]}"; do
  echo ""
  echo "================================================================================"
  echo " Building Workspace inside Docker Service: $service"
  echo "================================================================================"
  
  # Clean build artifacts if requested
  if [ "$CLEAN_BUILD" = true ]; then
    echo "Cleaning build artifacts inside $service container..."
    docker compose exec -T "$service" rm -rf build install log
  fi
  
  # Run colcon build inside container
  echo "Running colcon build inside $service container..."
  docker compose exec -T "$service" bash -c "source /opt/ros/jazzy/setup.bash && colcon build --symlink-install"
done

echo ""
echo "================================================================================"
echo " All workspaces built successfully inside Docker containers!"
echo "================================================================================"
