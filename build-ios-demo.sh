#!/usr/bin/env bash
# Run myboss-mobile on iOS simulator or device with push enabled.
set -euo pipefail

cd "$(dirname "$0")/.."

FLUTTER_BIN="fvm flutter"
command -v fvm >/dev/null 2>&1 || FLUTTER_BIN="flutter"

if [ ! -f ios/Runner/GoogleService-Info.plist ]; then
  echo "ERROR: Missing ios/Runner/GoogleService-Info.plist"
  echo "Run: ./scripts/setup-ios-firebase.sh"
  exit 1
fi

GATEWAY_ORIGIN="${GATEWAY_ORIGIN:-http://127.0.0.1:8090}"
API_HOSTS="${API_HOSTS:-127.0.0.1}"

PLATFORM_DIR="$(cd "$(dirname "$0")/../myboss-platform" && pwd)"
URL_FILE="$PLATFORM_DIR/demo-public-url.txt"
if [ -f "$URL_FILE" ]; then
  TUNNEL_URL="$(tr -d '[:space:]' < "$URL_FILE")"
  TUNNEL_HOST="${TUNNEL_URL#https://}"
  TUNNEL_HOST="${TUNNEL_HOST#http://}"
  if [ -n "$TUNNEL_HOST" ]; then
    API_HOSTS="${TUNNEL_HOST},127.0.0.1"
    GATEWAY_ORIGIN="$TUNNEL_URL"
  fi
fi

echo "==> iOS demo run (push enabled)"
echo "    Gateway: $GATEWAY_ORIGIN"
echo "    API hosts: $API_HOSTS"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
cd ios && pod install && cd ..

$FLUTTER_BIN run \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true \
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN" \
  --dart-define=API_HOSTS="$API_HOSTS"
