#!/bin/bash
# Before minisatip: free the sat tuner (le_hscr holds it otherwise).
set -euo pipefail
echo "Stopping le_hscr (holds DVB-S tuner)..."
docker stop le_hscr_sigint 2>/dev/null || true
pkill -f 'sat_play.conf' 2>/dev/null || true
sleep 2
echo "Starting minisatip..."
exec /home/enigma2/sat_stuff/minisatip/start-minisatip.sh
