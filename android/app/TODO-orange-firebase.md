# TODO(orange-firebase): Orange Firebase — Android

**No Firebase project was created in this repo.** The file `google-services.json` is a **placeholder only**.

When Orange IT provisions the project:

1. Open [Firebase Console](https://console.firebase.google.com/) with the **Orange Google account**
2. Select (or create) the Orange `my boss` project
3. Register Android app: `com.myboss.myboss_mobile`
4. Download **`google-services.json`** and **replace** this folder’s file
5. Run `flutterfire configure` in `myboss-mobile/` (updates `lib/firebase_options.dart`)

Do not commit the real `google-services.json` if Orange policy forbids it — use CI secrets instead.
