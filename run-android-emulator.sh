#!/usr/bin/env bash
# Start Android emulator + run myboss-mobile with push + demo gateway.
set -euo pipefail

cd "$(dirname "$0")"

FLUTTER="${FLUTTER:-fvm flutter}"
command -v fvm >/dev/null 2>&1 || FLUTTER="flutter"

# Prefer Homebrew SDK (matches android/local.properties); AVDs live in ~/.android/avd
SDK="${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}"
if [ ! -x "$SDK/emulator/emulator" ]; then
  SDK="$HOME/Library/Android/sdk"
fi
ADB="$SDK/platform-tools/adb"
EMU="$SDK/emulator/emulator"
AVD="${AVD:-Pixel_7}"

GATEWAY_ORIGIN="${GATEWAY_ORIGIN:-http://10.0.2.2:8090}"
API_HOSTS="${API_HOSTS:-10.0.2.2}"

echo "==> SDK: $SDK"
echo "==> AVD: $AVD"
echo "==> Gateway (emulator → Mac): $GATEWAY_ORIGIN"
echo "==> Push: enabled"
echo ""

if ! curl -sf --connect-timeout 3 http://127.0.0.1:8090/health >/dev/null 2>&1; then
  echo "WARN: Demo gateway not responding on :8090. Start myboss-platform first."
fi

# HEADLESS=1 saves RAM (no emulator window). Set HEADLESS=0 to show the GUI.
HEADLESS="${HEADLESS:-1}"

# Start emulator if none connected
if ! "$ADB" devices | grep -qE '^emulator-[0-9]+[[:space:]]+device'; then
  echo "==> Starting emulator ($AVD) — first boot can take 1–2 minutes..."
  EMU_ARGS=(-avd "$AVD" -memory 1536 -cores 2 -no-audio -gpu swiftshader_indirect -no-snapshot-load)
  if [ "$HEADLESS" = "1" ]; then
    EMU_ARGS+=(-no-window)
    echo "    (headless — set HEADLESS=0 for visible window)"
  fi
  "$EMU" "${EMU_ARGS[@]}" >/tmp/myboss-emulator.log 2>&1 &
  "$ADB" wait-for-device
  # Wait for boot completed
  for i in $(seq 1 60); do
    boot=$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$boot" = "1" ]; then break; fi
    sleep 2
  done
  echo "==> Emulator ready"
else
  echo "==> Emulator already running"
fi

"$ADB" devices -l

$FLUTTER pub get
$FLUTTER gen-l10n 2>/dev/null || true

$FLUTTER run \
  --dart-define=DEMO_MODE=true \
  --dart-define=PUSH_ENABLED=true \
  --dart-define=GATEWAY_ORIGIN="$GATEWAY_ORIGIN" \
  --dart-define=API_HOSTS="$API_HOSTS" \
  "$@"
