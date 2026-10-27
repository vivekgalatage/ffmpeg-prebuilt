# Shared settings for the build scripts. Source this file; do not run it.
#
# Inputs (environment):
#   CHROMIUM_VERSION  Chromium release tag to build from, e.g. 158.0.8108.0
#                     (default: the contents of the CHROMIUM_VERSION file)
#   TARGET_CPU        x64 or arm64
#   WORK_DIR          Scratch directory (default: ./work)

set -euo pipefail

: "${TARGET_CPU:?set TARGET_CPU to x64 or arm64}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROMIUM_VERSION="${CHROMIUM_VERSION:-$(tr -d '[:space:]' < "$REPO_DIR/CHROMIUM_VERSION")}"
: "${CHROMIUM_VERSION:?set CHROMIUM_VERSION or fill in the CHROMIUM_VERSION file}"

case "$TARGET_CPU" in
  x64) SYSROOT_ARCH=amd64 ;;
  arm64) SYSROOT_ARCH=arm64 ;;
  *) echo "unsupported TARGET_CPU: $TARGET_CPU" >&2; exit 1 ;;
esac

WORK_DIR="${WORK_DIR:-$REPO_DIR/work}"
SRC_DIR="$WORK_DIR/src"
TOOLS_DIR="$WORK_DIR/tools"
OUT_DIR="$SRC_DIR/out/linux-$TARGET_CPU"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
GN="$TOOLS_DIR/gn/gn"
CHROMIUM_GIT="https://chromium.googlesource.com"
# Where chromium/src is cloned from, in order: Chromium's GitHub mirror (the
# same commits and tags; fast from GitHub's runners, with none of
# googlesource's per-address throttling), then googlesource for a tag the
# mirror does not have yet.
CHROMIUM_SRC_GITS=(
  https://github.com/chromium/chromium.git
  "$CHROMIUM_GIT/chromium/src.git"
)

# A stalled transfer fails instead of hanging the job: git gives up below
# 1 KB/s for 60 s, curl after 5 minutes; retry() then tries again.
export GIT_HTTP_LOW_SPEED_LIMIT="${GIT_HTTP_LOW_SPEED_LIMIT:-1000}"
export GIT_HTTP_LOW_SPEED_TIME="${GIT_HTTP_LOW_SPEED_TIME:-60}"
CURL_FLAGS=(-fsSL --retry 3 --connect-timeout 30 --max-time 300)

# retry CMD...: runs CMD up to 3 times, 15 s apart.
retry() {
  local attempt
  for attempt in 1 2 3; do
    "$@" && return 0
    echo "attempt $attempt failed: $*" >&2
    [ "$attempt" -lt 3 ] && sleep 15
  done
  return 1
}

# Git dependencies (gitlinks in chromium/src) needed by //third_party/ffmpeg.
# Opus is part of chromium/src itself and comes with the sparse checkout.
FFMPEG_GIT_DEPS=(
  third_party/ffmpeg
  third_party/nasm
)

log() { printf '\n=== %s\n' "$*"; }
