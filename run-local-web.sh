#!/usr/bin/env bash
# Local Flutter web dev — direct backend ports :3001–3005.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
if command -v fvm >/dev/null 2>&1 && [ -f ".fvm/fvm_config.json" ]; then
  FLUTTER_BIN="fvm flutter"
fi

echo "==> Local Flutter web (employee app)"
echo "    API: direct ports :3001–3005 (localhost)"
echo "    App: http://127.0.0.1:8092"
echo ""
echo "    For LAN access use:"
echo "    fvm flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8092 \\"
echo "      --dart-define=API_HOST=<SERVER_IP> --dart-define=ENV=demo --dart-define=DEMO_MODE=true"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n

$FLUTTER_BIN run -d web-server \
  --web-hostname=127.0.0.1 \
  --web-port=8092 \
  --dart-define=ENV=development \
  --dart-define=DEMO_MODE=true
