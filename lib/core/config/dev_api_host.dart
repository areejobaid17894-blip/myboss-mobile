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

  if (kIsWeb) {
    final webHost = Uri.base.host;
    if (webHost.isNotEmpty && webHost != 'localhost' && webHost != '127.0.0.1') {
      return webHost;
    }
    return 'localhost';
  }
  if (Platform.isAndroid) return '10.0.2.2';
  return 'localhost';
}

void logDevApiHostIfDebug(String host) {
  if (kDebugMode) {
    debugPrint('[MyBoss] Development API host: $host');
  }
}
