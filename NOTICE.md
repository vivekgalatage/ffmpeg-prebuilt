# Notice

The `libffmpeg.so` files published by this project are Chromium's copy of
[FFmpeg](https://ffmpeg.org/) built with the H.264 video decoder and the AAC
audio decoder enabled (`ffmpeg_branding = "Chrome"`).

**These codecs may be covered by patents in some countries.** Patent pools
license H.264 and AAC; this project holds no such licence and grants none.
Whether you may use or redistribute these files depends on where you are and
what you do with them. You are responsible for that decision.

These files are provided as-is, without warranty of any kind. This project is
not affiliated with or endorsed by Google, the Chromium project, or FFmpeg.

## Licences

- FFmpeg is licensed under the GNU LGPL v2.1 or later. Chromium builds it
  without GPL components. The licence text is in `licenses/` inside each
  archive.
- Opus (linked into the library) is under a BSD-style licence, also in
  `licenses/`.
- The complete corresponding source is Chromium's public source at the exact
  revisions recorded in each archive's `BUILDINFO.txt`, built with the GN
  arguments recorded there, using this repository's scripts.
