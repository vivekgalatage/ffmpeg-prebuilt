#!/usr/bin/env bash
# Publishes dist/* as GitHub release "chromium-<version>". Needs GH_TOKEN.
# Refuses to touch an existing release unless FORCE=true, in which case the
# release and its tag are deleted first so no stale assets remain.
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
  echo "\`*.so\` is the same library on its own (hash in \`*.so.sha256\`), for"
  echo "downloads without tar or xz."
  echo
  echo "Built from ffmpeg-prebuilt commit \`${GITHUB_SHA:-unknown}\`."
  if [ "${FORCE:-}" = true ]; then
    echo "Rebuilt on $(date -u +%Y-%m-%d) (force)."
  fi
} > "$notes"

if gh release view "$tag" >/dev/null 2>&1; then
  if [ "${FORCE:-}" != true ]; then
    echo "release $tag already exists; not overwriting (set force to rebuild)" >&2
    exit 1
  fi
  gh release delete "$tag" --cleanup-tag --yes
fi
gh release create "$tag" "$dist"/* --title "Chromium $CHROMIUM_VERSION" --notes-file "$notes"
