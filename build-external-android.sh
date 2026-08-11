#!/usr/bin/env bash
# Build Android APK for remote testers via Orange Apigee (default).
# Legacy nginx/Cloudflare fallback: USE_NGINX_TUNNEL=true
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

APIGEE_BASE="${APIGEE_API_BASE_URL:-https://api-demo.orange.com}"
PLATFORM_DIR="$(cd "$(dirname "$0")/../myboss-platform" && pwd)"
URL_FILE="${MYBOSS_PLATFORM_DIR:-$PLATFORM_DIR}/demo-public-url.txt"

if [ "${USE_NGINX_TUNNEL:-false}" = "true" ]; then
  if [ ! -f "$URL_FILE" ]; then
    echo "ERROR: $URL_FILE not found."
    echo "Start tunnel: cd ../myboss-platform && ./scripts/start-demo-tunnel.sh"
    echo "Or use Apigee (default): ./build-external-android.sh"
    exit 1
  fi
  TUNNEL_URL="$(tr -d '[:space:]' < "$URL_FILE")"
  TUNNEL_HOST="${TUNNEL_URL#https://}"
  TUNNEL_HOST="${TUNNEL_HOST#http://}"
  LAN=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")
  API_HOSTS="${TUNNEL_HOST}"
  [ -n "$LAN" ] && API_HOSTS="${TUNNEL_HOST},${LAN}"
  GATEWAY_ORIGIN="$TUNNEL_URL"
  OUT_APK="myboss-demo-external-tunnel.apk"
  echo "==> External Android APK (legacy nginx tunnel)"
  echo "    Tunnel:  $TUNNEL_URL"
else
  API_HOSTS="$APIGEE_BASE"
  GATEWAY_ORIGIN="$APIGEE_BASE"
  OUT_APK="myboss-demo-external.apk"
  echo "==> External Android APK (Orange Apigee)"
  echo "    Gateway: $APIGEE_BASE"
fi

echo "    Probes:  $API_HOSTS"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=API_HOSTS="$API_HOSTS" \
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN" \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true

OUT_DIR="build/android-dist"
mkdir -p "$OUT_DIR"
cp build/app/outputs/flutter-apk/app-release.apk "$OUT_DIR/$OUT_APK"

echo ""
echo "=========================================="
echo " EXTERNAL APK READY"
echo "=========================================="
echo "File: $(pwd)/$OUT_DIR/$OUT_APK"
echo "API:  $GATEWAY_ORIGIN"
echo ""
echo "Legacy tunnel build: USE_NGINX_TUNNEL=true ./build-external-android.sh"
echo "=========================================="
