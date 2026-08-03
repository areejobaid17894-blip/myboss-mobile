# myboss-mobile

Flutter employee app — BLoC + Clean Architecture.

Part of the **my boss** multi-repo layout — see [`../README.md`](../README.md) and sibling `myboss-platform` for full-stack deploy.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| **Flutter** | **3.35.7** (pinned) | [FVM](https://fvm.app): `brew install fvm && fvm install 3.35.7` |
| **Dart** | **≥3.9.2** | Bundled with Flutter |
| **Android Studio** | Latest stable | Android SDK + emulator (APK builds) |
| **Xcode** | 15+ | iOS builds only (macOS) |
| **Backend / gateway** | :8090 or :3001–3005 | See `myboss-platform` or `myboss-backend` |

Pin Flutter version (first time):

```bash
cd myboss-mobile
fvm install 3.35.7
fvm use 3.35.7
```

---

## Files NOT in git

| File / folder | In git? | How to obtain |
|---------------|---------|---------------|
| `.dart_tool/` | No | `fvm flutter pub get` |
| `build/` (APK, web) | No | `./build-local-android.sh` or `fvm flutter build web` |
| `android/local.properties` | No | Created by Android Studio (SDK path) |
| `ios/Pods/` | No | `cd ios && pod install` |
| `lib/gen/` (generated l10n) | No | `fvm flutter gen-l10n` |
| `**/*.g.dart`, `*.freezed.dart` | No | `dart run build_runner build` (if using code gen) |
| `demo-public-url.txt` | No | `../myboss-platform/scripts/start-demo-tunnel.sh` |

**Safe in git:** `demo_credentials.dart` (demo test emails only, no secrets)

---

## Run locally — step by step

### 1. Install Flutter dependencies

```bash
cd myboss-mobile
fvm flutter pub get
fvm flutter gen-l10n
```

### 2. Start backend / gateway

**Full demo (recommended):**

```bash
cd ../myboss-platform
cp .env.example .env
./scripts/deploy-demo-server.sh 127.0.0.1
ALLOW_DEPLOY=1 ./scripts/deploy-mobile-web.sh
```

Gateway: http://127.0.0.1:8090/app/

**Backend only (Node):**

```bash
cd ../myboss-backend
cp .env.example .env && npm install && npm run build -w @myboss/common && npm run start:dev
```

### 3. Run on device / emulator

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

### 4. Web dev (hot reload, separate from deployed /app/)

Requires gateway on :8090:

```bash
./run-local-web.sh
```

Opens: http://127.0.0.1:8092 (API calls go to gateway :8090)

---

## Build & deploy mobile web (demo gateway)

From **`myboss-platform`** (builds this repo automatically):

```bash
ALLOW_DEPLOY=1 ./scripts/deploy-mobile-web.sh
```

Or build only:

```bash
cd myboss-mobile
./build-demo-web.sh
# Output: build/web → deployed by platform script
```

Opens: http://127.0.0.1:8090/app/

---

### Step 3 — Build external APK (mobile data / remote testers)

```bash
cd myboss-mobile
./build-external-android.sh
# Output: build/android-dist/myboss-demo-external.apk
```

Requires `myboss-platform/demo-public-url.txt` from a running Cloudflare tunnel. Share APK by email — **not committed to git**.

See: [`../myboss-platform/docs/deployment/DEMO_TUNNEL_AND_APK.md`](../myboss-platform/docs/deployment/DEMO_TUNNEL_AND_APK.md)

---

## Build release APK (physical phone — same Wi‑Fi)

Phone must reach the demo gateway (`http://<server-ip>:8090`) on same Wi‑Fi, or use a Cloudflare tunnel URL.

### Step 1 — Start gateway on server/laptop

```bash
cd ../myboss-platform
./scripts/deploy-demo-server.sh 127.0.0.1
ALLOW_DEPLOY=1 ./scripts/deploy-mobile-web.sh
```

### Step 2 — Optional public tunnel

```bash
./scripts/start-demo-tunnel.sh
# Saves URL to demo-public-url.txt — APK picks this up automatically
```

### Step 3 — Build APK

```bash
cd myboss-mobile

# Auto-detects LAN IP (en0/en1):
./build-local-android.sh

# Or specify server IP:
API_HOST=192.168.1.9 ./build-local-android.sh

# Android emulator:
API_HOST=10.0.2.2 ./build-local-android.sh
```

Output (not in git):

```
build/android-dist/myboss-demo-<YOUR-LAN-IP>.apk
```

Install:

```bash
adb install -r build/android-dist/myboss-demo-*.apk
```

Or copy APK to phone and open it (enable "install from unknown sources").

---

## Deploy live (event / external testers)

On demo server:

```bash
cd /opt/myboss/myboss-platform
./scripts/deploy-demo-server.sh <SERVER_IP>
ALLOW_DEPLOY=1 ./scripts/deploy-mobile-web.sh
./scripts/start-demo-tunnel.sh   # optional public URL
```

Share:
- **Web:** `https://<tunnel>/app/` or `http://<SERVER_IP>:8090/app/`
- **APK:** Build on a dev machine with `API_HOST=<SERVER_IP> ./build-local-android.sh`

Full guide: [`../myboss-platform/docs/mobile/ANDROID_STUDIO.md`](../myboss-platform/docs/mobile/ANDROID_STUDIO.md)

---

## Demo test accounts

OTP auto-fills when `DEMO_MODE=true`.

| Email | Scenario |
|-------|----------|
| `demo@orange.com` | Full flow — squad member |
| `nisreen.a@orange.com` | Squad leader |
| `omar.t@orange.com` | No squad — gating tests |
| `laila.m@orange.com` | Incomplete onboarding |

After OTP: **Terms & conditions** popup (required before continuing).

---

## Project structure

```
lib/
├── app/           # App shell, theme, bottom nav
├── core/          # DI, router, network, session
└── features/      # auth, onboarding, squad, survey, gallery, chat, profile
```

---

## Build scripts

| Script | Purpose |
|--------|---------|
| `build-external-android.sh` | **External testers** — tunnel-first, mobile data |
| `build-demo-web.sh` | Flutter web for `/app/` on gateway |
| `build-local-android.sh` | Release APK for physical device |
| `build-demo-apk.sh` | APK with explicit server IP argument |
| `run-local-web.sh` | Hot-reload web dev on :8092 |
| `run-android-emulator.sh` | Helper for emulator launch |

---

## Documentation

| Doc | Path |
|-----|------|
| Android Studio guide | [`../myboss-platform/docs/mobile/ANDROID_STUDIO.md`](../myboss-platform/docs/mobile/ANDROID_STUDIO.md) |
| Employee journey | [`../myboss-platform/docs/EMPLOYEE_JOURNEY_COVERAGE.md`](../myboss-platform/docs/EMPLOYEE_JOURNEY_COVERAGE.md) |
| Chat API | [`../myboss-platform/docs/api/CHAT_API.md`](../myboss-platform/docs/api/CHAT_API.md) |
