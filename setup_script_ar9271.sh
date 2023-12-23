#!/bin/bash

# Define GitHub URLs
SETUP_ROUTER_PY_URL="https://raw.githubusercontent.com/Y-Kim-64/linux-router-forked/master/setup_router.py"
LNXROUTER_URL="https://raw.githubusercontent.com/Y-Kim-64/linux-router-forked/master/lnxrouter"

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt install -y iw hostapd haveged

# Download setup_router.py and lnxrouter from GitHub
wget "$SETUP_ROUTER_PY_URL" -O setup_router.py
wget "$LNXROUTER_URL" -O lnxrouter

# Move setup_router.py and lnxrouter to /usr/local/bin and make them executable
sudo mv setup_router.py /usr/local/bin/
sudo mv lnxrouter /usr/local/bin/
sudo chmod +x /usr/local/bin/setup_router.py
sudo chmod +x /usr/local/bin/lnxrouter

# Ask for user input
read -p "Enter WiFi Interface Name: " wifi_interface
read -p "Enter WiFi SSID: " wifi_ssid
read -p "Enter WiFi Password: " wifi_password
read -p "Enter Virtual Interface Name: " virt_interface_name
read -p "Enter WiFi Channel: " wifi_channel

# Create a systemd service file for setup_router.py with arguments
SERVICE_FILE=/etc/systemd/system/router_setup.service
echo "[Unit]
Description=Router Setup Service
After=network.target

[Service]
ExecStart=/usr/local/bin/setup_router.py --ap $wifi_interface $wifi_ssid -p $wifi_password --virt-name $virt_interface_name -g $wifi_channel
Restart=always
User=root

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable router_setup.service
sudo systemctl start router_setup.service

echo "Setup complete. The router_setup service is now active."
