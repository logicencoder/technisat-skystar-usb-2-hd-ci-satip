#!/bin/bash
# Build minisatip from upstream (catalinii/minisatip) into $SATIP_DIR
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

SRC="$SATIP_DIR/source"
BUILD="$SATIP_DIR/build"

echo "→ Building minisatip in $SATIP_DIR"

if ! command -v cmake >/dev/null; then
  echo "Install cmake: sudo apt install -y cmake build-essential git libdvbcsa-dev" >&2
  exit 1
fi

mkdir -p "$SATIP_DIR"
if [[ ! -d "$SRC/.git" ]]; then
  git clone --depth 1 https://github.com/catalinii/minisatip.git "$SRC"
fi

mkdir -p "$BUILD"
cmake -S "$SRC" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD" -j"$(nproc)"

if [[ -x "$BUILD/minisatip" ]]; then
  echo "OK: $BUILD/minisatip"
else
  echo "Build failed — binary not found" >&2
  exit 1
fi

# html for web status page
if [[ -d "$SRC/html" && ! -d "$SATIP_DIR/html" ]]; then
  ln -sf "$SRC/html" "$SATIP_DIR/html" 2>/dev/null || cp -a "$SRC/html" "$SATIP_DIR/html"
fi
mkdir -p "$SATIP_DIR/cache"
echo "Done. Start with: scripts/start-minisatip.sh"
