import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_logo.dart';
import 'package:myboss_mobile/features/onboarding/presentation/terms_acceptance_flow.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';

/// Blocking terms step in onboarding. Shown after OTP and on cold start when
/// the user has not yet accepted terms and conditions.
class TermsAcceptancePage extends StatefulWidget {
  const TermsAcceptancePage({super.key});

  @override
  State<TermsAcceptancePage> createState() => _TermsAcceptancePageState();
}

class _TermsAcceptancePageState extends State<TermsAcceptancePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptTerms());
  }

  Future<void> _promptTerms() async {
    final profile = getIt<SessionManager>().currentUser;
    if (!mounted || profile == null) {
      context.go('/sign-in');
      return;
    }

    if (profile.hasAcceptedTerms) {
      _continue(profile);
      return;
    }

    final acceptedProfile = await ensureTermsAccepted(context, profile);
    if (!mounted) return;
    if (acceptedProfile == null) return;

    _continue(acceptedProfile);
  }

  void _continue(UserProfile profile) {
    if (OnboardingNavigation.isComplete(profile)) {
      context.go('/resolve', extra: profile.id);
      return;
    }

    final next = OnboardingNavigation.routeAfterTerms(profile);
    context.go(next);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BossLogo(showTagline: false),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}
