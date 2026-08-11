#!/usr/bin/env bash
# Build Android APK for remote testers via Orange Apigee.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

APIGEE_BASE="${APIGEE_API_BASE_URL:-https://api-demo.orange.com}"

echo "==> External Android APK (Orange Apigee)"
echo "    Gateway: $APIGEE_BASE"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=API_HOSTS="$APIGEE_BASE" \
  --dart-define=GATEWAY_ORIGIN="$APIGEE_BASE" \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true

OUT_DIR="build/android-dist"
mkdir -p "$OUT_DIR"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/myboss-demo-external.apk"

echo ""
echo "=========================================="
echo " EXTERNAL APK READY"
echo "=========================================="
echo "File: $(pwd)/$OUT_DIR/myboss-demo-external.apk"
echo "API:  $APIGEE_BASE"
echo "=========================================="
