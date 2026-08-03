/// In-memory OTP session for native mobile (demo APK).
/// Web uses sessionStorage; mobile relies on router [syncOtpSessionStore] during navigation.
class OtpSessionStore {
  static OtpSessionData? _pending;

  static void save({
    required String sessionId,
    required String email,
    String? demoOtpCode,
  }) {
    _pending = OtpSessionData(
      sessionId: sessionId,
      email: email,
      demoOtpCode: demoOtpCode,
    );
  }

  static OtpSessionData? read() => _pending;

  static void clear() {
    _pending = null;
  }
}

class OtpSessionData {
  const OtpSessionData({
    required this.sessionId,
    required this.email,
    this.demoOtpCode,
  });

  final String sessionId;
  final String email;
  final String? demoOtpCode;
}
