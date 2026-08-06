#!/usr/bin/env bash
# Build Android APK locally — does NOT deploy mobile web or tunnel.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

PLATFORM_DIR="$(cd "$(dirname "$0")/../myboss-platform" && pwd)"
URL_FILE="${MYBOSS_PLATFORM_DIR:-$PLATFORM_DIR}/demo-public-url.txt"

# Physical device on same Wi‑Fi as this Mac (override: API_HOST=10.0.0.5 ./build-local-android.sh)
API_HOST="${API_HOST:-$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "10.0.2.2")}"
GATEWAY_PORT="${GATEWAY_PORT:-8090}"
GATEWAY_ORIGIN="http://${API_HOST}:${GATEWAY_PORT}"
API_HOSTS="${API_HOST}"

if [ -f "$URL_FILE" ]; then
  TUNNEL_URL="$(tr -d '[:space:]' < "$URL_FILE")"
  TUNNEL_HOST="${TUNNEL_URL#https://}"
  TUNNEL_HOST="${TUNNEL_HOST#http://}"
  if [ -n "$TUNNEL_HOST" ]; then
    API_HOSTS="${TUNNEL_HOST},${API_HOSTS}"
    GATEWAY_ORIGIN="$TUNNEL_URL"
  fi
fi

OUT_DIR="build/android-dist"
APK_NAME="myboss-demo-${API_HOST//./-}.apk"

echo "==> Building Android APK (Flutter 3.35.7 / Dart 3.9.2)"
echo "    Demo hosts (probed at startup): $API_HOSTS"
echo "    Demo OTP auto-fill: enabled"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=API_HOSTS="$API_HOSTS" \
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN" \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true

mkdir -p "$OUT_DIR"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/$APK_NAME"

echo ""
echo "=========================================="
echo " ANDROID APK READY"
echo "=========================================="
echo "File: $(pwd)/$OUT_DIR/$APK_NAME"
echo "Size: $(du -h "$OUT_DIR/$APK_NAME" | cut -f1)"
echo ""
echo "Install (USB): adb install -r $OUT_DIR/$APK_NAME"
echo "Or copy the APK to your phone and open it."
echo ""
echo "Requirements:"
echo "  • Same Wi‑Fi: app probes $GATEWAY_ORIGIN first"
if [ -f "$URL_FILE" ]; then
  echo "  • Off Wi‑Fi / mobile data: app falls back to tunnel in demo-public-url.txt"
fi
echo "  • Demo gateway running on port ${GATEWAY_PORT}"
echo "  • Login: demo@orange.com + OTP (auto-filled)"
echo ""
echo "Android emulator: API_HOST=10.0.2.2 ./build-local-android.sh"
echo "=========================================="
