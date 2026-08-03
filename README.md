> Part of **my boss** multi-repo. See sibling `myboss-platform` for full-stack deploy.


# my boss app — Mobile App

Flutter employee app — BLoC + Clean Architecture.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| **Flutter** | **3.35.7** (pinned) | [FVM](https://fvm.app): `fvm install 3.35.7` or match `apps/mobile/.fvmrc` |
| **Dart** | **≥3.9.2** | Bundled with Flutter |
| **Android Studio** | Latest stable | For Android SDK + emulator (APK builds) |
| **Xcode** | 15+ | iOS builds only (macOS) |
| **Backend** | Running on :3001–3005 or gateway :8090 | See [`apps/backend/README.md`](../backend/README.md) |

---

## Files NOT in git — how to get them

| File / folder | In git? | How to obtain |
|---------------|---------|---------------|
| `.dart_tool/` | No | `fvm flutter pub get` |
| `build/` (APK, web) | No | `./build-local-android.sh` or `fvm flutter build web` |
| `android/local.properties` | No | Created by Android Studio (SDK path) |
| `android/gradlew`, `gradle-wrapper.jar` | Partial | Run `fvm flutter create .` in `apps/mobile` if missing, or open in Android Studio |
| `ios/Pods/` | No | `cd ios && pod install` |
| `lib/gen/` (generated l10n) | No | `fvm flutter gen-l10n` |
| `**/*.g.dart`, `*.freezed.dart` | No | `dart run build_runner build` (if using code gen) |
| `.env` (root) | No | Backend needs it — `cp .env.example .env` at repo root |
| `demo-public-url.txt` | No | `./infrastructure/scripts/start-demo-tunnel.sh` (see `demo-public-url.example.txt`) |
| Release **APK** | No | Build locally — see below |

**Safe in git:** `demo_credentials.dart` (demo test emails only, no secrets).

---

## Local development — start

```bash
cd apps/mobile
fvm flutter pub get
fvm flutter gen-l10n
```

Start backend first (repo root):

```bash
./infrastructure/scripts/deploy-demo-server.sh 127.0.0.1
# OR: cd apps/backend && npm run start:dev
```

Run app:

```bash
fvm flutter run --dart-define=DEMO_MODE=true
```

**Web (local):**

```bash
./run-local-web.sh          # serves on :8092
```

**Emulator + backend on host:**

```bash
fvm flutter run --dart-define=DEMO_MODE=true --dart-define=GATEWAY_ORIGIN=http://10.0.2.2:8090
```

---

## Build release APK (physical phone)

```bash
cd apps/mobile
API_HOST=192.168.1.9 ./build-local-android.sh
```

Output (not in git):

```
build/android-dist/myboss-demo-<YOUR-LAN-IP>.apk
```

Install: copy to phone or `adb install -r build/android-dist/myboss-demo-*.apk`

Requirements:
- Phone on same Wi‑Fi as demo server (`http://<LAN-IP>:8090`)
- Or tunnel running → app reads `demo-public-url.txt` at build time

---

## Build & deploy mobile web (demo gateway)

From **repo root**:

```bash
ALLOW_DEPLOY=1 ./infrastructure/scripts/deploy-mobile-web.sh
```

Opens: http://127.0.0.1:8090/app/

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

## Documentation

| Doc | Purpose |
|-----|---------|
| [`docs/mobile/ANDROID_STUDIO.md`](../../docs/mobile/ANDROID_STUDIO.md) | Full Android Studio guide |
| [`docs/EMPLOYEE_JOURNEY_COVERAGE.md`](../../docs/EMPLOYEE_JOURNEY_COVERAGE.md) | Feature matrix |
| [`docs/api/CHAT_API.md`](../../docs/api/CHAT_API.md) | Squad chat API |
