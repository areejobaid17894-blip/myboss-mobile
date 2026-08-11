#!/usr/bin/env bash
# Build Flutter web for employee browser testing (direct microservice ports).
# Usage: API_HOST=<SERVER_IP> ./build-demo-web.sh
set -euo pipefail

cd "$(dirname "$0")"

HOST="${API_HOST:-127.0.0.1}"

echo "==> Building Flutter web (demo mode, API_HOST=${HOST})"

FLUTTER_CMD="flutter"
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD="fvm flutter"
fi

$FLUTTER_CMD pub get
$FLUTTER_CMD gen-l10n
$FLUTTER_CMD build web --release \
  --base-href=/ \
  --dart-define=API_HOST="${HOST}" \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE=true

echo ""
echo "=========================================="
echo " WEB BUILD READY"
echo "=========================================="
echo "Output: $(pwd)/build/web"
echo ""
echo "Serve:  python3 -m http.server 8092 --directory build/web"
echo "Open:   http://${HOST}:8092"
echo "Login:  demo@orange.com + OTP"
echo "=========================================="
