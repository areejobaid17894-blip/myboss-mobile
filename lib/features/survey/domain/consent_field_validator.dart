import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';

/// Consent / identified-submission field rules (client-side).
///
/// Identified submission (consent checked) requires:
/// - non-empty name
/// - 10-digit national ID starting with 99
/// - valid Jordanian mobile
/// - signature
class ConsentFieldValidator {
  const ConsentFieldValidator._();

  /// Jordanian mobile: +962 7X… / 07X… / 7X… with operator 7, 8, or 9.
  static final RegExp _jordanMobile = RegExp(
    r'^(9627[789]\d{7}|07[789]\d{7}|7[789]\d{7})$',
  );

  /// 10 digits starting with 99.
  static final RegExp _nationalId = RegExp(r'^99\d{8}$');

  static bool hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is bool) return value;
    return true;
  }

  static String digitsOnly(dynamic value) =>
      (value?.toString() ?? '').replaceAll(RegExp(r'\D'), '');

  static bool isValidName(dynamic value) {
    if (value is! String) return false;
    return value.trim().isNotEmpty;
  }

  static bool isValidNationalId(dynamic value) {
    return _nationalId.hasMatch(digitsOnly(value));
  }

  static bool isValidJordanPhone(dynamic value) {
    return _jordanMobile.hasMatch(digitsOnly(value));
  }

  static bool isValidSignature(dynamic value) {
    if (value is! String) return false;
    final text = value.trim();
    return text.isNotEmpty && text != 'signed';
  }

  /// Returns a stable error code, or null when OK for this question.
  ///
  /// [identified] forces name / ID / phone / signature when consent is checked.
  /// When not identified, empty optional fields are allowed; non-empty values
  /// must still match format.
  static String? validateQuestion(
    SurveyQuestion question,
    dynamic value, {
    required bool identified,
  }) {
    switch (question.type) {
      case QuestionType.consentName:
        if (identified || hasValue(value)) {
          if (!isValidName(value)) return 'CONSENT_NAME_REQUIRED';
        }
        return null;
      case QuestionType.consentNationalId:
        if (identified) {
          if (!isValidNationalId(value)) return 'CONSENT_NATIONAL_ID_INVALID';
        } else if (hasValue(value) && !isValidNationalId(value)) {
          return 'CONSENT_NATIONAL_ID_INVALID';
        }
        return null;
      case QuestionType.consentPhone:
        if (identified) {
          if (!isValidJordanPhone(value)) return 'CONSENT_PHONE_INVALID';
        } else if (hasValue(value) && !isValidJordanPhone(value)) {
          return 'CONSENT_PHONE_INVALID';
        }
        return null;
      case QuestionType.consentCheckbox:
        return null;
      case QuestionType.signature:
        if (identified && !isValidSignature(value)) {
          return 'CONSENT_SIGNATURE_REQUIRED';
        }
        return null;
      default:
        if (question.required && !hasValue(value)) {
          return 'VALIDATION_FAILED';
        }
        return null;
    }
  }
}
