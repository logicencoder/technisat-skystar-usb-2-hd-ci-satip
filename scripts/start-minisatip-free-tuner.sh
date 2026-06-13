#!/bin/bash
# Pred spustením minisatip uvoľni sat tuner (le_hscr ho inak drží).
set -euo pipefail
echo "Stopping le_hscr (drží DVB-S tuner)..."
docker stop le_hscr_sigint 2>/dev/null || true
pkill -f 'sat_play.conf' 2>/dev/null || true
sleep 2
echo "Starting minisatip..."
exec /home/enigma2/sat_stuff/minisatip/start-minisatip.sh
