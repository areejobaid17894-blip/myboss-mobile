#!/usr/bin/env bash
# Build the employee app for iOS (simulator .app or device .ipa).
# Uses the same multi-URL fallback as build-demo-apk.sh.
#
# Usage:
#   ./build-demo-ios.sh [--simulator|--ipa]
#
# Prerequisites (physical iPhone / IPA):
#   1. Install Xcode from the App Store (~12 GB)
#   2. sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
#   3. sudo xcodebuild -runFirstLaunch
#   4. brew install cocoapods   (or: sudo gem install cocoapods)
#   5. Open ios/Runner.xcworkspace → Signing & Capabilities → select your Team
#
# Examples:
#   ./build-demo-ios.sh --ipa         # physical iPhone (default)
#   ./build-demo-ios.sh --simulator   # iOS Simulator only
#
set -euo pipefail

cd "$(dirname "$0")"
REPO_ROOT="$(cd ../.. && pwd)"

TARGET="ipa"
for arg in "$@"; do
  case "$arg" in
    --simulator) TARGET="simulator" ;;
    --ipa|--device) TARGET="ipa" ;;
  esac
done

DEFAULT_LAN=$(grep "const demoServerHost" lib/core/config/demo_server_host.dart | sed "s/.*= '\\([^']*\\)'.*/\\1/")
LAN_HOST="${DEMO_LAN_HOST:-${DEFAULT_LAN:-10.6.208.129}}"
GATEWAY_ORIGIN="http://${LAN_HOST}:8090"

TUNNEL_HOST=""
if [ -f "$REPO_ROOT/demo-public-url.txt" ] && [ -s "$REPO_ROOT/demo-public-url.txt" ]; then
  TUNNEL_HOST="$(sed -E 's#https?://##; s#/.*##' "$REPO_ROOT/demo-public-url.txt" | tr -d '[:space:]')"
fi

API_HOSTS="$LAN_HOST"
if [ -n "$TUNNEL_HOST" ]; then
  API_HOSTS="$API_HOSTS,$TUNNEL_HOST"
fi

require_xcode() {
  if [ ! -d "/Applications/Xcode.app" ]; then
    echo "ERROR: Xcode is not installed."
    echo ""
    echo "Install Xcode from the App Store, then run:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo "  sudo xcodebuild -runFirstLaunch"
    echo "  brew install cocoapods"
    echo ""
    echo "Then open ios/Runner.xcworkspace and set your Signing Team."
    exit 1
  fi
  if ! xcodebuild -version >/dev/null 2>&1; then
    echo "ERROR: xcodebuild requires full Xcode (not Command Line Tools only)."
    echo "Run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    exit 1
  fi
}

require_xcode

if ! command -v pod >/dev/null 2>&1; then
  echo "ERROR: CocoaPods is required. Install with: brew install cocoapods"
  exit 1
fi

DEFINE_ARGS=(
  --dart-define=DEMO_MODE=true
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN"
  --dart-define=API_HOSTS="$API_HOSTS"
)

echo "==> Building iOS ($TARGET) with auto-fallback demo URLs:"
echo "    Gateway: $GATEWAY_ORIGIN"
if [ -n "$TUNNEL_HOST" ]; then
  echo "    Tunnel:  https://${TUNNEL_HOST}"
fi
echo "    Hosts baked in: $API_HOSTS"
echo ""

flutter pub get
flutter gen-l10n

if [ -f ios/Podfile ]; then
  echo "==> Running pod install..."
  (cd ios && pod install)
fi

if [ "$TARGET" = "simulator" ]; then
  flutter build ios --simulator --release "${DEFINE_ARGS[@]}"
  APP="build/ios/iphonesimulator/Runner.app"
  if [ -d "$APP" ]; then
    SIZE=$(du -sh "$APP" | cut -f1)
    echo ""
    echo "=========================================="
    echo " iOS SIMULATOR BUILD READY"
    echo "=========================================="
    echo "App bundle: $(pwd)/$APP"
    echo "Size: $SIZE"
    echo ""
    echo "Run on simulator:"
    echo "  open -a Simulator"
    echo "  xcrun simctl install booted \"$APP\""
    echo "  xcrun simctl launch booted com.myboss.mybossMobile"
    echo "=========================================="
  else
    echo "ERROR: Simulator app not found at $APP"
    exit 1
  fi
else
  flutter build ipa --release "${DEFINE_ARGS[@]}"
  IPA=$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -1)
  if [ -n "$IPA" ] && [ -f "$IPA" ]; then
    SIZE=$(du -h "$IPA" | cut -f1)
    echo ""
    echo "=========================================="
    echo " iOS IPA READY"
    echo "=========================================="
    echo "File: $(pwd)/$IPA"
    echo "Size: $SIZE"
    echo "Hosts baked in: $API_HOSTS"
    echo ""
    echo "Install on iPhone:"
    echo "  • Xcode → Window → Devices and Simulators → drag IPA onto device"
    echo "  • Or upload to TestFlight via Transporter"
    echo ""
    echo "Login: demo@orange.com + OTP (auto-filled in demo mode)"
    echo "=========================================="
  else
    echo "ERROR: IPA not found under build/ios/ipa/"
    echo "Open ios/Runner.xcworkspace in Xcode, set your Team under Signing, then retry."
    exit 1
  fi
fi
