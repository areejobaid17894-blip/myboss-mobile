#!/usr/bin/env bash
# Run myboss-mobile on iOS simulator or device (demo mode + push).
#
# Usage:
#   ./build-ios-demo.sh                    # auto: tunnel URL + LAN fallback
#   IOS_TARGET=simulator ./build-ios-demo.sh
#   IOS_TARGET=device ./build-ios-demo.sh  # physical iPhone on same Wi‑Fi
#   GATEWAY_ORIGIN=http://10.6.209.30:8090 ./build-ios-demo.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

FLUTTER_BIN="fvm flutter"
command -v fvm >/dev/null 2>&1 || FLUTTER_BIN="flutter"

if [ ! -f ios/Runner/GoogleService-Info.plist ]; then
  echo "ERROR: Missing ios/Runner/GoogleService-Info.plist"
  echo "Run: ./scripts/setup-ios-firebase.sh"
  exit 1
fi

LAN=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")
GATEWAY_ORIGIN="${GATEWAY_ORIGIN:-}"
API_HOSTS="${API_HOSTS:-}"

PLATFORM_DIR="$(cd "$ROOT/../myboss-platform" && pwd)"
URL_FILE="$PLATFORM_DIR/demo-public-url.txt"

if [ -z "$GATEWAY_ORIGIN" ] && [ -f "$URL_FILE" ]; then
  TUNNEL_URL="$(tr -d '[:space:]' < "$URL_FILE")"
  TUNNEL_HOST="${TUNNEL_URL#https://}"
  TUNNEL_HOST="${TUNNEL_HOST#http://}"
  if [ -n "$TUNNEL_HOST" ]; then
    GATEWAY_ORIGIN="$TUNNEL_URL"
    API_HOSTS="${TUNNEL_HOST}"
    [ -n "$LAN" ] && API_HOSTS="${API_HOSTS},${LAN}"
    [ "${IOS_TARGET:-}" = "simulator" ] && API_HOSTS="${API_HOSTS},127.0.0.1"
  fi
fi

if [ -z "$GATEWAY_ORIGIN" ]; then
  if [ "${IOS_TARGET:-}" = "device" ] && [ -n "$LAN" ]; then
    GATEWAY_ORIGIN="http://${LAN}:8090"
    API_HOSTS="${LAN}"
  else
    GATEWAY_ORIGIN="http://127.0.0.1:8090"
    API_HOSTS="127.0.0.1"
    [ -n "$LAN" ] && API_HOSTS="${API_HOSTS},${LAN}"
  fi
fi

if [ -z "$API_HOSTS" ]; then
  API_HOSTS="${GATEWAY_ORIGIN#https://}"
  API_HOSTS="${API_HOSTS#http://}"
  API_HOSTS="${API_HOSTS%%/*}"
  API_HOSTS="${API_HOSTS%%:*}"
fi

echo "==> iOS demo run (push enabled)"
echo "    Gateway:   $GATEWAY_ORIGIN"
echo "    API hosts: $API_HOSTS"
echo "    Target:    ${IOS_TARGET:-auto}"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
cd ios && pod install && cd ..

RUN_ARGS=(
  --dart-define=DEMO_MODE=true
  --dart-define=PUSH_ENABLED=true
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN"
  --dart-define=API_HOSTS="$API_HOSTS"
)

if [ "${IOS_TARGET:-}" = "simulator" ]; then
  SIM_ID="${IOS_SIMULATOR_ID:-}"
  if [ -z "$SIM_ID" ]; then
    SIM_ID=$(xcrun simctl list devices available | grep -E "iPhone.*Booted" | head -1 | grep -oE '[A-F0-9-]{36}' || true)
  fi
  if [ -z "$SIM_ID" ]; then
    SIM_ID=$(xcrun simctl list devices available | grep "iPhone 17 Pro (" | grep -v Max | head -1 | grep -oE '[A-F0-9-]{36}' || true)
    [ -n "$SIM_ID" ] && xcrun simctl boot "$SIM_ID" 2>/dev/null || true
    open -a Simulator 2>/dev/null || true
    sleep 3
  fi
  if [ -n "$SIM_ID" ]; then
    RUN_ARGS+=(-d "$SIM_ID")
  fi
fi

$FLUTTER_BIN run "${RUN_ARGS[@]}"
