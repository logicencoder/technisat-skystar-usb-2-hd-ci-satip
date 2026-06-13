#!/bin/bash
# Shared paths and helpers for all SkyStar scripts.
# Source this file: source "$(dirname "$0")/lib/common.sh"

set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
REPO_ROOT="$(cd "$_script_dir/.." && pwd)"

CONFIG_FILE="${CONFIG_FILE:-$REPO_ROOT/config.env}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

SATIP_DIR="${SATIP_DIR:-$REPO_ROOT/minisatip}"
BACKUP_DIR="${BACKUP_DIR:-$REPO_ROOT/backup}"
STB0899_DIR="${STB0899_DIR:-$REPO_ROOT/stb0899-module}"
MINISATIP_ADAPTER="${MINISATIP_ADAPTER:-0}"
SATIP_RTSP_PORT="${SATIP_RTSP_PORT:-8554}"
SATIP_HTTP_PORT="${SATIP_HTTP_PORT:-8080}"
SATIP_LNB="${SATIP_LNB:-*:9750-10600-11700}"
TUNER_HOLD_DOCKER="${TUNER_HOLD_DOCKER:-}"

satip_bind_ip() {
  if [[ -n "${SATIP_BIND_IP:-}" ]]; then
    echo "$SATIP_BIND_IP"
    return
  fi
  ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}'
}

minisatip_bin() {
  local b
  for b in \
    "$SATIP_DIR/build/minisatip" \
    "$SATIP_DIR/source/build/minisatip" \
    "$SATIP_DIR/bin/minisatip" \
    "$REPO_ROOT/minisatip/build/minisatip"; do
    if [[ -x "$b" ]]; then
      echo "$b"
      return 0
    fi
  done
  return 1
}

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run as root: sudo $*" >&2
    exit 1
  fi
}

disable_tbs_media_build() {
  local kver media backup
  kver="$(uname -r)"
  media="/lib/modules/${kver}/updates/extra/media"
  backup="${BACKUP_DIR}/media.disabled.skystar"
  for dir in "$media" "${media}.disabled.skystar"; do
    if [[ -d "$dir" && ! -L "$dir" ]]; then
      mkdir -p "$(dirname "$backup")"
      rm -rf "$backup"
      mv "$dir" "$backup"
      depmod -a
      echo "Moved TBS media_build to $backup"
      return 0
    fi
  done
}

move_enigma_settings_aside() {
  if [[ -f /etc/enigma2/settings && ! -f /etc/enigma2/settings.tbs-only.bak ]]; then
    mv /etc/enigma2/settings /etc/enigma2/settings.tbs-only.bak
    echo "Moved /etc/enigma2/settings → settings.tbs-only.bak"
  fi
}

free_tuner() {
  if [[ -n "$TUNER_HOLD_DOCKER" ]]; then
    docker stop "$TUNER_HOLD_DOCKER" 2>/dev/null || true
  fi
  pkill -f 'sat_play.conf' 2>/dev/null || true
}

stop_minisatip() {
  if [[ -n "${USM_PATH:-}" && -f "$USM_PATH" ]]; then
    python3 "$USM_PATH" stop minisatip 2>/dev/null || true
  fi
  pkill -x minisatip 2>/dev/null || true
}
