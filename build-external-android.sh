#!/usr/bin/env bash
# Build Android APK for remote testers — direct microservice ports on SERVER_HOST.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

SERVER_HOST="${SERVER_HOST:-${API_HOST:-$(ipconfig getifaddr en0 2>/dev/null || echo "127.0.0.1")}}"

echo "==> External Android APK (direct ports)"
echo "    Server: $SERVER_HOST:3001–3005"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=API_HOST="$SERVER_HOST" \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true

OUT_DIR="build/android-dist"
mkdir -p "$OUT_DIR"
HOST_SLUG="${SERVER_HOST//./-}"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/myboss-demo-${HOST_SLUG}.apk"

echo ""
echo "APK: $(pwd)/$OUT_DIR/myboss-demo-${HOST_SLUG}.apk"
echo "Requires backend at http://${SERVER_HOST}:3001–3005"
