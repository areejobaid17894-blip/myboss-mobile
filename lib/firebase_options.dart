// Generated from Firebase project my-customer-my-boss (Android + iOS).
//
// Build with push: --dart-define=PUSH_ENABLED=true

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Push is not enabled for web demo builds.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Push is not supported on this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrxc2Ngddxnsy0WrHLExWr8pDo0O5MvdM',
    appId: '1:418987594217:android:df43fb4766902c33affb78',
    messagingSenderId: '418987594217',
    projectId: 'my-customer-my-boss',
    storageBucket: 'my-customer-my-boss.firebasestorage.app',
  );

  // iOS — synced from ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8FINbRalZ4WVvt0gqFo2WiUk4ySUDYXE',
    appId: '1:418987594217:ios:631189970a237264affb78',
    messagingSenderId: '418987594217',
    projectId: 'my-customer-my-boss',
    storageBucket: 'my-customer-my-boss.firebasestorage.app',
    iosBundleId: 'com.myboss.mybossMobile',
  );
}
