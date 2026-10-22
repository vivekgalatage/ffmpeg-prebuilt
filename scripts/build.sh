#!/usr/bin/env bash
# Builds libffmpeg.so with H.264/AAC enabled (ffmpeg_branding = "Chrome").
source "$(dirname "$0")/common.sh"

cd "$SRC_DIR"

GN_ARGS=$(cat <<EOF
target_os = "linux"
target_cpu = "$TARGET_CPU"
is_official_build = true
is_debug = false
is_component_build = false
is_component_ffmpeg = true
ffmpeg_branding = "Chrome"
proprietary_codecs = true
chrome_pgo_phase = 0
is_cfi = false
symbol_level = 0
treat_warnings_as_errors = false
clang_use_chrome_plugins = false
use_custom_libcxx = false
use_llvm_libatomic = false
use_sysroot = true
use_remoteexec = false
EOF
)

log "gn gen $OUT_DIR"
mkdir -p "$OUT_DIR"
printf '%s\n' "$GN_ARGS" > "$OUT_DIR/args.gn"
"$GN" gen "$OUT_DIR"

log "ninja"
ninja -C "$OUT_DIR" third_party/ffmpeg:ffmpeg

ls -l "$OUT_DIR/libffmpeg.so"
