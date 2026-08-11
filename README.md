# myboss-mobile

Flutter employee app — connects to **microservices directly** on ports **3001–3005**.

**Setup:** [`NEW_DEVICE_SETUP.md`](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/NEW_DEVICE_SETUP.md) · **URLs:** [`SERVICE_URLS.md`](https://github.com/areejobaid17894-blip/myboss-platform/blob/main/docs/deployment/SERVICE_URLS.md)

---

## Run (Android / iOS)

```bash
fvm use 3.35.7 && fvm flutter pub get && fvm flutter gen-l10n

# Emulator / same machine as Docker
fvm flutter run --dart-define=ENV=development --dart-define=DEMO_MODE=true

# Remote server / phone on same network
fvm flutter run --dart-define=API_HOST=10.6.210.45 --dart-define=ENV=demo --dart-define=DEMO_MODE=true
```

---

## Employee web app (browser)

```bash
# Local only
./run-local-web.sh                    # → http://127.0.0.1:8092

# LAN — other devices on same network
fvm flutter run -d web-server \
  --web-hostname=0.0.0.0 --web-port=8092 \
  --dart-define=API_HOST=<SERVER_IP> \
  --dart-define=ENV=demo \
  --dart-define=DEMO_MODE=true
# → http://<SERVER_IP>:8092
```

Login: `demo@orange.com` + OTP (auto-fills in demo mode)

---

## Build APK

```bash
./build-local-android.sh              # auto LAN IP
SERVER_HOST=<SERVER_IP> ./build-external-android.sh
```

`./build-apigee-android.sh` is deprecated — use `build-external-android.sh`.

---

## Service ports (on SERVER_HOST)

| Service | URL |
|---------|-----|
| Auth | `http://<HOST>:3001/api/v1` |
| User | `http://<HOST>:3002/api/v1` |
| Config | `http://<HOST>:3003/api/v1` |
| Squad | `http://<HOST>:3004/api/v1` |
| Survey | `http://<HOST>:3005/api/v1` |

---

*Orange — my boss app*
