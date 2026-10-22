#!/usr/bin/env bash
# Publishes dist/* as GitHub release "chromium-<version>". Needs GH_TOKEN.
set -euo pipefail
: "${CHROMIUM_VERSION:?}"

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
dist="${DIST_DIR:-$repo_dir/dist}"
tag="chromium-$CHROMIUM_VERSION"

notes=$(mktemp)
{
  echo "libffmpeg.so for Chromium $CHROMIUM_VERSION on Linux (x64, arm64),"
  echo "built with H.264 and AAC decoders enabled (\`ffmpeg_branding = \"Chrome\"\`)."
  echo
  echo "**Read [NOTICE.md](../../blob/main/NOTICE.md) before using these files.**"
  echo
  echo "Exact sources and build arguments are in each \`*.BUILDINFO.txt\`."
  echo "Each archive also contains \`libffmpeg.so.sha256\` (hash of the library itself)."
} > "$notes"

if gh release view "$tag" >/dev/null 2>&1; then
  gh release upload "$tag" "$dist"/* --clobber
else
  gh release create "$tag" "$dist"/* --title "Chromium $CHROMIUM_VERSION" --notes-file "$notes"
fi
