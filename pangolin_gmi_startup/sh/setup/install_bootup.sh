#!/bin/bash

# ROS_DISTRO="noetic"


# OPT_PATH="/opt/ros/$ROS_DISTRO/setup.bash"
# if [ -f $OPT_PATH ]; then
#     source /opt/ros/$ROS_DISTRO/setup.bash
# else
#     exit 1
# fi

# CATKIN_PATH="$HOME/catkin_ws/devel/setup.bash"
# if [ -f $CATKIN_PATH ]; then
#     source $HOME/catkin_ws/devel/setup.bash
# else
#     exit 1
# fi

# if pidof rosout >/dev/null
# then
#     killall -9 rosmaster
#     killall -9 roscore
# fi

source ~/.bashrc

PKG_NAME="pangolin_gmi_startup"
SERVICE_FILE="pangolin_gmi_startup.service"
SCRIPT_FILE="startup.sh"

SERVICE_DIR="/etc/systemd/system"
PKG_DIR="$(rospack find $PKG_NAME 2>/dev/null)"
if [ $? -eq 0 -a -d "$PKG_DIR" ]; then
    SCRIPT_DIR="$PKG_DIR/sh"
else
    exit 1
fi

TEMP_PATH="/tmp/$SERVICE_FILE"
SERVICE_PATH="$SERVICE_DIR/$SERVICE_FILE"
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_FILE"

# SERVICE_CONTENT="
# [Unit]
# Description=moverobotic startup service
# After=network.target

# [Service]
# Type=simple
# User=$USER
# Environment=DISPLAY=:0
# Environment="ROS_HOME=/$HOME/.ros"
# ExecStart="$SCRIPT_PATH"

# [Install]
# WantedBy=multi-user.target
# "
# Environment=DISPLAY=:0

SERVICE_CONTENT="
[Unit]
Description=pangolin_gmi startup service
After=network.target

[Service]
Type=simple
User=$USER
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u $USER)
Environment=PULSE_SERVER=/run/user/$(id -u $USER)/pulse/native
Environment=ROS_HOME=/$HOME/.ros
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=5
TimeoutStartSec=20

[Install]
WantedBy=multi-user.target
"

# SERVICE_CONTENT="
# [Unit]
# Description=pangolin_gmi startup service
# After=network.target

# [Service]
# Type=simple
# User=$USER
# Environment=XDG_RUNTIME_DIR=/run/user/$(id -u $USER)
# Environment=PULSE_SERVER=/run/user/$(id -u $USER)/pulse/native
# Environment=ROS_HOME=/$HOME/.ros
# ExecStart=/bin/bash -c \"/usr/bin/pulseaudio --system --disallow-exit --disable-shm --exit-idle-time=-1 & $SCRIPT_PATH\"
# Restart=always
# RestartSec=5
# TimeoutStartSec=20

# [Install]
# WantedBy=multi-user.target
# "


# ###
# [Unit]
# Description=PulseAudio System Server
# After=sound.target

# [Service]
# Type=notify
# ExecStart=/usr/bin/pulseaudio --system --disallow-exit --disable-shm --exit-idle-time=-1
# ExecReload=/bin/kill -HUP $MAINPID
# Restart=on-failure
# LimitMEMLOCK=infinity
# LockPersonality=yes
# ProtectKernelModules=yes
# ProtectKernelTunables=yes
# ProtectControlGroups=yes

# [Install]
# WantedBy=multi-user.target

# ###
# sudo subl /etc/pulse/daemon.conf
# system-instance = yes

# ###
# sudo mkdir -p /var/run/pulse
# sudo chown pulse:pulse /var/run/pulse
# sudo mkdir -p /var/lib/pulse
# sudo chown pulse:pulse /var/lib/pulse

# ###
# subl ~/.config/pulse/client.conf
# autospawn = no
# default-server = /var/run/pulse/native






echo "$SERVICE_CONTENT" > $TEMP_PATH
sudo mv $TEMP_PATH "$SERVICE_PATH"

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_FILE
# sudo systemctl start $SERVICE_FILE

# echo "opt: $OPT_PATH"
# echo "catkin_ws: $CATKIN_PATH"
echo "service: $SERVICE_PATH"
echo "script: $SCRIPT_PATH"
echo "Service for $USER has been created and started"
