import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;

/// Host that reaches the developer machine running backend services.
///
/// - Android emulator: `10.0.2.2` (alias for host loopback)
/// - iOS simulator / desktop: `localhost`
/// - Physical device: pass `--dart-define=API_HOST=<your-lan-ip>`
String resolveDevApiHost() {
  const override = String.fromEnvironment('API_HOST');
  if (override.isNotEmpty) return override;

  if (kIsWeb) return 'localhost';
  if (Platform.isAndroid) return '10.0.2.2';
  return 'localhost';
}

void logDevApiHostIfDebug(String host) {
  if (kDebugMode) {
    debugPrint('[MyBoss] Development API host: $host');
  }
}
