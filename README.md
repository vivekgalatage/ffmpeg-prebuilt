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

## Choosing the Chromium version

The version to build lives in one place: the [`CHROMIUM_VERSION`](CHROMIUM_VERSION)
file. A push to `main` that changes it starts the **build** workflow, which
publishes the result as the release `chromium-<version>`.

- If that release already has both `x64` and `arm64` archives, the build is
  skipped. Published releases are never overwritten.
- **build** can also be run by hand (*Run workflow*) with an explicit
  `chromium_version`. Setting `force` rebuilds and replaces an existing release
  (its tag and assets are deleted and recreated).
- **bump_chromium_version** takes a `chromium_version`, checks that the tag
  exists, commits it to `CHROMIUM_VERSION` and starts **build**. This is the
  entry point for automation, e.g.
  `gh workflow run bump_chromium_version.yml -R <owner>/ffmpeg-prebuilt -f chromium_version=<version>`
  with a fine-grained token that has *Actions: read and write* on this
  repository.

### Token for calling **bump_chromium_version** from another repository

The calling repository needs a token that is allowed to start workflows here.
Nothing else is required: the commit and the build use this repository's own
`GITHUB_TOKEN`.

1. On GitHub open *Settings → Developer settings → Personal access tokens →
   Fine-grained tokens → Generate new token*.
2. Resource owner: the account that owns `ffmpeg-prebuilt`. Set an expiry and
   note when it ends; after that the calls fail with 401/403.
3. Repository access: *Only select repositories* → `ffmpeg-prebuilt`.
4. Repository permissions: **Actions → Read and write**. Metadata (read) is
   added automatically. Leave everything else at *No access*.
5. Generate the token and copy it.
6. In the calling repository open *Settings → Secrets and variables →
   Actions → New repository secret* and save it, e.g. as
   `FFMPEG_PREBUILT_TOKEN`.
7. Use it in a workflow step there:

   ```yaml
   - run: gh workflow run bump_chromium_version.yml -R <owner>/ffmpeg-prebuilt -f chromium_version=<version>
     env:
       GH_TOKEN: ${{ secrets.FFMPEG_PREBUILT_TOKEN }}
   ```

(A classic token also works with the `public_repo` scope, but it is not
limited to one repository.)

To build locally on Linux x64 (needs `git`, `python3`, `curl`, `unzip`,
`ninja`; `CHROMIUM_VERSION` defaults to the file's contents):

```sh
export TARGET_CPU=x64
scripts/fetch_sources.sh && scripts/build.sh && scripts/verify.sh && scripts/package.sh
```

## Licence

The scripts in this repository are under the BSD 3-Clause licence
([LICENSE](LICENSE)). The published binaries are FFmpeg (LGPL 2.1+) and Opus
(BSD); see [NOTICE.md](NOTICE.md).
