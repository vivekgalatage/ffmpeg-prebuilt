#!/usr/bin/env bash
# Adds libffmpeg-<version>-linux-<cpu>.so (+ .sha256) to an existing release
# that only has the archives (releases made before package.sh published the
# library on its own). The library is taken from the published archive and
# checked against the archive's own libffmpeg.so.sha256, so it is the same
# bytes. Assets already there are left alone. Needs GH_TOKEN and GH_REPO.
set -euo pipefail
: "${CHROMIUM_VERSION:?}"
tag="chromium-$CHROMIUM_VERSION"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
assets=$(gh release view "$tag" --json assets -q '.assets[].name')
for cpu in x64 arm64; do
  name="libffmpeg-$CHROMIUM_VERSION-linux-$cpu"
  if grep -qx "$name.so" <<<"$assets"; then
    echo "$tag: $name.so already published"
    continue
  fi
  gh release download "$tag" -p "$name.tar.xz" -p "$name.tar.xz.sha256" -D "$work"
  (cd "$work" && sha256sum -c "$name.tar.xz.sha256")
  tar -C "$work" -xJf "$work/$name.tar.xz"
  (cd "$work/$name" && sha256sum -c libffmpeg.so.sha256)
  cp "$work/$name/libffmpeg.so" "$work/$name.so"
  (cd "$work" && sha256sum "$name.so" > "$name.so.sha256")
  gh release upload "$tag" "$work/$name.so" "$work/$name.so.sha256"
  cat "$work/$name.so.sha256"
done
