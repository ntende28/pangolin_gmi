#!/bin/bash
if [ -f ~/opt/ros/$ROS_DISTRO/setup.bash ]; then
    source ~/opt/ros/$ROS_DISTRO/setup.bash
fi
if [ -f ~/catkin_ws/devel/setup.bash ]; then
    source ~/catkin_ws/devel/setup.bash
fi
if pidof rosout >/dev/null
then
    killall -9 rosmaster
    killall -9 roscore
fi

# sleep 10
roslaunch pangolin_gmi_navigation mapping.launch mapping:=false filename:=default simulation:=false rviz:=false
