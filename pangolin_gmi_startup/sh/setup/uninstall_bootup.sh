#!/bin/bash

SERVICE_FILE="pangolin_gmi_startup.service"
SERVICE_DIR="/etc/systemd/system"
SERVICE_PATH="$SERVICE_DIR/$SERVICE_FILE"

# stop and disable
sudo systemctl stop $SERVICE_FILE
sudo systemctl disable $SERVICE_FILE

# delete service file
if [ -f "$SERVICE_PATH" ]; then
    sudo rm "$SERVICE_PATH"
    if [ -f "$SERVICE_PATH" ]; then
        echo "Failed to remove the file"
        exit 1
    else
        echo "File removed successfully"
    fi
else
    echo "File does not exists, no need to remove"
    exit 1
fi

# reload service
sudo systemctl daemon-reload

echo "service: $SERVICE_PATH"