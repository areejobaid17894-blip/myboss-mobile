# myboss-mobile

Flutter employee app (Flutter **3.35.7**). **Not in Docker.** Talks to `http://<host>:3001/api/v1`.

API first: [INSTALL](https://github.com/areejobaid17894-blip/myboss-platform/-/blob/master/docs/INSTALL.md). Android Studio: [ANDROID_STUDIO](https://github.com/areejobaid17894-blip/myboss-platform/-/blob/master/docs/mobile/ANDROID_STUDIO.md).

## Setup

```bash
cd myboss-mobile
flutter pub get
flutter gen-l10n
```

Use Flutter **3.35.7**.

## Run

| Target | `API_HOST` |
|--------|------------|
| Web (same PC) | `localhost` |
| Android emulator | `10.0.2.2` |
| Phone (same Wi‑Fi) | laptop LAN IP |
| Phone (cellular) | public IP — only if `:3001` is published |

```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=API_HOST=localhost \
  --dart-define=API_PORT=3001 \
  --dart-define=DEMO_MODE=false
```

Release APK:

```bash
flutter build apk --release \
  --dart-define=ENV=development \
  --dart-define=API_HOST=<host> \
  --dart-define=API_PORT=3001 \
  --dart-define=DEMO_MODE=false \
  --dart-define=PUSH_ENABLED=true
```

OTP is emailed (Orange Maxit). Login → **Demo account** picks a seed email.

## Offline surveys

Open Home **once with internet** so services are cached. Offline, the user can open those services, fill them, and close them to save a **draft**. When the app is online again, queued drafts submit automatically.

Details and QA: [OFFLINE_SURVEYS](https://github.com/areejobaid17894-blip/myboss-platform/-/blob/master/docs/mobile/OFFLINE_SURVEYS.md).

---

*Orange — my boss app*
