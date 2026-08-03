import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';

class SurveyAnswerValidator {
  const SurveyAnswerValidator._();

  static String? validateQuestion(SurveyQuestion question, dynamic value) {
    if (!question.required) return null;

    if (value == null) return 'required';
    if (value is String && value.trim().isEmpty) return 'required';
    if (value is List && value.isEmpty) return 'required';
    if (value is bool && question.type == QuestionType.consentCheckbox && !value) {
      return 'required';
    }

    if (question.type == QuestionType.consentNationalId) {
      return _validateNationalId(value);
    }
    if (question.type == QuestionType.consentPhone) {
      return _validateJordanPhone(value);
    }
    if (question.type == QuestionType.signature) {
      return _validateSignature(value);
    }

    return null;
  }

  static String? _validateNationalId(dynamic value) {
    if (value is! String) return 'invalidNationalId';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'invalidNationalId';
    return null;
  }

  static String? _validateJordanPhone(dynamic value) {
    if (value is! String) return 'invalidPhone';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final valid = RegExp(r'^(9627[789]\d{7}|07[789]\d{7}|7[789]\d{7})$').hasMatch(digits);
    if (!valid) return 'invalidPhone';
    return null;
  }

  static String? _validateSignature(dynamic value) {
    if (value is! String || value.trim().isEmpty || value == 'signed') {
      return 'required';
    }
    return null;
  }
}
