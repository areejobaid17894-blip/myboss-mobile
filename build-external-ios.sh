#!/usr/bin/env bash
# Build iOS app for external testers (tunnel-first, LAN fallback on same Wi‑Fi).
#
# Prerequisites:
#   - Demo stack on :8090
#   - Cloudflare tunnel running (myboss-platform/scripts/start-demo-tunnel.sh)
#   - Xcode + CocoaPods
#
# Usage:
#   ./build-external-ios.sh              # release build, install via Xcode/Archive
#   ./build-external-ios.sh --run        # run on connected iPhone / simulator
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

FLUTTER_BIN="fvm flutter"
command -v fvm >/dev/null 2>&1 || FLUTTER_BIN="flutter"

PLATFORM_DIR="$(cd "$ROOT/../myboss-platform" && pwd)"
URL_FILE="${MYBOSS_PLATFORM_DIR:-$PLATFORM_DIR}/demo-public-url.txt"

if [ ! -f "$URL_FILE" ]; then
  echo "ERROR: $URL_FILE not found."
  echo "Start tunnel: cd ../myboss-platform && ./scripts/start-demo-tunnel.sh"
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

echo "==> External iOS build (tunnel-first)"
echo "    Tunnel:  $TUNNEL_URL"
echo "    Probes:  $API_HOSTS"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
cd ios && pod install && cd ..

DEFINES=(
  --dart-define=API_HOSTS="$API_HOSTS"
  --dart-define=GATEWAY_ORIGIN="$TUNNEL_URL"
  --dart-define=DEMO_MODE=true
  --dart-define=PUSH_ENABLED=true
)

if [ "${1:-}" = "--run" ]; then
  $FLUTTER_BIN run "${DEFINES[@]}"
  exit 0
fi

$FLUTTER_BIN build ios --release "${DEFINES[@]}"

echo ""
echo "=========================================="
echo " iOS RELEASE BUILD READY"
echo "=========================================="
echo "Open Xcode to install on device:"
echo "  open ios/Runner.xcworkspace"
echo "Product → Archive (for TestFlight) or Run on connected iPhone"
echo ""
echo "Gateway: $TUNNEL_URL"
echo "LAN fallback: http://${LAN:-<unknown>}:8090"
echo "Login: areej.obaid@orange.com + OTP (or demo@orange.com)"
echo "Keep Mac awake + cloudflared running."
echo "=========================================="
