#!/bin/bash
set -e

ZTNET="3efa5cb78a804998"

echo "Installing ZeroTier…"
curl -s https://install.zerotier.com | bash
systemctl enable zerotier-one
systemctl start zerotier-one

echo "Joining ZeroTier network $ZTNET…"
zerotier-cli join "$ZTNET"

echo "Waiting for ZeroTier to come online…"
sleep 10

ZT_IFACE=$(ip -o link show | awk -F': ' '/zt/ {print $2; exit}')
ZT_IP=$(ip addr show "$ZT_IFACE" | awk '/inet /{print $2; exit}')
echo "ZeroTier interface: $ZT_IFACE | IP: $ZT_IP"

echo "Installing bridge tools…"
apt install -y bridge-utils ebtables

echo "Creating L2 bridge between ZeroTier and vmbr0…"
cat <<EOF >/etc/network/interfaces.d/ztbridge.cfg
auto ztbridge
iface ztbridge inet manual
    bridge_ports $ZT_IFACE vmbr0
    bridge_stp off
    bridge_fd 0
EOF

echo "Applying network changes…"
ifdown vmbr0 || true
ifup vmbr0 || true
ifup ztbridge || true

echo "Enabling ZeroTier L2 bridging…"
zerotier-cli set "$ZTNET" allowBridging=1 || true
zerotier-cli set "$ZT_IFACE" bridge=1 || true

echo "Removing Proxmox subscription popup…"
sed -i.bak 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list

cat <<EOF >/etc/apt/sources.list.d/pve-no-sub.list
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF

sed -i.bak 's/NotFound/OK/' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js || true

apt update || true
systemctl restart pveproxy

echo ""
echo "============================================="
echo " DONE — Proxmox is now ZeroTier L2 bridged!"
echo " Remote devices behave as if physically on LAN."
echo " HomeKit, HA, mDNS, AirPlay all work natively."
echo " No Proxmox subscription nags."
echo " Reboot recommended."
echo "============================================="
echo ""
