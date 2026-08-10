// Generated from Firebase project my-boss-app-38576 (Android + iOS).
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

  // iOS — synced from ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBW_f-DTDlixrj_pBfUa4fuvr0XQpr3eoE',
    appId: '1:142867649793:ios:8acdec20b145cc497cf700',
    messagingSenderId: '142867649793',
    projectId: 'my-boss-app-38576',
    storageBucket: 'my-boss-app-38576.firebasestorage.app',
    iosBundleId: 'com.myboss.mybossMobile',
  );
}
