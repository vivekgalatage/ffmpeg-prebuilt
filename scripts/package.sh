#!/usr/bin/env bash
# Packages libffmpeg.so with build information and licence texts.
source "$(dirname "$0")/common.sh"

name="libffmpeg-$CHROMIUM_VERSION-linux-$TARGET_CPU"
stage="$WORK_DIR/stage/$name"
rm -rf "$stage"
mkdir -p "$stage/licenses" "$DIST_DIR"

cp "$OUT_DIR/libffmpeg.so" "$stage/"

{
  echo "chromium_version: $CHROMIUM_VERSION"
  echo "chromium_src_commit: $(git -C "$SRC_DIR" rev-parse HEAD)"
  echo "target: linux-$TARGET_CPU"
  echo "dependencies:"
  while read -r path url sha; do
    echo "  $path: $url @ $sha"
  done < "$WORK_DIR/deps.txt"
  echo "gn_args: |"
  sed 's/^/  /' "$OUT_DIR/args.gn"
  echo "built_by: ${GITHUB_SERVER_URL:-local}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-}"
} > "$stage/BUILDINFO.txt"

ff="$SRC_DIR/third_party/ffmpeg"
for f in LICENSE.md COPYING.LGPLv2.1 CREDITS; do
  [ -f "$ff/$f" ] && cp "$ff/$f" "$stage/licenses/ffmpeg-$f"
done
[ -f "$SRC_DIR/third_party/opus/src/COPYING" ] &&
  cp "$SRC_DIR/third_party/opus/src/COPYING" "$stage/licenses/opus-COPYING"
cp "$REPO_DIR/NOTICE.md" "$stage/"

(cd "$stage" && sha256sum libffmpeg.so > libffmpeg.so.sha256)
tar -C "$(dirname "$stage")" -cJf "$DIST_DIR/$name.tar.xz" "$name"
(cd "$DIST_DIR" && sha256sum "$name.tar.xz" > "$name.tar.xz.sha256")
cp "$stage/BUILDINFO.txt" "$DIST_DIR/$name.BUILDINFO.txt"
# The library alone, for clients that download without tar/xz: the same
# bytes as the libffmpeg.so in the archive.
cp "$stage/libffmpeg.so" "$DIST_DIR/$name.so"
(cd "$DIST_DIR" && sha256sum "$name.so" > "$name.so.sha256")

ls -l "$DIST_DIR"
cat "$stage/libffmpeg.so.sha256"
