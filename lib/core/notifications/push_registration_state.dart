/// Last push registration status for demo diagnostics UI.
class PushRegistrationState {
  PushRegistrationState._();

  static final PushRegistrationState instance = PushRegistrationState._();

  String? lastError;
  String? lastTokenPrefix;
  DateTime? lastRegisteredAt;
  bool lastAttemptSucceeded = false;

  void recordSuccess(String token) {
    lastError = null;
    lastTokenPrefix = token.length > 24 ? '${token.substring(0, 24)}…' : token;
    lastRegisteredAt = DateTime.now();
    lastAttemptSucceeded = true;
  }

  void recordFailure(String message) {
    lastError = message;
    lastAttemptSucceeded = false;
  }

  void recordLocalToken(String token) {
    lastTokenPrefix = token.length > 24 ? '${token.substring(0, 24)}…' : token;
  }
}
