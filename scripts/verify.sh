#!/usr/bin/env bash
# Checks the built library: right architecture, and the H.264 and AAC
# decoders are really in it (the point of this build).
source "$(dirname "$0")/common.sh"

so="$OUT_DIR/libffmpeg.so"
test -f "$so"

case "$TARGET_CPU" in
  x64) want_machine="X86-64" ;;
  arm64) want_machine="AArch64" ;;
esac
machine=$(readelf -h "$so" | awk -F: '/Machine:/ { gsub(/^ +/, "", $2); print $2 }')
echo "machine: $machine"
case "$machine" in
  *"$want_machine"*) ;;
  *) echo "unexpected machine '$machine' for $TARGET_CPU" >&2; exit 1 ;;
esac

symbols=$(nm -D --defined-only "$so")
for sym in avcodec_find_decoder ff_h264_decoder ff_aac_decoder; do
  if grep -qE "[[:space:]]${sym}\$" <<<"$symbols"; then
    echo "ok: $sym"
  else
    echo "missing: $sym" >&2
    exit 1
  fi
done
