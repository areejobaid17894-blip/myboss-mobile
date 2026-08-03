#!/usr/bin/env bash
# Run employee app on a physical device against a remote demo server (not localhost).
# Usage: ./run-on-demo-server.sh <DEMO_SERVER_IP>
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <DEMO_SERVER_IP>"
  echo "Example: $0 203.0.113.50"
  exit 1
fi

DEMO_HOST="$1"
cd "$(dirname "$0")"

flutter pub get
flutter gen-l10n
echo "==> Connecting mobile app to demo server: $DEMO_HOST"
flutter run --dart-define=API_HOST="$DEMO_HOST"
