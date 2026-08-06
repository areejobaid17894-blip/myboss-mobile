#!/usr/bin/env bash
# Copy GoogleService-Info.plist from Downloads and sync firebase_options.dart for iOS.
set -euo pipefail

cd "$(dirname "$0")/.."
PLIST_DEST="ios/Runner/GoogleService-Info.plist"
SRC="${1:-$HOME/Downloads/GoogleService-Info.plist}"

if [ ! -f "$SRC" ]; then
  echo "ERROR: GoogleService-Info.plist not found at: $SRC"
  echo ""
  echo "Firebase Console steps:"
  echo "  1. https://console.firebase.google.com/project/my-boss-app-38576/settings/general"
  echo "  2. Add app → iOS"
  echo "  3. Bundle ID: com.myboss.mybossMobile"
  echo "  4. Download GoogleService-Info.plist"
  echo "  5. Run: $0 /path/to/GoogleService-Info.plist"
  exit 1
fi

cp "$SRC" "$PLIST_DEST"
echo "==> Copied to $PLIST_DEST"

FLUTTER_BIN="fvm flutter"
command -v fvm >/dev/null 2>&1 || FLUTTER_BIN="flutter"

if command -v flutterfire >/dev/null 2>&1 || dart pub global list 2>/dev/null | grep -q flutterfire_cli; then
  echo "==> Running flutterfire configure (select my-boss-app-38576, iOS + Android)..."
  dart pub global activate flutterfire_cli 2>/dev/null || true
  "$FLUTTER_BIN" pub get
  flutterfire configure --project=my-boss-app-38576 --platforms=android,ios --yes 2>/dev/null \
    || flutterfire configure --project=my-boss-app-38576 --platforms=android,ios
  echo "==> firebase_options.dart updated"
else
  echo "WARN: flutterfire CLI not found. Manually update lib/firebase_options.dart ios section from plist."
fi

echo ""
echo "Next: upload APNs .p8 key in Firebase → Project settings → Cloud Messaging → Apple app configuration"
echo "Then: ./build-ios-demo.sh  (simulator) or connect iPhone and flutter run with PUSH_ENABLED=true"
