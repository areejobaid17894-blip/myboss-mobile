#!/usr/bin/env bash
# Local Flutter web dev — API via Apigee or direct backend ports (no nginx :8090).
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
if command -v fvm >/dev/null 2>&1 && [ -f ".fvm/fvm_config.json" ]; then
  FLUTTER_BIN="fvm flutter"
fi

APIGEE_BASE="${APIGEE_API_BASE_URL:-https://api-demo.orange.com}"
USE_DIRECT_PORTS="${USE_DIRECT_PORTS:-false}"

if [ "$USE_DIRECT_PORTS" = "true" ]; then
  API_MODE="direct ports :3001–3005"
  DART_DEFINES=(--dart-define=ENV=development)
else
  API_MODE="$APIGEE_BASE"
  DART_DEFINES=(--dart-define=GATEWAY_ORIGIN="$APIGEE_BASE" --dart-define=ENV=demo)
fi

echo "==> Local Flutter web (Dart 3.9.2 / Flutter 3.35.7 via FVM if installed)"
echo "    API target: $API_MODE"
echo "    App URL:    http://127.0.0.1:8092"
echo "    Direct ports: USE_DIRECT_PORTS=true ./run-local-web.sh"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n

$FLUTTER_BIN run -d web-server \
  --web-hostname=127.0.0.1 \
  --web-port=8092 \
  "${DART_DEFINES[@]}"
