#!/usr/bin/bash

set -e

# Sets up for routing
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.conf >/dev/null
sudo sysctl -p

# Install packages
sudo apt update && sudo apt install wireguard -y

# Generate keys
PRIVKEY="$(wg genkey)"
PUBKEY="$(echo "$PRIVKEY" | wg pubkey)"

# Get Tunnel address from user
echo -n "Tunnel IP address: "
read TUNNEL_IP

# Generate file contents
FILEPATH=/etc/wireguard/wg0.conf
cat <<EOF | sudo tee $FILEPATH>/dev/null
# Public key: $PUBKEY

[Interface]
PrivateKey = $PRIVKEY
Address= $TUNNEL_IP
SaveConfig = true
ListenPort = 51820
EOF

# Sets correct permissions on server config file
sudo chmod 600 $FILEPATH

echo -e "Servers public key: \n$PUBKEY"

# Enables wg0 interface and optional start on reboot
sudo wg-quick up wg0
#sudo systemctl enable wg-quick@wg0