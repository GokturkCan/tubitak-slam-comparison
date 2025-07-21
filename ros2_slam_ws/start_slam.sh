#!/usr/bin/env bash
# Eğer bir yerde tanımsız değişken hatası alırsanız, nounset’i devre dışı bırakacağız.
set -eo pipefail

# 1) Kaynak dosyalarını yüklerken nounset’i kapat, sonra tekrar aç
set +u
source /opt/ros/jazzy/setup.bash
source ~/Masaüstü/tubitak/ros2_slam_ws/install/setup.bash
set -u

# 2) RPLIDAR sürücüsünü başlat
ros2 launch rplidar_ros rplidar.launch.py &
PID_LIDAR=$!
sleep 2

# 3) map → laser arası statik TF
ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 map laser &
PID_TF=$!
sleep 1

# 4) SLAM Toolbox’ı parametre dosyasıyla aç
ros2 launch slam_toolbox online_sync_launch.py \
  params_file:=/home/uki/Masaüstü/tubitak/ros2_slam_ws/slam_params.yaml &
PID_SLAM=$!
sleep 2

# 5) RViz’i konfig ile başlat
rviz2 -d ~/Masaüstü/tubitak/ros2_slam_ws/rviz/gmapping.rviz

# RViz kapandığında arka plandaki node’ları temizle
kill $PID_SLAM $PID_TF $PID_LIDAR || true

