# iOS push notifications setup

Firebase project: **my-boss-app-38576**

---

## 1. Register iOS app in Firebase

1. Open [Firebase Console → Project settings](https://console.firebase.google.com/project/my-boss-app-38576/settings/general)
2. Click **Add app** → **iOS**
3. **Apple bundle ID:** `com.myboss.mybossMobile` (must match Xcode exactly)
4. App nickname: `MyBoss Mobile iOS` (optional)
5. Download **`GoogleService-Info.plist`**

---

## 2. Add plist to the project

Copy `GoogleService-Info.plist` to `ios/Runner/` and run `flutterfire configure` if you need to refresh `lib/firebase_options.dart`.

---

## 3. Upload APNs key (required for push delivery)

Firebase cannot send to iOS without an Apple Push Notification key.

1. [Apple Developer → Keys](https://developer.apple.com/account/resources/authkeys/list)
2. Create key → enable **Apple Push Notifications service (APNs)**
3. Download `.p8` file (once only — store safely)
4. Note **Key ID** and your **Team ID** (`8QRN4LKK2X` in this project)
5. Firebase Console → **Project settings** → **Cloud Messaging** → **Apple app configuration**
6. Upload `.p8`, enter Key ID + Team ID

---

## 4. Xcode capabilities (already in repo)

These are configured in code — verify in Xcode if push fails:

| Item | File |
|------|------|
| Push entitlement | `ios/Runner/Runner.entitlements` (`aps-environment: development`) |
| Background modes | `ios/Runner/Info.plist` (`remote-notification`, `fetch`) |
| APNs registration | `ios/Runner/AppDelegate.swift` |
| Bundle ID | `com.myboss.mybossMobile` |

Open `ios/Runner.xcworkspace` → **Signing & Capabilities** → confirm **Push Notifications** is enabled.

For **TestFlight / App Store**, change `aps-environment` to `production` in `Runner.entitlements`.

---

## 5. Run on simulator or device

**Simulator** (in-app notifications work; push delivery is limited):

```bash
./build-ios-demo.sh
```

**Physical iPhone** (recommended for real push):

```bash
./build-ios-demo.sh
# Select your connected iPhone when prompted
```

Login: `demo@orange.com` + OTP → allow notifications.

---

## 6. Test

1. Backend running (`myboss-platform` demo on `:8090`)
2. Admin → send notification to **All employees**
3. iPhone should receive push + in-app gallery entry

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Firebase not configured` | Add `GoogleService-Info.plist` under `ios/Runner/` |
| No APNs token | Use physical device; check Push capability in Xcode |
| Push not delivered | Upload APNs `.p8` to Firebase Cloud Messaging |
| `aps-environment` mismatch | Use `development` for debug builds, `production` for release |
| Token not in backend | Login on device; check `POST /users/:id/device-token` with `platform: ios` |

---

## Related

- [PUSH_FIREBASE_SETUP.md](../../myboss-platform/docs/PUSH_FIREBASE_SETUP.md) — full stack setup
- Android package: `com.myboss.myboss_mobile` (different from iOS bundle ID — intentional)
