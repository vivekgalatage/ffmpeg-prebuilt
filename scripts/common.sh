# Shared settings for the build scripts. Source this file; do not run it.
#
# Inputs (environment):
#   CHROMIUM_VERSION  Chromium release tag to build from, e.g. 158.0.8108.0
#   TARGET_CPU        x64 or arm64
#   WORK_DIR          Scratch directory (default: ./work)

set -euo pipefail

: "${CHROMIUM_VERSION:?set CHROMIUM_VERSION, e.g. 158.0.8108.0}"
: "${TARGET_CPU:?set TARGET_CPU to x64 or arm64}"

case "$TARGET_CPU" in
  x64) SYSROOT_ARCH=amd64 ;;
  arm64) SYSROOT_ARCH=arm64 ;;
  *) echo "unsupported TARGET_CPU: $TARGET_CPU" >&2; exit 1 ;;
esac

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$REPO_DIR/work}"
SRC_DIR="$WORK_DIR/src"
TOOLS_DIR="$WORK_DIR/tools"
OUT_DIR="$SRC_DIR/out/linux-$TARGET_CPU"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
GN="$TOOLS_DIR/gn/gn"
CHROMIUM_GIT="https://chromium.googlesource.com"

# Git dependencies (gitlinks in chromium/src) needed by //third_party/ffmpeg.
# Opus is part of chromium/src itself and comes with the sparse checkout.
FFMPEG_GIT_DEPS=(
  third_party/ffmpeg
  third_party/nasm
)

log() { printf '\n=== %s\n' "$*"; }
