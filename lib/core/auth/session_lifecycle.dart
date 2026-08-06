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

/// Returns true when an HTTP 401 should terminate the local session.
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
  return errorCode.startsWith('AUTH_SESSION') || errorCode.startsWith('AUTH_INVALID');
}

bool shouldEndSessionForOrangeCode(int? orangeCode) {
  if (orangeCode == null) return false;
  return orangeCode == 40 || orangeCode == 41 || orangeCode == 42;
}
