#!/bin/bash
# Before minisatip: free the sat tuner (docker/le_hscr holds it otherwise).
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

free_tuner
sleep 1
echo "Starting minisatip..."
exec bash "$REPO_ROOT/scripts/start-minisatip.sh"
