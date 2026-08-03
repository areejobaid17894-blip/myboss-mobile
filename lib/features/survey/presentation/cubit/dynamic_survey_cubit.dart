import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/domain/usecases/survey_usecases.dart';

class DynamicSurveyState extends Equatable {
  const DynamicSurveyState({
    this.isLoading = false,
    this.survey,
    this.orderedQuestions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.error,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
  });

  final bool isLoading;
  final DynamicSurvey? survey;
  final List<SurveyQuestion> orderedQuestions;
  final int currentIndex;
  final Map<String, dynamic> answers;
  final Failure? error;
  final bool isSubmitting;
  final Failure? submitError;
  final bool submitSuccess;

  SurveyQuestion? get currentQuestion =>
      currentIndex >= 0 && currentIndex < orderedQuestions.length ? orderedQuestions[currentIndex] : null;

  bool get isLastQuestion => currentIndex == orderedQuestions.length - 1;
  bool get isFirstQuestion => currentIndex == 0;
  double get progress =>
      orderedQuestions.isEmpty ? 0 : (currentIndex + 1) / orderedQuestions.length;

  bool get canGoNext {
    final question = currentQuestion;
    if (question == null) return false;
    if (!question.required) return true;
    final value = answers[question.id];
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  DynamicSurveyState copyWith({
    bool? isLoading,
    DynamicSurvey? survey,
    List<SurveyQuestion>? orderedQuestions,
    int? currentIndex,
    Map<String, dynamic>? answers,
    Failure? error,
    bool clearError = false,
    bool? isSubmitting,
    Failure? submitError,
    bool clearSubmitError = false,
    bool? submitSuccess,
  }) {
    return DynamicSurveyState(
      isLoading: isLoading ?? this.isLoading,
      survey: survey ?? this.survey,
      orderedQuestions: orderedQuestions ?? this.orderedQuestions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      error: clearError ? null : (error ?? this.error),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        survey,
        orderedQuestions,
        currentIndex,
        answers,
        error,
        isSubmitting,
        submitError,
        submitSuccess,
      ];
}

class DynamicSurveyCubit extends Cubit<DynamicSurveyState> {
  DynamicSurveyCubit(this._getActiveSurveyUseCase, this._submitResponseUseCase)
      : super(const DynamicSurveyState());

  final GetActiveSurveyUseCase _getActiveSurveyUseCase;
  final SubmitSurveyResponseUseCase _submitResponseUseCase;

  Future<void> load(String segment) async {
    emit(const DynamicSurveyState(isLoading: true));
    final response = await _getActiveSurveyUseCase(segment);
    if (response.failure != null) {
      emit(DynamicSurveyState(error: response.failure));
      return;
    }
    final survey = response.survey!;
    final ordered = [...survey.feedbackQuestions, ...survey.consentQuestions];
    emit(DynamicSurveyState(survey: survey, orderedQuestions: ordered));
  }

  void setAnswer(String questionId, dynamic value) {
    final updated = Map<String, dynamic>.from(state.answers);
    updated[questionId] = value;
    emit(state.copyWith(answers: updated));
  }

  void next() {
    if (!state.canGoNext) return;
    if (state.isLastQuestion) return;
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  void back() {
    if (state.isFirstQuestion) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  Future<void> submit({
    required String squadId,
    required String userId,
    required String governorate,
  }) async {
    if (state.survey == null) return;
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    final answers = state.answers.entries.map((e) => {'questionId': e.key, 'value': e.value}).toList();
    final response = await _submitResponseUseCase(
      surveyId: state.survey!.id,
      squadId: squadId,
      userId: userId,
      governorate: governorate,
      answers: answers,
    );
    if (response.failure != null) {
      emit(state.copyWith(isSubmitting: false, submitError: response.failure));
      return;
    }
    emit(state.copyWith(isSubmitting: false, submitSuccess: true));
  }
}
