#!/usr/bin/env bash
#
# Fails when an API key is committed anywhere — working tree or history.
#
# This repository leaked four Google Maps keys through `master`, so the check
# exists to make the next one loud instead of silent. Run it before a release,
# or as a CI step; it exits non-zero on a find so a build fails rather than
# printing a warning into a log nobody reads.
set -euo pipefail

cd "$(dirname "$0")/.."

# Google API keys are a fixed prefix and 35 more characters. Narrow on purpose:
# a pattern that also matches base64 blobs cries wolf and gets switched off.
PATTERN='AIza[0-9A-Za-z_-]{30,45}'

status=0

# Only files git actually tracks. `Secrets.xcconfig` and `local.properties` are
# git-ignored and are *meant* to hold a key on a developer's machine — flagging
# those is the false positive that gets a check like this switched off.
echo "Scanning tracked files…"
if matches=$(git ls-files -z | xargs -0 grep -nIE "$PATTERN" 2>/dev/null); then
  echo "FOUND an API key in a tracked file:"
  echo "$matches" | sed 's/^/  /'
  status=1
else
  echo "  clean"
fi

echo "Scanning every commit…"
found_history=""
while read -r commit; do
  if files=$(git grep -lE "$PATTERN" "$commit" -- 2>/dev/null); then
    found_history+="$files"$'\n'
  fi
done < <(git rev-list --all)

if [ -n "$found_history" ]; then
  echo "FOUND an API key in history (revoke the key; rewriting is optional):"
  echo "$found_history" | sed 's/^\([^:]*\):/  /' | sort -u | head -20
  status=1
else
  echo "  clean"
fi

if [ "$status" -ne 0 ]; then
  echo
  echo "See docs/KEY-ROTATION.md. A committed key must be revoked in the"
  echo "Google Cloud console — removing it from the files is not enough."
fi

exit "$status"
