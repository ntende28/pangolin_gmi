#!/bin/bash

source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash

killall -9 rosmaster

roslaunch pangolin_gmi_bringup pangolin_gmi_bringup.launch