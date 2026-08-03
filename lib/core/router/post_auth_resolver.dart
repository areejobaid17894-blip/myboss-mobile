import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/user/domain/usecases/get_user_usecase.dart';

/// Resolves where a freshly authenticated user should land: onboarding (if
/// incomplete), the squad hub (onboarded but no squad yet), or the main
/// authenticated shell (home).
class PostAuthResolver {
  const PostAuthResolver();

  Future<String> resolve(String userId) async {
    final session = getIt<SessionManager>();

    final userResponse = await getIt<GetUserUseCase>().call(userId);
    if (userResponse.failure != null || userResponse.profile == null) {
      return '/sign-in';
    }

    final profile = userResponse.profile!;
    session.setUser(profile);

    if (!OnboardingNavigation.isComplete(profile)) {
      return OnboardingNavigation.initialRoute(profile);
    }

    final squadResponse = await getIt<ResolveUserSquadUseCase>().call(userId);
    if (squadResponse.squad != null) {
      session.setSquad(squadResponse.squad);
      return '/home';
    }

    return '/squad/hub';
  }
}
