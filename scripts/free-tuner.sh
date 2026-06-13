#!/bin/bash
# Free DVB tuner held by docker/other process (does not start minisatip).
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
free_tuner
echo "Tuner freed."
