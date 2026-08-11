#!/usr/bin/env bash
# Build Android APK pointing at Orange Apigee (no local nginx / tunnel required).
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

APIGEE_BASE="${APIGEE_API_BASE_URL:-https://api-demo.orange.com}"
DEMO_MODE="${DEMO_MODE:-false}"
OUT_NAME="myboss-apigee-${APIGEE_BASE#https://}"
OUT_NAME="${OUT_NAME#http://}"
OUT_NAME="${OUT_NAME//\//-}.apk"

echo "==> Apigee Android APK"
echo "    Gateway:   $APIGEE_BASE"
echo "    Demo OTP:  $DEMO_MODE"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=GATEWAY_ORIGIN="$APIGEE_BASE" \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE="$DEMO_MODE" \
  --dart-define=PUSH_ENABLED=true

OUT_DIR="build/android-dist"
mkdir -p "$OUT_DIR"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/$OUT_NAME"

echo ""
echo "=========================================="
echo " APIGEE APK READY"
echo "=========================================="
echo "File: $(pwd)/$OUT_DIR/$OUT_NAME"
echo "API:  $APIGEE_BASE/auth/api/v1/..."
echo ""
echo "Override gateway: APIGEE_API_BASE_URL=https://your-apigee-host ./build-apigee-android.sh"
echo "=========================================="
