import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/router/app_router.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/auth/domain/repositories/auth_repository.dart';

bool _endingSession = false;

/// Clears tokens and in-memory session, then navigates to sign-in.
Future<void> endUserSession() async {
  if (_endingSession) return;
  _endingSession = true;
  try {
    final userId = getIt<SessionManager>().currentUser?.id;
    if (userId != null) {
      try {
        await revokePushTokens(userId);
      } catch (_) {}
    }
    try {
      await getIt<AuthRepository>().signOut();
    } catch (_) {
      // Best-effort remote sign-out; local session must still end.
    }
    getIt<DioClient>().clearAuthToken();
    getIt<SessionManager>().clear();
    appRouter.go('/sign-in');
  } finally {
    _endingSession = false;
  }
}

/// Auth endpoints that return 401 for bad OTP/credentials — never a reason to
/// wipe an in-progress login or bounce the user off the OTP screen.
bool isPreAuthUnauthorizedPath(String path) {
  final normalized = path.toLowerCase();
  return normalized.contains('/auth/sign-in') ||
      normalized.contains('/auth/admin-sign-in') ||
      normalized.contains('/auth/verify-2fa') ||
      normalized.contains('/auth/resend-otp') ||
      normalized.contains('/auth/resend');
}

/// Returns true when an HTTP 401 should terminate the local session.
///
/// Orange code 41 / `AUTH_INVALID_OTP` must NOT end the session — that is the
/// wrong-OTP response during verify-2fa. Ending the session there navigates to
/// `/sign-in` and looks like "OTP kicked me back to login".
bool shouldEndSessionForUnauthorized({required int? statusCode, String? errorCode}) {
  if (statusCode != 401) return false;
  if (errorCode == null || errorCode.isEmpty) return true;
  const sessionCodes = {
    'UNAUTHORIZED',
    'AUTH_SESSION_INVALID',
    'AUTH_SESSION_EXPIRED',
    'AUTH_INVALID_REFRESH_TOKEN',
  };
  if (sessionCodes.contains(errorCode)) return true;
  if (errorCode.startsWith('AUTH_SESSION')) return true;
  // Do not treat AUTH_INVALID_OTP / AUTH_INVALID_CREDENTIALS as session expiry.
  return false;
}

bool shouldEndSessionForOrangeCode(int? orangeCode) {
  if (orangeCode == null) return false;
  // 40 = missing credentials, 42 = expired/invalid session.
  // 41 = invalid OTP or credentials — keep the user on the auth flow.
  return orangeCode == 40 || orangeCode == 42;
}
