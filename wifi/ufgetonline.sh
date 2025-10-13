#!/bin/bash
# ufgetonline.sh — minimal prep for UF JoinNow on Omarchy/Arch
set -euo pipefail

log(){ printf '[*] %s\n' "$*"; }
has(){ command -v "$1" >/dev/null 2>&1; }

# 0) Packages: NM+iwd backend and basic tools the JoinNow stub needs
log "Installing minimal packages"
sudo pacman -Sy --noconfirm --needed \
  networkmanager iwd ca-certificates \
  python gzip tar sed coreutils

# 1) Make NetworkManager own Wi-Fi with iwd backend
log "Disabling conflicting network services"
sudo systemctl disable --now systemd-networkd wpa_supplicant netctl 2>/dev/null || true

log "Configuring NetworkManager to use iwd backend"
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf >/dev/null
sudo systemctl enable --now NetworkManager

# 2) Ensure radio is unblocked and interface is managed
log "Unblocking Wi-Fi and enabling radio"
sudo rfkill unblock wifi || true
nmcli radio wifi on || true

IFACE="$(iw dev | awk '/Interface/{print $2}' | head -n1 || true)"
if [ -n "${IFACE:-}" ]; then
  log "Marking $IFACE as managed by NetworkManager"
  nmcli dev set "$IFACE" managed yes || true
fi

# 3) Verify NM is in control
log "Current device status:"
nmcli device status || true

# 4) Run UF JoinNow helper if present (no sudo; it will prompt for creds itself)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "$SCRIPT_DIR/JoinNow.sh" ]; then
  log "Launching UF JoinNow helper"
  exec "$SCRIPT_DIR/JoinNow.sh"
else
  log "JoinNow.sh not found here: $SCRIPT_DIR"
  log "Place UF's script alongside ufgetonline.sh and re-run."
fi
