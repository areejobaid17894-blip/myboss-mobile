#!/usr/bin/env bash
# Build installable APK for a physical phone (no USB) — points to demo gateway.
# Usage: ./build-demo-apk.sh [DEMO_SERVER_IP]
# Default IP: lib/core/config/demo_server_host.dart
# Output: build/app/outputs/flutter-apk/app-release.apk
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="fvm flutter"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
fi

PLATFORM_DIR="$(cd "$(dirname "$0")/../myboss-platform" && pwd)"
URL_FILE="${MYBOSS_PLATFORM_DIR:-$PLATFORM_DIR}/demo-public-url.txt"

DEFAULT_HOST=$(grep "const demoServerHost" lib/core/config/demo_server_host.dart | sed "s/.*= '\\([^']*\\)'.*/\\1/")
DEMO_HOST="${1:-$DEFAULT_HOST}"
GATEWAY_PORT="${GATEWAY_PORT:-8090}"
GATEWAY_ORIGIN="http://${DEMO_HOST}:${GATEWAY_PORT}"
API_HOSTS="${DEMO_HOST}"

if [ -f "$URL_FILE" ]; then
  TUNNEL_URL="$(tr -d '[:space:]' < "$URL_FILE")"
  TUNNEL_HOST="${TUNNEL_URL#https://}"
  TUNNEL_HOST="${TUNNEL_HOST#http://}"
  if [ -n "$TUNNEL_HOST" ]; then
    API_HOSTS="${TUNNEL_HOST},${DEMO_HOST}"
  fi
fi

if [ -z "$DEMO_HOST" ]; then
  echo "Usage: $0 [DEMO_SERVER_IP]"
  echo "Set demoServerHost in lib/core/config/demo_server_host.dart or pass IP as argument."
  exit 1
fi

echo "==> Building APK for demo hosts: $API_HOSTS"
$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build apk --release \
  --dart-define=API_HOSTS="$API_HOSTS" \
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN" \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true

APK="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK" ]; then
  SIZE=$(du -h "$APK" | cut -f1)
  echo ""
  echo "=========================================="
  echo " APK READY — copy to your phone"
  echo "=========================================="
  echo "File: $(pwd)/$APK"
  echo "Size: $SIZE"
  echo ""
  echo "Install on phone:"
  echo "  1. Uninstall old app first"
  echo "  2. Copy APK to phone (WhatsApp, email, Google Drive, etc.)"
  echo "  3. Settings → Security → allow install from unknown sources"
  echo "  4. Open the APK file on phone → Install"
  echo ""
  echo "Login: demo@orange.com + OTP (auto-filled in demo mode)"
  echo "Probed hosts: $API_HOSTS"
  echo "=========================================="
else
  echo "ERROR: APK not found at $APK"
  exit 1
fi
