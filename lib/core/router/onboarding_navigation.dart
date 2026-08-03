import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';

/// Routes users through vest/building onboarding only when profile data is missing.
class OnboardingNavigation {
  const OnboardingNavigation._();

  static bool hasAcceptedTerms(UserProfile profile) => profile.hasAcceptedTerms;

  static bool hasVest(UserProfile profile) => (profile.vestSize ?? '').trim().isNotEmpty;

  static bool hasLocation(UserProfile profile) {
    final buildingId = (profile.buildingId ?? '').trim();
    final governorate = (profile.governorate ?? '').trim();
    return buildingId.isNotEmpty || governorate.isNotEmpty;
  }

  static bool isComplete(UserProfile profile) {
    if (!hasAcceptedTerms(profile)) return false;
    if (profile.onboardingCompleted) return true;
    return hasVest(profile) && hasLocation(profile);
  }

  static String initialRoute(UserProfile profile) {
    if (!hasAcceptedTerms(profile)) return '/onboarding/terms';
    return routeAfterTerms(profile);
  }

  static String routeAfterTerms(UserProfile profile) {
    if (hasVest(profile)) return '/onboarding/building';
    return '/onboarding/vest-size';
  }
}
