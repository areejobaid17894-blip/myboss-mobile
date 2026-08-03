import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/onboarding_navigation.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';

/// Returns from squad create/join flows to the screen that opened them.
void popSquadFormationRoute(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  final user = getIt<SessionManager>().currentUser;
  if (user != null && OnboardingNavigation.isComplete(user)) {
    context.go('/my-squad');
    return;
  }

  context.go('/squad/hub');
}
