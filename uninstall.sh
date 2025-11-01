#!/bin/bash
# Complete uninstall of WGDashboard and WireGuard configs

SERVICE_NAME="wg-dashboard"
INSTALL_DIR="/root/WGDashboard"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
WG_DIR="/etc/wireguard"
BACKUP_DIR="/root/wg_backup_$(date +%Y%m%d_%H%M%S)"

echo "🛑 Stopping WGDashboard service (if running)..."
systemctl stop "$SERVICE_NAME" 2>/dev/null
systemctl disable "$SERVICE_NAME" 2>/dev/null

echo "🧾 Removing systemd service file..."
if [ -f "$SERVICE_FILE" ]; then
  rm -f "$SERVICE_FILE"
  echo "✅ Service file removed."
else
  echo "⚠️ No service file found."
fi

echo "🗑 Removing WGDashboard installation directory..."
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "✅ Directory $INSTALL_DIR deleted."
else
  echo "⚠️ Directory $INSTALL_DIR not found."
fi

echo "📦 Backing up existing WireGuard configuration to $BACKUP_DIR ..."
if [ -d "$WG_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
  cp -r "$WG_DIR"/* "$BACKUP_DIR"/ 2>/dev/null
  echo "✅ Backup completed."
else
  echo "⚠️ /etc/wireguard not found, skipping backup."
fi

echo "🔌 Stopping and removing all WireGuard interfaces..."
for iface in $(wg show interfaces 2>/dev/null); do
  echo " - Bringing down interface: $iface"
  wg-quick down "$iface" 2>/dev/null
  ip link delete "$iface" 2>/dev/null
done

echo "🧹 Removing WireGuard configuration files..."
if [ -d "$WG_DIR" ]; then
  rm -rf "$WG_DIR"
  echo "✅ All WireGuard configs removed."
fi

echo "🧹 Cleaning leftover WGDashboard data..."
find /root -maxdepth 2 -type f -name "wgdashboard.db" -delete 2>/dev/null
find /var/log -type f -name "wgdashboard*.log" -delete 2>/dev/null

echo "🔁 Reloading systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "✅ All done!"
echo "💡 A backup of your old WireGuard configs is saved at: $BACKUP_DIR"
echo "💣 WGDashboard and all WireGuard interfaces have been removed."
