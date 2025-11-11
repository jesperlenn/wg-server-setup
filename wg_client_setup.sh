#!/usr/bin/bash
set -e

# SET THESE VARS
SERVER_PUBKEY="<server public key>"
ENDPOINT="<server address>"
SERVER_PORT="51820"

# Generate keys
echo "Generating keys..."
PRIVKEY="$(wg genkey)"
PUBKEY="$(echo "$PRIVKEY" | wg pubkey)"

# Get information from admin
echo -n "Username: "
read USERNAME
echo -n "Client tunnel IPv4 address: "
read TUNNEL_ADDRESS
echo -n "Allowed IPs, separate subnets with coma (Blank for 0.0.0.0/0): "
read ALLOWED_IPS
if [ -z "$ALLOWED_IPS" ]; then
    ALLOWED_IPS="0.0.0.0/0"
fi

# Create peers folder where userpeer configs are stored
sudo mkdir -p /etc/wireguard/peers/
FILEPATH="/etc/wireguard/peers/$USERNAME.conf"

# Generates Wireguard peer config
cat <<EOF | sudo tee $FILEPATH>/dev/null
# User: $USERNAME
# Client public key: $PUBKEY

[Interface]
PrivateKey = $PRIVKEY
Address = $TUNNEL_ADDRESS/32
SaveConfig = true

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = $ENDPOINT:$SERVER_PORT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 30
EOF

# Sets right permissions
sudo chmod 600 $FILEPATH

# Adds peer to server wg0 interface
echo "Adding peer to server interface..."
sudo wg set wg0 peer $PUBKEY allowed-ips $TUNNEL_ADDRESS/32