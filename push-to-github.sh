#!/bin/bash
# Push skystar-satip-docs na GitHub (logicencoder)
# Token: ~/.gitpush_secret.txt (nastav cez: python3 ~/lojzo/githelper/gitcc.py)
set -euo pipefail

REPO="skystar-satip-docs"
USER="logicencoder"
DIR="$(cd "$(dirname "$0")" && pwd)"
SECRET="$HOME/.gitpush_secret.txt"

if [[ ! -f "$SECRET" ]]; then
  echo "Chýba GitHub token v $SECRET"
  echo "Spusti: python3 ~/lojzo/githelper/gitcc.py"
  echo "  → 1 Setup → Update token"
  echo "  → 5 GitHub → Connect to repo → Create new repo → $REPO"
  exit 1
fi

TOKEN=$(tr -d '\n' < "$SECRET")
cd "$DIR"

git remote remove origin 2>/dev/null || true
git remote add origin "https://${TOKEN}@github.com/${USER}/${REPO}.git"

# vytvor repo ak neexistuje
curl -sS -X POST -H "Authorization: token ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${REPO}\",\"private\":true,\"description\":\"SkyStar USB Sat>IP + minisatip + DVBViewer docs\"}" \
  "https://api.github.com/user/repos" | grep -qE 'html_url|"message".*already exists' || true

git push -u origin main
echo ""
echo "Hotovo: https://github.com/${USER}/${REPO}"
