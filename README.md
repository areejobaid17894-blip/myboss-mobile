# myboss-mobile

Flutter employee app — BLoC, clean architecture, Arabic/English l10n.

Connects to the backend through the demo gateway (`:8090`) or direct service ports during development. Demo mode auto-fills OTP so you can walk through flows quickly.

Full stack setup: [Multi-repo setup guide](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/MULTI_REPO_SETUP.md) (**myboss-platform** repo)

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter | **3.35.7** (pinned) | Use FVM: `brew install fvm && fvm install 3.35.7` |
| Dart | ≥3.9.2 | Bundled with Flutter |
| Android Studio | Latest | SDK + emulator for APK builds |
| Xcode | 15+ | iOS only (macOS) |
| Backend | :8090 or :3001–3005 | See `myboss-platform` or `myboss-backend` |

First time in this project:

```bash
cd myboss-mobile
fvm install 3.35.7
fvm use 3.35.7
fvm flutter pub get
fvm flutter gen-l10n
```

---

## Run on device or emulator

**1. Start the stack**

Full demo (recommended):

```bash
cd ../myboss-platform
cp .env.example .env
./scripts/deploy-demo-server.sh 127.0.0.1
ALLOW_DEPLOY=1 ./scripts/deploy-mobile-web.sh
```

Gateway: http://127.0.0.1:8090/app/

**2. Launch the app**

```bash
cd myboss-mobile
fvm flutter run --dart-define=DEMO_MODE=true
```

**Android emulator** (backend on host Mac):

```bash
fvm flutter run \
  --dart-define=DEMO_MODE=true \
  --dart-define=GATEWAY_ORIGIN=http://10.0.2.2:8090
```

**iOS simulator:**

```bash
fvm flutter run --dart-define=DEMO_MODE=true --dart-define=GATEWAY_ORIGIN=http://127.0.0.1:8090
```

---

## Web development (hot reload)

Separate from the deployed `/app/` bundle — runs on :8092 with API calls through the gateway:

```bash
./run-local-web.sh
```

Requires gateway on :8090.

---

## Build mobile web for demo gateway

From platform (builds this project automatically):

```bash
cd ../myboss-platform
ALLOW_DEPLOY=1 ./scripts/deploy-mobile-web.sh
```

Or build only:

```bash
./build-demo-web.sh
# Output: build/web — platform script deploys it to /app/
```

---

## Android APK

### External testers (mobile data)

For people outside your Wi‑Fi — bakes in the Cloudflare tunnel URL:

```bash
# 1. Tunnel running in myboss-platform
# 2. Then:
./build-external-android.sh
# → build/android-dist/myboss-demo-external.apk
```

Needs `myboss-platform/demo-public-url.txt` from `./scripts/start-demo-tunnel.sh`.

→ [Tunnel + external APK guide](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/deployment/DEMO_TUNNEL_AND_APK.md)

### Same Wi‑Fi (physical phone)

Phone must reach the gateway on your LAN or a tunnel URL.

```bash
# Start gateway first (myboss-platform)
./build-local-android.sh                    # auto-detects LAN IP
API_HOST=192.168.1.9 ./build-local-android.sh
API_HOST=10.0.2.2 ./build-local-android.sh  # Android emulator
```

Output: `build/android-dist/myboss-demo-<host>.apk`

Install: `adb install -r build/android-dist/myboss-demo-*.apk` or sideload on the device.

---

## Local configuration & generated files

| Path | Purpose | How |
|------|---------|-----|
| `.dart_tool/` | Flutter tooling | `fvm flutter pub get` |
| `build/` | APK and web output | Build scripts above |
| `lib/gen/` | Generated l10n | `fvm flutter gen-l10n` |
| `android/local.properties` | Android SDK path | Created by Android Studio |
| `demo-public-url.txt` | Tunnel URL for external APK | From platform tunnel script |
| `.env` | Optional env-based config | `cp .env.example .env` |

Demo test emails live in `demo_credentials.dart` — no real secrets there.

---

## Demo accounts

OTP auto-fills when `DEMO_MODE=true`.

| Email | Scenario |
|-------|----------|
| `demo@orange.com` | Full flow — squad member |
| `nisreen.a@orange.com` | Squad leader |
| `omar.t@orange.com` | No squad — gating tests |
| `laila.m@orange.com` | Incomplete onboarding |

After OTP: accept **Terms & conditions** to continue.

---

## Project structure

```
lib/
├── app/           App shell, theme, bottom nav
├── core/          DI, router, network, session
└── features/      auth, onboarding, squad, survey, gallery, chat, profile
```

---

## Build scripts

| Script | Purpose |
|--------|---------|
| `build-external-android.sh` | External testers — tunnel URL, mobile data |
| `build-demo-web.sh` | Flutter web for `/app/` on gateway |
| `build-local-android.sh` | Release APK for physical device |
| `build-demo-apk.sh` | APK with explicit server IP |
| `run-local-web.sh` | Hot-reload web dev on :8092 |
| `run-android-emulator.sh` | Emulator launch helper |

---

## Further reading

| Topic | Link |
|-------|------|
| Android Studio guide | [ANDROID_STUDIO.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/mobile/ANDROID_STUDIO.md) |
| Employee journey | [EMPLOYEE_JOURNEY_COVERAGE.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/EMPLOYEE_JOURNEY_COVERAGE.md) |
| Chat API | [CHAT_API.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/api/CHAT_API.md) |
| Full stack setup | [MULTI_REPO_SETUP.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/MULTI_REPO_SETUP.md) |
