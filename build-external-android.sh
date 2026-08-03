#!/usr/bin/env bash
# Build Android APK for testers outside your laptop (mobile data / remote).
# Uses Cloudflare tunnel URL from myboss-platform/demo-public-url.txt (primary)
# and LAN IP as fallback on same Wi‑Fi.
#
# Prerequisites:
#   - Demo stack on :8090
#   - ./scripts/start-demo-tunnel.sh (in myboss-platform) — tunnel running
#
# Output: build/android-dist/myboss-demo-external.apk
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

PLATFORM_DIR="$(cd "$(dirname "$0")/../myboss-platform" && pwd)"
URL_FILE="${MYBOSS_PLATFORM_DIR:-$PLATFORM_DIR}/demo-public-url.txt"

if [ ! -f "$URL_FILE" ]; then
  echo "ERROR: $URL_FILE not found."
  echo "Start tunnel first: cd ../myboss-platform && ./scripts/start-demo-tunnel.sh"
  exit 1
fi

TUNNEL_URL="$(tr -d '[:space:]' < "$URL_FILE")"
TUNNEL_HOST="${TUNNEL_URL#https://}"
TUNNEL_HOST="${TUNNEL_HOST#http://}"

if [ -z "$TUNNEL_HOST" ]; then
  echo "ERROR: demo-public-url.txt is empty. Restart the Cloudflare tunnel."
  exit 1
fi

LAN=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")
API_HOSTS="${TUNNEL_HOST}"
[ -n "$LAN" ] && API_HOSTS="${TUNNEL_HOST},${LAN}"

echo "==> External Android APK (tunnel-first)"
echo "    Tunnel:  $TUNNEL_URL"
echo "    Probes:  $API_HOSTS"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=API_HOSTS="$API_HOSTS" \
  --dart-define=GATEWAY_ORIGIN="$TUNNEL_URL" \
  --dart-define=DEMO_MODE=true

OUT_DIR="build/android-dist"
mkdir -p "$OUT_DIR"
APK="$OUT_DIR/myboss-demo-external.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$APK"

echo ""
echo "=========================================="
echo " EXTERNAL APK READY"
echo "=========================================="
echo "File: $(pwd)/$APK"
echo "Size: $(du -h "$APK" | cut -f1)"
echo ""
echo "Share by email / Drive / WhatsApp."
echo "Keep Mac awake + cloudflared running."
echo "If tunnel URL changes, rebuild this APK."
echo "Login: demo@orange.com + OTP"
echo "=========================================="
