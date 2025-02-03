# export ROS_DISTRO=noetic

source ~/.bashrc

sudo apt update -y # update the apt package
sudo apt upgrade -y # upgrade the apt package

# install ufw firewall
sudo apt-get install -y ufw

# install nginx proxy server
sudo apt-get install -y nginx

# install ssh server
sudo apt install openssh-server -y # install ssh
sudo systemctl restart ssh -y # restart the ssh server service

# install node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash # install nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 20 # download version 20 and install

# install node-red
npm install -g --unsafe-perm node-red #download node-red and install

# install ros package
sudo apt-get install ros-$ROS_DISTRO-rplidar-ros -y # install rplidar ros package
sudo apt-get install ros-$ROS_DISTRO-navigation -y # install navigation package
sudo apt-get install ros-$ROS_DISTRO-joy -y # install joy package
sudo apt-get install ros-$ROS_DISTRO-teleop-twist-joy -y # install teleop twist joy package
sudo apt-get install ros-$ROS_DISTRO-teleop-twist-keyboard -y # install teleop twist keyboard package
sudo apt-get install ros-$ROS_DISTRO-twist-mux -y # install twist mux package
sudo apt-get install ros-$ROS_DISTRO-ros-control -y # install ros control package
sudo apt-get install ros-$ROS_DISTRO-ros-controllers -y # install ros controllers package
sudo apt-get install ros-$ROS_DISTRO-serial -y # install ros serial package
sudo apt-get install ros-$ROS_DISTRO-usb-cam -y # install ros usb cam package
sudo apt-get install ros-$ROS_DISTRO-robot-localization -y # install ros robot localization
sudo apt-get install ros-$ROS_DISTRO-audio-common -y # install ros audio common
sudo apt-get install ros-$ROS_DISTRO-rosbridge-suite -y # install ros rosbridge suite
sudo apt-get install ros-$ROS_DISTRO-geometry2 -y # install ros geometry2
sudo apt-get install ros-$ROS_DISTRO-imu-tools -y # install ros imu tools
sudo apt-get install ros-$ROS_DISTRO-imu-pipeline -y # install ros imu pipeline
sudo apt-get install ros-$ROS_DISTRO-teb-local-planner -y # install ros teb local planner
sudo apt-get install ros-$ROS_DISTRO-map-server -y # install ros map server
sudo apt-get install ros-$ROS_DISTRO-ddynamic-reconfigure -y # install ros ddynamic reconfigure
sudo apt-get install ros-$ROS_DISTRO-realsense2-camera -y # install ros realsense2 camera
sudo apt-get install ros-$ROS_DISTRO-realsense2-description -y # install ros realsense2 description

# install dependencies
sudo apt-get install libmodbus-dev -y # install libmodbus
sudo apt-get install libpcap-dev -y # install pcap
sudo ldconfig
sudo usermod -a -G dialout $USER
echo "u need to reboot"
