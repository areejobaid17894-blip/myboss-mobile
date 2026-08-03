#!/usr/bin/env bash
# Run my boss app mobile on Android emulator (backend must be on this Mac, ports 3001–3005).
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER="${FLUTTER:-fvm flutter}"
if ! command -v fvm >/dev/null 2>&1; then
  FLUTTER="flutter"
fi

echo "==> API host: 10.0.2.2 (Android emulator → your Mac)"
echo "==> Ensure Docker backend is up: ../../infrastructure/scripts/verify-backend.sh"
echo ""

$FLUTTER pub get
$FLUTTER gen-l10n 2>/dev/null || true

$FLUTTER run \
  --dart-define=DEMO_MODE=true \
  "$@"
