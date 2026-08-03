#!/usr/bin/env bash
# Build Flutter web locally without deploying to nginx / Cloudflare tunnel.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
if command -v fvm >/dev/null 2>&1 && [ -f ".fvm/fvm_config.json" ]; then
  FLUTTER_BIN="fvm flutter"
fi

echo "==> Building local Flutter web (NOT deployed to /app/)"

$FLUTTER_BIN pub get
$FLUTTER_BIN gen-l10n
$FLUTTER_BIN build web --release \
  --base-href=/ \
  --dart-define=ENV=development

echo ""
echo "Local build: $(pwd)/build/web"
echo "Serve with:  python3 -m http.server 8092 --directory build/web"
echo "Do NOT run deploy-mobile-web.sh if the team is testing the live tunnel."
