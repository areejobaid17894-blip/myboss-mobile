#!/usr/bin/env bash
# Build Android APK for physical device on same Wi‑Fi as demo server (direct backend ports).
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

# Physical device on same Wi‑Fi (override: API_HOST=10.0.0.5 ./build-local-android.sh)
API_HOST="${API_HOST:-$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "10.0.2.2")}"

OUT_DIR="build/android-dist"
APK_NAME="myboss-demo-${API_HOST//./-}.apk"

echo "==> Building Android APK (Flutter 3.35.7 / Dart 3.9.2)"
echo "    API host: $API_HOST (direct ports 3001–3005)"
echo "    Demo OTP auto-fill: enabled"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=ENV=development \
  --dart-define=API_HOST="$API_HOST" \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true

mkdir -p "$OUT_DIR"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/$APK_NAME"

echo ""
echo "==> APK ready: $OUT_DIR/$APK_NAME"
echo "    Install: adb install -r $OUT_DIR/$APK_NAME"
echo "    Requires backend on this machine (myboss-platform deploy-demo-server.sh)"
echo "    Phone must be on same Wi‑Fi and reach http://${API_HOST}:3001/api/v1/health"
