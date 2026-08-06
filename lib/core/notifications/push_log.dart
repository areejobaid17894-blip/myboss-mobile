import 'package:flutter/foundation.dart' show kDebugMode;

/// Logs push diagnostics in debug and demo release builds.
void pushLog(String message) {
  const demoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);
  if (kDebugMode || demoMode) {
    // ignore: avoid_print
    print('[Push] $message');
  }
}
