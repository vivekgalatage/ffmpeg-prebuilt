#!/usr/bin/env bash
# Runs scripts/<name>.sh, keeping a log. On failure, the last lines of the
# log are also reported as a GitHub Actions error annotation, so they can be
# read through the REST API without downloading the full job log.
set -uo pipefail

name="$1"
dir="$(cd "$(dirname "$0")" && pwd)"
logs="$dir/../logs"
mkdir -p "$logs"

"$dir/$name.sh" 2>&1 | tee "$logs/$name.log"
rc=${PIPESTATUS[0]}

if [ "$rc" -ne 0 ] && [ -n "${GITHUB_ACTIONS:-}" ]; then
  tail_text=$(tail -n 80 "$logs/$name.log" |
    sed -e 's/\x1b\[[0-9;]*m//g' -e 's/%/%25/g' -e 's/\r/%0D/g' |
    awk '{ printf "%s%%0A", $0 }')
  echo "::error title=$name failed (last 80 lines)::$tail_text"
fi
exit "$rc"
