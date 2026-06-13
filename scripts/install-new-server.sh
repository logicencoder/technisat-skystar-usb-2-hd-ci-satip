#!/bin/bash
# Full first-time setup on a NEW Ubuntu server (SkyStar 14f7:0001 + minisatip)
# Run: sudo bash scripts/install-new-server.sh
#
# After completion: REBOOT, then: scripts/start-minisatip.sh
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
require_root

echo "=== Install: TechniSat SkyStar USB 2 HD CI (14f7:0001) ==="
echo "Repo: $REPO_ROOT"

# --- packages ---
echo "→ Installing packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends \
  build-essential \
  "linux-headers-$(uname -r)" \
  git cmake \
  libdvbcsa-dev \
  kmod \
  curl \
  firmware-linux-nonfree 2>/dev/null || apt-get install -y firmware-misc-nonfree 2>/dev/null || true

# firmware check
if [[ ! -f /lib/firmware/dvb-usb-az6027-03.fw ]]; then
  echo "WARNING: /lib/firmware/dvb-usb-az6027-03.fw missing."
  echo "  Try: apt install firmware-linux-nonfree"
  echo "  Or copy firmware manually before using the tuner."
fi

# --- config ---
if [[ ! -f "$REPO_ROOT/config.env" ]]; then
  cp "$REPO_ROOT/config.env.example" "$REPO_ROOT/config.env"
  echo "Created $REPO_ROOT/config.env from example"
fi

# --- TBS media_build off ---
disable_tbs_media_build

# --- enigma settings (breaks SkyStar demux) ---
move_enigma_settings_aside

# --- build patched stb0899 ---
echo "→ Building patched stb0899..."
make -C "$STB0899_DIR" clean
make -C "$STB0899_DIR" -j"$(nproc)"
make -C "$STB0899_DIR" install

# --- system config ---
echo "→ Installing udev / modprobe / modules-load..."
install -m 0644 "$REPO_ROOT/scripts/70-skystar-usb.rules" /etc/udev/rules.d/70-skystar-usb.rules
install -m 0644 "$REPO_ROOT/scripts/skystar-no-tbs.conf" /etc/modprobe.d/skystar-no-tbs.conf
install -m 0644 "$REPO_ROOT/scripts/skystar-modules-load.conf" /etc/modules-load.d/skystar.conf
udevadm control --reload-rules
udevadm trigger
depmod -a

# --- build minisatip (as original user if sudo) ---
echo "→ Building minisatip..."
if [[ -n "${SUDO_USER:-}" ]]; then
  sudo -u "$SUDO_USER" bash "$REPO_ROOT/scripts/build-minisatip.sh"
else
  bash "$REPO_ROOT/scripts/build-minisatip.sh"
fi

# --- optional systemd ---
if [[ -f "$REPO_ROOT/systemd/minisatip-skystar.service" ]]; then
  sed "s|@REPO_ROOT@|$REPO_ROOT|g" "$REPO_ROOT/systemd/minisatip-skystar.service" \
    > /etc/systemd/system/minisatip-skystar.service
  systemctl daemon-reload
  systemctl enable minisatip-skystar.service
  echo "→ systemd service enabled: minisatip-skystar"
fi

mkdir -p "$BACKUP_DIR"

echo ""
echo "=== INSTALL COMPLETE ==="
echo ""
echo "1. Plug in SkyStar USB (14f7:0001) if not already connected"
echo "2. REBOOT:  sudo reboot"
echo "3. After reboot verify:"
echo "     lsusb | grep 14f7"
echo "     ls /dev/dvb/adapter0/"
echo "     modinfo stb0899 | grep filename"
echo "4. Start Sat>IP:"
echo "     $REPO_ROOT/scripts/start-minisatip.sh"
echo "     # or: sudo systemctl start minisatip-skystar"
echo ""
echo "DVBViewer RTSP (replace IP):"
echo "  rtsp://YOUR_IP:${SATIP_RTSP_PORT}/?src=1&freq=12344&pol=h&sr=29900&msys=dvbs2&mtype=8psk&fec=34&pids=1310,1320"
echo "Web status: http://YOUR_IP:${SATIP_HTTP_PORT}/"
