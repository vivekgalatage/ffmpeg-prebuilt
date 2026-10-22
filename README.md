# ffmpeg-prebuilt

Prebuilt `libffmpeg.so` for Chromium-based applications on Linux, built from
Chromium's own FFmpeg with **H.264 and AAC decoders enabled**.

Chromium-based apps that ship without proprietary codecs can load one of
these libraries instead of their bundled, open-codecs-only `libffmpeg.so`, if
the user chooses to.

> **Read [NOTICE.md](NOTICE.md) first.** H.264 and AAC may be patent-encumbered
> where you live. Nothing here is a licence to use them.

## What is published

Each GitHub release is named `chromium-<version>` and contains, for `x64` and
`arm64`:

| File | Contents |
|---|---|
| `libffmpeg-<version>-linux-<cpu>.tar.xz` | `libffmpeg.so`, `libffmpeg.so.sha256`, `BUILDINFO.txt`, `NOTICE.md`, `licenses/` |
| `*.tar.xz.sha256` | Hash of the archive |
| `*.BUILDINFO.txt` | Exact Chromium commit, FFmpeg/NASM revisions and GN arguments |

## Compatibility

A replacement `libffmpeg.so` must come from **the same Chromium version** as
the application loading it (in practice, the same `third_party/ffmpeg`
revision). Loading a library built for a different version can crash.

## How it is built

`.github/workflows/build.yml` runs on GitHub-hosted runners:

1. `scripts/fetch_sources.sh`: sparse, blob-less, depth-1 checkout of
   `chromium/src` at the release tag (only `build/`, `buildtools/`, `testing/`,
   `tools/clang`, `tools/rust`, `third_party/opus`). It then fetches the FFmpeg
   and NASM dependencies at the revisions that tag pins, and downloads GN,
   Chromium's clang, the Rust toolchain and the Debian sysroot.
2. `scripts/build.sh`: `gn gen` with `is_component_ffmpeg = true`,
   `ffmpeg_branding = "Chrome"`, `proprietary_codecs = true`,
   `is_official_build = true`, then `ninja third_party/ffmpeg:ffmpeg`.
3. `scripts/verify.sh`: checks the architecture and that `ff_h264_decoder`
   and `ff_aac_decoder` are in the library.
4. `scripts/package.sh`: archive plus hashes and build info.

Run it from the Actions tab (**build** → *Run workflow*), giving the Chromium
version and whether to publish a release.

To build locally on Linux x64 (needs `git`, `python3`, `curl`, `unzip`,
`ninja`):

```sh
export CHROMIUM_VERSION=158.0.8108.0 TARGET_CPU=x64
scripts/fetch_sources.sh && scripts/build.sh && scripts/verify.sh && scripts/package.sh
```

## Licence

The scripts in this repository are under the BSD 3-Clause licence
([LICENSE](LICENSE)). The published binaries are FFmpeg (LGPL 2.1+) and Opus
(BSD); see [NOTICE.md](NOTICE.md).
