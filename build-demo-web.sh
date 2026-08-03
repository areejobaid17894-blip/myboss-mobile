#!/usr/bin/env bash
# Build Flutter web for mobile browser testing (served at /app/ on the API gateway).
# Usage: ./build-demo-web.sh
# Deploy: ../myboss-platform/scripts/deploy-mobile-web.sh
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Building Flutter web for /app/ (demo mode, same-origin API)"

FLUTTER_CMD="flutter"
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD="fvm flutter"
fi

$FLUTTER_CMD pub get
$FLUTTER_CMD gen-l10n
$FLUTTER_CMD build web --release \
  --base-href=/app/ \
  --dart-define=DEMO_MODE=true

echo ""
echo "=========================================="
echo " WEB BUILD READY"
echo "=========================================="
echo "Output: $(pwd)/build/web"
echo ""
echo "Deploy: ../myboss-platform/scripts/deploy-mobile-web.sh"
echo "Then open: https://<tunnel-host>/app/"
echo "Login: demo@orange.com + OTP"
echo "=========================================="
