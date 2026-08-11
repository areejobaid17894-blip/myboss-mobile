# myboss-mobile

Flutter employee app — BLoC, clean architecture, Arabic/English.

Connects through **Orange Apigee** (`https://api-demo.orange.com`) in demo/production. Local dev uses direct ports via `ENV=development`.

**Setup:** [`NEW_DEVICE_SETUP.md`](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/NEW_DEVICE_SETUP.md) · **URLs:** [`APIGEE_CLIENT_URLS.md`](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/deployment/APIGEE_CLIENT_URLS.md)

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | **3.35.7** (FVM) |
| Android Studio | Latest (emulator + APK) |
| Xcode | 15+ (iOS, macOS only) |

```bash
cd myboss-mobile
fvm install 3.35.7 && fvm use 3.35.7
fvm flutter pub get && fvm flutter gen-l10n
```

---

## Run on emulator or device

**Apigee (recommended):**

```bash
fvm flutter run \
  --dart-define=GATEWAY_ORIGIN=https://api-demo.orange.com \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE=true
```

**Local backend (Docker on same machine):**

```bash
# Start backend first: myboss-platform/scripts/deploy-demo-server.sh
fvm flutter run --dart-define=ENV=development --dart-define=DEMO_MODE=true
# Emulator uses 10.0.2.2 for host ports
```

**Physical device (same Wi‑Fi):**

```bash
fvm flutter run \
  --dart-define=ENV=development \
  --dart-define=DEMO_MODE=true \
  --dart-define=GATEWAY_ORIGIN=http://<YOUR_LAN_IP>:3001
```

---

## Web development (hot reload)

```bash
./run-local-web.sh
# Apigee by default; USE_DIRECT_PORTS=true for local Docker
```

---

## Android APK

| Script | Use case |
|--------|----------|
| `./build-apigee-android.sh` | **Recommended** — testers on mobile data |
| `./build-external-android.sh` | Same (Apigee default) |
| `./build-local-android.sh` | Same Wi‑Fi as demo server |
| `./build-demo-apk.sh` | Explicit server IP |

Output: `build/android-dist/*.apk`  
Install: `adb install -r build/android-dist/myboss-*.apk`

---

## iOS

```bash
./build-ios-demo.sh
# Push setup: ios/Runner/IOS_PUSH_SETUP.md
```

---

## Build scripts

| Script | Purpose |
|--------|---------|
| `build-apigee-android.sh` | Apigee demo APK |
| `build-local-android.sh` | LAN APK |
| `build-external-android.sh` | Apigee APK (alias) |
| `run-local-web.sh` | Hot-reload web dev |
| `build-ios-demo.sh` | iOS demo build |
| `run-android-emulator.sh` | Emulator helper |
| `scripts/setup-ios-firebase.sh` | iOS Firebase plist |

---

## Push notifications

1. `myboss-platform/secrets/fcm-service-account.json`
2. `FCM_ENABLED=true` in platform `.env`, redeploy Docker
3. Build APK with push-enabled scripts
4. Physical device + allow notifications

→ [PUSH_FIREBASE_SETUP.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/PUSH_FIREBASE_SETUP.md)

---

## Demo accounts

OTP auto-fills when `DEMO_MODE=true`.

| Email | Scenario |
|-------|----------|
| `demo@orange.com` | Full flow — squad member |
| `nisreen.a@orange.com` | Squad leader |
| `omar.t@orange.com` | No squad |
| `laila.m@orange.com` | Incomplete onboarding |

Accept **Terms & conditions** after OTP.

---

## Further reading

| Topic | Link |
|-------|------|
| New device setup | [NEW_DEVICE_SETUP.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/NEW_DEVICE_SETUP.md) |
| Android Studio | [ANDROID_STUDIO.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/mobile/ANDROID_STUDIO.md) |
| Employee journey | [EMPLOYEE_JOURNEY_COVERAGE.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/EMPLOYEE_JOURNEY_COVERAGE.md) |
| Chat API | [CHAT_API.md](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/api/CHAT_API.md) |
