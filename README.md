# Proxmox ZeroTier L2 Bridge Installer

Fully automated script that:

- Installs ZeroTier  
- Joins network **3efa5cb78a804998**  
- Enables ZeroTier's hidden L2 bridging mode  
- Bridges `zt0` with Proxmox `vmbr0`  
- Allows full LAN passthrough (HomeKit, mDNS, AirPlay, SSDP, HA Discovery, etc.)  
- Removes Proxmox subscription nag  
- Adds the no-subscription repo  
- Restarts Proxmox services

This makes all ZeroTier-connected devices appear **natively on your home LAN**.

---

## 🔥 One-line installer

Run this on your Proxmox node:

```bash
bash <(curl -s https://raw.githubusercontent.com/agph2006/proxmox-zerotier-l2/main/install.sh)
```

---

## Notes

- After running, approve the Proxmox node in your ZeroTier web console  
- Reboot recommended  
- LAN services will now work remotely exactly as if you're on home WiFi
