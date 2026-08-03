import 'dart:convert';
import 'dart:html' as html;

class OtpSessionStore {
  static const _storageKey = 'myboss_otp_session';

  static void save({
    required String sessionId,
    required String email,
    String? demoOtpCode,
  }) {
    final payload = jsonEncode({
      'sessionId': sessionId,
      'email': email,
      if (demoOtpCode != null) 'demoOtpCode': demoOtpCode,
    });
    html.window.sessionStorage[_storageKey] = payload;
  }

  static OtpSessionData? read() {
    final raw = html.window.sessionStorage[_storageKey];
    if (raw == null || raw.isEmpty) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final sessionId = data['sessionId'] as String? ?? '';
      final email = data['email'] as String? ?? '';
      if (sessionId.isEmpty || email.isEmpty) return null;

      return OtpSessionData(
        sessionId: sessionId,
        email: email,
        demoOtpCode: data['demoOtpCode'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static void clear() {
    html.window.sessionStorage.remove(_storageKey);
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
