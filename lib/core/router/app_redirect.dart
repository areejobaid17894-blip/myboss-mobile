import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';

String? resolveAppRedirect(String location) {
  const authPaths = ['/sign-in', '/login', '/verify-otp', '/resolve'];
  if (authPaths.any((path) => location.startsWith(path))) return null;

  final session = getIt<SessionManager>();
  final user = session.currentUser;
  if (user == null) return '/sign-in';

  if (!OnboardingNavigation.isComplete(user)) {
    if (location.startsWith('/onboarding')) return null;
    return OnboardingNavigation.initialRoute(user);
  }

  return null;
}
