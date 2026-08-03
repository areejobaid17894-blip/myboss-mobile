import 'package:flutter/material.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/onboarding/presentation/widgets/terms_acceptance_dialog.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/usecases/get_user_usecase.dart';

/// Ensures the user has accepted terms before continuing onboarding.
/// Returns the updated profile when terms are accepted, or null otherwise.
Future<UserProfile?> ensureTermsAccepted(BuildContext context, UserProfile profile) async {
  if (profile.hasAcceptedTerms) return profile;

  final accepted = await showTermsAcceptanceDialog(context, userId: profile.id);
  if (!context.mounted || accepted != true) return null;

  final updated = getIt<SessionManager>().currentUser;
  if (updated != null && updated.hasAcceptedTerms) return updated;

  final response = await getIt<GetUserUseCase>().call(profile.id);
  if (!context.mounted || response.profile == null || !response.profile!.hasAcceptedTerms) {
    return null;
  }

  getIt<SessionManager>().setUser(response.profile!);
  return response.profile;
}
