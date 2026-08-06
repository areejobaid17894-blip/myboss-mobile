#!/usr/bin/env bash
# Start emulator, install emulator APK (10.0.2.2), launch app, optional test push.
set -euo pipefail

cd "$(dirname "$0")"

SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
if [ ! -x "$SDK/emulator/emulator" ]; then
  SDK="/opt/homebrew/share/android-commandlinetools"
fi
ADB="$SDK/platform-tools/adb"
EMU="$SDK/emulator/emulator"
AVD="${AVD:-Pixel_7}"
HEADLESS="${HEADLESS:-1}"
APK="${APK:-build/android-dist/myboss-demo-10-0-2-2.apk}"
GATEWAY="${GATEWAY:-http://127.0.0.1:8090}"

free_mb() {
  vm_stat | awk '/Pages free/ {printf "%.0f", $3*16384/1048576}'
}

echo "==> Free RAM: $(free_mb) MB (emulator needs ~2 GB headroom)"
echo "==> AVD: $AVD  headless=$HEADLESS"
echo ""

if ! curl -sf --connect-timeout 3 "$GATEWAY/health" >/dev/null 2>&1; then
  echo "ERROR: Demo gateway not running on :8090. Start myboss-platform first."
  exit 1
fi

if [ ! -f "$APK" ]; then
  echo "==> Building emulator APK (API_HOST=10.0.2.2)..."
  API_HOST=10.0.2.2 ./build-local-android.sh
fi

start_emulator() {
  pkill -f "qemu-system-aarch64.*$AVD" 2>/dev/null || true
  sleep 1
  local emu_args=(-avd "$AVD" -memory 1536 -cores 2 -no-audio -gpu swiftshader_indirect -no-snapshot-load)
  if [ "$HEADLESS" = "1" ]; then
    emu_args+=(-no-window)
  fi
  "$EMU" "${emu_args[@]}" >/tmp/myboss-emulator.log 2>&1 &
  EMU_PID=$!
  echo "==> Emulator PID $EMU_PID (log: /tmp/myboss-emulator.log)"
  for i in $(seq 1 90); do
    if "$ADB" devices 2>/dev/null | grep -qE '^emulator-[0-9]+[[:space:]]+device'; then
      boot=$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
      if [ "$boot" = "1" ]; then
        echo "==> Emulator booted (${i}x2s)"
        return 0
      fi
    fi
    if ! kill -0 "$EMU_PID" 2>/dev/null; then
      echo "ERROR: Emulator exited. Last log lines:"
      tail -20 /tmp/myboss-emulator.log
      echo ""
      echo "Tip: close Chrome tabs / stop unused Docker stacks, then retry."
      echo "     HEADLESS=0 ./test-android-emulator.sh  (GUI, needs more RAM)"
      exit 1
    fi
    sleep 2
  done
  echo "ERROR: Emulator boot timeout"
  exit 1
}

if ! "$ADB" devices | grep -qE '^emulator-[0-9]+[[:space:]]+device'; then
  start_emulator
else
  echo "==> Emulator already connected"
fi

"$ADB" devices -l
echo "==> Installing $APK"
"$ADB" install -r "$APK"
echo "==> Launching app"
"$ADB" shell am start -n com.myboss.myboss_mobile/.MainActivity
sleep 8

if "$ADB" shell pidof com.myboss.myboss_mobile >/dev/null 2>&1; then
  echo "==> App process: running"
else
  echo "WARN: App process not found"
fi

echo "==> Screenshot: /tmp/myboss-emulator-screen.png"
"$ADB" exec-out screencap -p > /tmp/myboss-emulator-screen.png

echo "==> Recent Flutter logs:"
"$ADB" logcat -d -t 120 | grep -iE 'flutter|Push|FCM|token|error|exception' | tail -25 || true

echo ""
echo "=========================================="
echo " EMULATOR TEST READY"
echo "=========================================="
echo "Login on emulator: demo@orange.com + OTP (auto-filled in demo mode)"
echo "Send push from admin: $GATEWAY/login → Notifications"
echo "Screenshot: /tmp/myboss-emulator-screen.png"
if [ "$HEADLESS" = "1" ]; then
  echo ""
  echo "GUI emulator: HEADLESS=0 ./test-android-emulator.sh"
  echo "(Close other apps first if it exits with code 1)"
fi
echo "=========================================="
