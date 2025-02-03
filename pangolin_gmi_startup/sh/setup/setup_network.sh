#!/bin/bash

# Function to print usage
print_usage() {
    echo "Usage: $0 -i <IP_ADDRESSES> -g <GATEWAY> -d <DNS> -t <INTERFACE> -s <SSID> -p <PASSPHRASE>"
    echo "Example (Ethernet): $0 -i '192.168.2.1/24 10.0.0.1/24' -g 192.168.2.254 -d 8.8.8.8 -t eth1"
    echo "Example (Wi-Fi): $0 -i '192.168.2.1/24 10.0.0.1/24' -g 192.168.2.254 -d 8.8.8.8 -t wlp4s0 -s 'My SSID' -p 'My Passphrase'"
}

# Parse arguments
while getopts ":i:g:d:t:s:p:" opt; do
    case ${opt} in
        i )
            IP_ADDRESSES=$OPTARG
            ;;
        g )
            GATEWAY=$OPTARG
            ;;
        d )
            DNS=$OPTARG
            ;;
        t )
            INTERFACE=$OPTARG
            ;;
        s )
            SSID=$OPTARG
            ;;
        p )
            PASSPHRASE=$OPTARG
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            print_usage
            exit 1
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            print_usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Check if all required arguments are provided
if [ -z "${IP_ADDRESSES}" ] || [ -z "${GATEWAY}" ] || [ -z "${DNS}" ] || [ -z "${INTERFACE}" ]; then
    echo "Error: Missing required arguments"
    print_usage
    exit 1
fi

if [[ $INTERFACE == wl* && ( -z "${SSID}" || -z "${PASSPHRASE}" ) ]]; then
    echo "Error: Missing SSID or Passphrase for Wi-Fi interface"
    print_usage
    exit 1
fi

# Convert space-separated IP addresses into Netplan compatible list
IP_ADDRESSES_LIST=$(echo $IP_ADDRESSES | sed 's/ /, /g')

# Determine if the interface is Ethernet or Wi-Fi for Netplan configuration
if [[ $INTERFACE == wl* ]]; then
    INTERFACE_TYPE="wifis"
    WIFI_CONFIG="access-points:
        \"${SSID}\":
            password: \"${PASSPHRASE}\""
else
    INTERFACE_TYPE="ethernets"
    WIFI_CONFIG=""
fi

# Update network configuration using Netplan with NetworkManager
NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"
TEMP_NETPLAN_CONFIG="/tmp/01-netcfg.yaml"
sudo bash -c "cat > ${TEMP_NETPLAN_CONFIG}" <<EOL
network:
  version: 2
  renderer: NetworkManager
  ${INTERFACE_TYPE}:
    ${INTERFACE}:
      dhcp4: no
      addresses: [${IP_ADDRESSES_LIST}]
      gateway4: ${GATEWAY}
      nameservers:
        addresses: [${DNS}]
      ${WIFI_CONFIG}
EOL

# Move the temporary Netplan configuration to the final location
sudo mv ${TEMP_NETPLAN_CONFIG} ${NETPLAN_CONFIG}

# Apply the Netplan configuration
sudo netplan apply

# # Update Nginx configuration to listen on all provided IP addresses
# NGINX_CONFIG="/etc/nginx/sites-available/node-red-rosbridge"
# TEMP_NGINX_CONFIG="/tmp/node-red-rosbridge"
# NGINX_LISTEN_DIRECTIVES=$(for ip in $IP_ADDRESSES; do echo "listen ${ip%%/*}:80;"; done)
# sudo bash -c "cat > ${TEMP_NGINX_CONFIG}" <<EOL
# server {
#     ${NGINX_LISTEN_DIRECTIVES}

#     server_name _;

#     location / {
#         proxy_pass http://localhost:1880/;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade \$http_upgrade;
#         proxy_set_header Connection 'upgrade';
#         proxy_set_header Host \$host;
#         proxy_cache_bypass \$http_upgrade;
#     }

#     location /rosbridge/ {
#         proxy_pass http://localhost:9090/;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade \$http_upgrade;
#         proxy_set_header Connection 'upgrade';
#         proxy_set_header Host \$host;
#         proxy_cache_bypass \$http_upgrade;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#         proxy_set_header X-Forwarded-Host \$http_host;
#         proxy_set_header X-Forwarded-Port \$server_port;
#     }
# }
# EOL

# # Move the temporary Nginx configuration to the final location
# sudo mv ${TEMP_NGINX_CONFIG} ${NGINX_CONFIG}

# # Enable the Nginx site and restart Nginx
# sudo ln -sf /etc/nginx/sites-available/node-red-rosbridge /etc/nginx/sites-enabled/node-red-rosbridge
# sudo nginx -t
# sudo systemctl restart nginx

echo "Network configuration and Nginx setup complete."
