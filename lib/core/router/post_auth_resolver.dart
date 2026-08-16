import 'dart:async';

import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/usecases/get_user_usecase.dart';

/// Resolves where a freshly authenticated user should land: onboarding (if
/// incomplete), the squad hub (onboarded but no squad yet), or the main
/// authenticated shell (home).
class PostAuthResolver {
  const PostAuthResolver();

  Future<String> resolve(String userId) async {
    final session = getIt<SessionManager>();
    final cachedProfile = session.currentUser;
    final cachedSquad = session.currentSquad;

    if (cachedProfile != null &&
        OnboardingNavigation.isComplete(cachedProfile) &&
        cachedSquad != null) {
      unawaited(_refreshInBackground(userId));
      return '/home';
    }

    final userResponse = await getIt<GetUserUseCase>().call(userId);
    final profile = userResponse.profile ?? cachedProfile;
    if (profile == null) {
      // Auth already succeeded; keep moving through onboarding instead of login.
      return '/onboarding/vest-size';
    }

    session.setUser(profile);

    if (!OnboardingNavigation.isComplete(profile)) {
      return OnboardingNavigation.initialRoute(profile);
    }

    final squadResponse = await getIt<ResolveUserSquadUseCase>().call(userId);
    if (squadResponse.squad != null) {
      session.setSquad(squadResponse.squad);
      return '/home';
    }

    if (cachedSquad != null) {
      session.setSquad(cachedSquad);
      return '/home';
    }

    return '/squad/hub';
  }

  static String routeFromCachedSession({
    required UserProfile? profile,
    required bool hasSquad,
  }) {
    if (profile == null) return '/onboarding/vest-size';
    if (!OnboardingNavigation.isComplete(profile)) {
      return OnboardingNavigation.initialRoute(profile);
    }
    return hasSquad ? '/home' : '/squad/hub';
  }

  Future<void> _refreshInBackground(String userId) async {
    try {
      final session = getIt<SessionManager>();
      final userResponse = await getIt<GetUserUseCase>().call(userId);
      final profile = userResponse.profile;
      if (profile != null) {
        session.setUser(profile);
      }
      final squadResponse = await getIt<ResolveUserSquadUseCase>().call(userId);
      if (squadResponse.squad != null) {
        session.setSquad(squadResponse.squad);
      }
    } catch (_) {}
  }
}
