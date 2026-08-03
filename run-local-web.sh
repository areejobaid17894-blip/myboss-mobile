#!/usr/bin/env bash
# Local Flutter web dev — does NOT update the deployed /app/ on port 8090.
# Use this while the team tests the frozen tunnel build.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
if command -v fvm >/dev/null 2>&1 && [ -f ".fvm/fvm_config.json" ]; then
  FLUTTER_BIN="fvm flutter"
fi

echo "==> Local Flutter web (Dart 3.9.2 / Flutter 3.35.7 via FVM if installed)"
echo "    API target: http://127.0.0.1:8090 (unchanged deployed gateway)"
echo "    App URL:    http://127.0.0.1:8092"
echo ""

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n

$FLUTTER_BIN run -d web-server \
  --web-hostname=127.0.0.1 \
  --web-port=8092 \
  --dart-define=ENV=development
