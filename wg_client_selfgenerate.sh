#!/usr/bin/bash
set -e

# Generate keys
echo "Generating keys..."
PRIVKEY="$(wg genkey)"
PUBKEY="$(echo "$PRIVKEY" | wg pubkey)"

# Get information from admin
echo -n "Sesrver public key: "
read SERVER_PUBKEY
echo -n "Sesrver address: "
read ENDPOINT
echo -n "Sesrver port (Blank for 51820): "
read ENDPOINT_PORT
if [ -z "$ENDPOINT_PORT" ]; then
    ENDPOINT_PORT="51820"
fi
echo -n "Client tunnel IPv4 address: "
read TUNNEL_ADDRESS
echo -n "Allowed IPs, separate subnets with coma (Blank for 0.0.0.0/0): "
read ALLOWED_IPS
if [ -z "$ALLOWED_IPS" ]; then
    ALLOWED_IPS="0.0.0.0/0"
fi
echo -n "Wireguard interface name (Blank for wg0): "
read INTERFACE_NAME
if [ -z "$INTERFACE_NAME" ]; then
    INTERFACE_NAME="wg0"
fi

# Create peers folder where userpeer configs are stored
FILEPATH="/etc/wireguard/$INTERFACE_NAME.conf"

# Generates Wireguard peer config
cat <<EOF | sudo tee $FILEPATH>/dev/null
# Client public key: $PUBKEY

[Interface]
PrivateKey = $PRIVKEY
Address = $TUNNEL_ADDRESS/32
SaveConfig = true

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = $ENDPOINT:$ENDPOINT_PORT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 30
EOF

# Sets right permissions
sudo chmod 600 $FILEPATH

echo -e "\nConfig has been saved to $FILEPATH\n"
echo -e "Send folling to VPN admin:\nPublic key: $PUBKEY\nTunnel address: $TUNNEL_ADDRESS/32"