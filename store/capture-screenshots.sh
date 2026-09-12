#!/usr/bin/env bash
#
# Captures App Store / Play screenshots from a booted simulator.
#
# Re-run this after café photos and opening hours are filled in. The current
# set is honest but thin: most cards read "No photo yet" and "Closed", because
# most cafés have neither a photo nor hours. Screenshots are the one place
# where the catalogue's gaps are visible to a reviewer before they are visible
# to a user.
#
#   ./store/capture-screenshots.sh                 # uses the booted simulator
#   ./store/capture-screenshots.sh <device-udid>
#
# The device must be a 6.9" iPhone (1320×2868) — that is the size App Store
# Connect asks for, and a screenshot at any other size is rejected on upload.
set -euo pipefail

cd "$(dirname "$0")/.."

SIM="${1:-$(xcrun simctl list devices booted -j | python3 -c 'import json,sys; d=json.load(sys.stdin)["devices"]; print(next(x["udid"] for v in d.values() for x in v))')}"
OUT="store/screenshots/ios-6.9"
BUNDLE="com.erbil.erbilcafe"

mkdir -p "$OUT"

# route → filename. START_ROUTE is a debug-only entry point override, which is
# why these are built with --debug.
ROUTES=(
  "/|01-home"
  "/cafe/alreef-cafe|02-cafe"
  "/map|03-map"
  "/explore|04-explore"
  "/cafe/alreef-cafe/menu|05-menu"
)

for entry in "${ROUTES[@]}"; do
  route="${entry%%|*}"
  name="${entry##*|}"

  echo "Building $route…"
  flutter build ios --simulator --debug --dart-define=START_ROUTE="$route" >/dev/null

  xcrun simctl install "$SIM" build/ios/iphonesimulator/Runner.app
  xcrun simctl terminate "$SIM" "$BUNDLE" 2>/dev/null || true
  xcrun simctl launch "$SIM" "$BUNDLE" >/dev/null

  # Long enough for the map tiles and the café images to arrive. A screenshot
  # of a skeleton loader is the classic way to ship a placeholder to the store.
  sleep 14
  xcrun simctl io "$SIM" screenshot "$OUT/$name.png" 2>/dev/null
  echo "  → $OUT/$name.png"
done

echo
echo "Checking sizes (App Store 6.9\" wants 1320×2868):"
for f in "$OUT"/*.png; do
  size=$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/{printf "%s ", $2}')
  echo "  $(basename "$f")  $size"
done
