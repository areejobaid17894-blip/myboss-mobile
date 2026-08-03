import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';

/// Maps backend [Failure.code] values to localized user-facing messages.
/// Never show raw server messages in UI — codes are the stable contract.
String localizedFailureMessage(AppLocalizations l10n, Failure failure) {
  if (failure is NetworkFailure) {
    return l10n.errorNetwork;
  }

  return switch (failure.code) {
    'AUTH_INVALID_OTP' => l10n.errorAuthInvalidOtp,
    'AUTH_SESSION_INVALID' => l10n.errorAuthSessionInvalid,
    'AUTH_SESSION_EXPIRED' => l10n.errorAuthSessionExpired,
    'AUTH_INVALID_REFRESH_TOKEN' => l10n.errorAuthSessionExpired,
    'AUTH_INVALID_DOMAIN' => l10n.errorInvalidDomain,
    'AUTH_NOT_ELIGIBLE' => l10n.errorNotEligible,
    'UNAUTHORIZED' => l10n.errorUnauthorized,
    'FORBIDDEN' => l10n.errorForbidden,
    'NOT_FOUND' => l10n.errorNotFound,
    'VALIDATION_FAILED' => l10n.errorValidation,
    'USER_NOT_FOUND' => l10n.errorUserNotFound,
    'USER_PROFILE_EDIT_LIMIT' => l10n.errorProfileEditLimit,
    'USER_PROFILE_EDIT_OUTSIDE_WINDOW' => l10n.errorProfileEditOutsideWindow,
    'CONFIG_NOT_FOUND' => l10n.errorConfigNotFound,
    'BUILDING_NOT_FOUND' => l10n.errorBuildingNotFound,
    'SQUAD_NOT_FOUND' => l10n.errorSquadNotFound,
    'SQUAD_LIMIT_REACHED' => l10n.errorSquadLimitReached,
    'SQUAD_NAME_TAKEN' => l10n.errorSquadNameTaken,
    'SQUAD_ALREADY_MEMBER' => l10n.errorSquadAlreadyMember,
    'SQUAD_FULL' => l10n.errorSquadFull,
    'SQUAD_JOIN_REQUEST_EXISTS' => l10n.errorSquadJoinRequestExists,
    'SQUAD_JOIN_REQUEST_NOT_FOUND' => l10n.errorSquadJoinRequestNotFound,
    'SQUAD_LEADER_ONLY' => l10n.errorSquadLeaderOnly,
    'SQUAD_LEADER_CANNOT_LEAVE' => l10n.errorSquadLeaderCannotLeave,
    'SQUAD_LEADER_CANNOT_REMOVE_SELF' => l10n.errorSquadLeaderCannotRemoveSelf,
    'SQUAD_MEMBER_NOT_FOUND' => l10n.errorSquadMemberNotFound,
    'SURVEY_NOT_FOUND' => l10n.errorSurveyNotFound,
    'SURVEY_SEGMENT_NOT_FOUND' => l10n.errorSurveySegmentNotFound,
    'GALLERY_UPLOAD_LIMIT' => l10n.errorGalleryUploadLimit,
    'BACKEND_UNAVAILABLE' => l10n.errorBackendUnavailable,
    'INTERNAL_ERROR' => l10n.errorGeneric,
    _ => l10n.errorGeneric,
  };
}
