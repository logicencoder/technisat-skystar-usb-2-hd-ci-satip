#!/bin/bash
# Push skystar-satip-docs to GitHub (logicencoder)
# Token: ~/.gitpush_secret.txt (set via: python3 ~/lojzo/githelper/gitcc.py)
set -euo pipefail

REPO="skystar-satip-docs"
USER="logicencoder"
DIR="$(cd "$(dirname "$0")" && pwd)"

find_token() {
  for f in "$HOME/.gitpush_secret.txt" "$HOME/lojzo/.gitpush_secret.txt" "$HOME/lojzo/githelper/.gitpush_secret.txt"; do
    if [[ -f "$f" ]]; then
      tr -d '\n' < "$f"
      return 0
    fi
  done
  return 1
}

TOKEN=$(find_token || true)
if [[ -z "$TOKEN" ]]; then
  echo "GitHub token not found."
  echo "Set it via: python3 ~/lojzo/githelper/gitcc.py"
  echo "  → 1 Setup → Update token"
  echo "  → saves to ~/.gitpush_secret.txt"
  exit 1
fi

cd "$DIR"
git remote remove origin 2>/dev/null || true
git remote add origin "https://${TOKEN}@github.com/${USER}/${REPO}.git"

curl -sS -X POST -H "Authorization: token ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${REPO}\",\"private\":true,\"description\":\"SkyStar USB Sat>IP + minisatip + DVBViewer docs\"}" \
  "https://api.github.com/user/repos" >/dev/null || true

git push -u origin main
echo ""
echo "Done: https://github.com/${USER}/${REPO}"
