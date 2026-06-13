#!/bin/bash
# Push technisat-skystar-usb-2-hd-ci-satip to GitHub (logicencoder)
# Token is on SOL server: sol@192.168.1.103 ~/.gitpush_secret.txt
set -euo pipefail

REPO="technisat-skystar-usb-2-hd-ci-satip"
USER="logicencoder"
DIR="$(cd "$(dirname "$0")" && pwd)"
SOL_KEY="/home/enigma2/lojzo/ssh-key-2024-05-16.key"
SOL_HOST="sol@192.168.1.103"

fetch_token() {
  if [[ -f "$HOME/.gitpush_secret.txt" ]]; then
    tr -d '\n' < "$HOME/.gitpush_secret.txt"
    return 0
  fi
  ssh -i "$SOL_KEY" -o BatchMode=yes -o ConnectTimeout=15 "$SOL_HOST" \
    'cat /home/sol/.gitpush_secret.txt' 2>/dev/null | tr -d '\n'
}

TOKEN=$(fetch_token || true)
if [[ -z "$TOKEN" ]]; then
  echo "GitHub token not found locally or on SOL ($SOL_HOST)."
  echo "On SOL: python3 ~/lojzo/githelper/gitcc.py → Update token"
  exit 1
fi

cd "$DIR"
git remote remove origin 2>/dev/null || true
git remote add origin "https://${TOKEN}@github.com/${USER}/${REPO}.git"

DESC="TechniSat SkyStar USB 2 HD CI (14f7:0001): Ubuntu 24.04 / kernel 6.8 — patched stb0899 (DVB-S2 + signal/SNR) + minisatip Sat>IP FTA — DVBViewer & TransEdit tested"

curl -sS -X POST -H "Authorization: token ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${REPO}\",\"private\":false,\"description\":\"${DESC}\"}" \
  "https://api.github.com/user/repos" >/dev/null || true

curl -sS -X PATCH -H "Authorization: token ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"description\":\"${DESC}\"}" \
  "https://api.github.com/repos/${USER}/${REPO}" >/dev/null || true

git push -u origin main
echo ""
echo "Done: https://github.com/${USER}/${REPO}"
