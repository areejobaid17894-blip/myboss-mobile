// Generated from Firebase project my-boss-app-38576 (Android).
// iOS credentials are placeholders until GoogleService-Info.plist is added.
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
    apiKey: 'AIzaSyDhfJyAkpkunSvuGI-4awk96JkU36jfGho',
    appId: '1:142867649793:android:3246efde837d83907cf700',
    messagingSenderId: '142867649793',
    projectId: 'my-boss-app-38576',
    storageBucket: 'my-boss-app-38576.firebasestorage.app',
  );

  // iOS push requires GoogleService-Info.plist + APNs key in Firebase Console.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME_IOS_FIREBASE',
    appId: '1:142867649793:ios:0000000000000000000000',
    messagingSenderId: '142867649793',
    projectId: 'my-boss-app-38576',
    storageBucket: 'my-boss-app-38576.firebasestorage.app',
    iosBundleId: 'com.myboss.mybossMobile',
  );
}
