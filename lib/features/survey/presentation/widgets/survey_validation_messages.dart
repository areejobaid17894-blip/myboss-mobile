import 'package:myboss_mobile/core/localization/app_localizations.dart';

String localizedSurveyValidationMessage(AppLocalizations l10n, String? code) {
  return switch (code) {
    'required' => l10n.errorValidation,
    'invalidNationalId' => l10n.errorInvalidNationalId,
    'invalidPhone' => l10n.errorInvalidPhone,
    _ => l10n.errorValidation,
  };
}
