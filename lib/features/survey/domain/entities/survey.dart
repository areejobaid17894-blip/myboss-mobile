import 'package:equatable/equatable.dart';

/// Matches the survey-service `QuestionType` enum exactly (wire values).
abstract class QuestionType {
  static const rating = 'rating';
  static const singleChoice = 'single_choice';
  static const multiChoice = 'multi_choice';
  static const nps = 'nps';
  static const text = 'text';
  static const consentName = 'consent_name';
  static const consentNationalId = 'consent_national_id';
  static const consentPhone = 'consent_phone';
  static const consentCheckbox = 'consent_checkbox';
  static const signature = 'signature';
}

class QuestionOption extends Equatable {
  const QuestionOption({required this.id, required this.label});

  final String id;
  final String label;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, label];
}

class SurveyQuestion extends Equatable {
  const SurveyQuestion({
    required this.id,
    required this.order,
    required this.type,
    required this.title,
    required this.required,
    this.description,
    this.options,
    this.validation,
    this.section,
  });

  final String id;
  final int order;
  final String type;
  final String title;
  final String? description;
  final bool required;
  final List<QuestionOption>? options;
  final Map<String, dynamic>? validation;

  /// "feedback" | "consent"
  final String? section;

  bool get isConsentSection => section == 'consent';

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>?;
    return SurveyQuestion(
      id: json['id'] as String,
      order: json['order'] as int? ?? 0,
      type: json['type'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
      options: rawOptions?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>)).toList(),
      validation: json['validation'] as Map<String, dynamic>?,
      section: json['section'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, order, type, title, description, required, options, validation, section];
}

class DynamicSurvey extends Equatable {
  const DynamicSurvey({
    required this.id,
    required this.segment,
    required this.title,
    required this.isActive,
    required this.questions,
    this.description,
  });

  final String id;
  final String segment;
  final String title;
  final String? description;
  final bool isActive;
  final List<SurveyQuestion> questions;

  List<SurveyQuestion> get feedbackQuestions =>
      questions.where((q) => q.section != 'consent').toList()..sort((a, b) => a.order.compareTo(b.order));

  List<SurveyQuestion> get consentQuestions =>
      questions.where((q) => q.section == 'consent').toList()..sort((a, b) => a.order.compareTo(b.order));

  factory DynamicSurvey.fromJson(Map<String, dynamic> json) {
    return DynamicSurvey(
      id: json['id'] as String,
      segment: json['segment'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => SurveyQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, segment, title, description, isActive, questions];
}

class SquadProgress extends Equatable {
  const SquadProgress({
    required this.squadId,
    required this.completed,
    required this.target,
    required this.percentage,
  });

  final String squadId;
  final int completed;
  final int target;
  final num percentage;

  factory SquadProgress.fromJson(Map<String, dynamic> json) {
    return SquadProgress(
      squadId: json['squadId'] as String,
      completed: json['completed'] as int? ?? 0,
      target: json['target'] as int? ?? 50,
      percentage: json['percentage'] as num? ?? 0,
    );
  }

  @override
  List<Object?> get props => [squadId, completed, target, percentage];
}

class ReportPriority extends Equatable {
  const ReportPriority({required this.label, required this.count, required this.percentage});

  final String label;
  final int count;
  final num percentage;

  factory ReportPriority.fromJson(Map<String, dynamic> json) {
    return ReportPriority(
      label: json['label'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percentage: json['percentage'] as num? ?? 0,
    );
  }

  @override
  List<Object?> get props => [label, count, percentage];
}

class SurveyReport extends Equatable {
  const SurveyReport({
    required this.scope,
    required this.totalResponses,
    required this.avgSatisfaction,
    required this.surveysPerHour,
    required this.topPriorities,
  });

  final String scope;
  final int totalResponses;
  final num avgSatisfaction;
  final num surveysPerHour;
  final List<ReportPriority> topPriorities;

  factory SurveyReport.fromJson(Map<String, dynamic> json) {
    return SurveyReport(
      scope: json['scope'] as String? ?? '',
      totalResponses: json['totalResponses'] as int? ?? 0,
      avgSatisfaction: json['avgSatisfaction'] as num? ?? 0,
      surveysPerHour: json['surveysPerHour'] as num? ?? 0,
      topPriorities: (json['topPriorities'] as List<dynamic>? ?? [])
          .map((e) => ReportPriority.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [scope, totalResponses, avgSatisfaction, surveysPerHour, topPriorities];
}
