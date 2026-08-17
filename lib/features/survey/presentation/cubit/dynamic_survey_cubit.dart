import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/survey/data/survey_draft_store.dart';
import 'package:myboss_mobile/features/survey/data/survey_schema_cache.dart';
import 'package:myboss_mobile/features/survey/domain/consent_field_validator.dart';
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
    this.savedOffline = false,
    this.fieldErrorCode,
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
  final bool savedOffline;

  /// Stable validation code for the current question (inline error).
  final String? fieldErrorCode;

  SurveyQuestion? get currentQuestion =>
      currentIndex >= 0 && currentIndex < orderedQuestions.length ? orderedQuestions[currentIndex] : null;

  bool get isLastQuestion => currentIndex == orderedQuestions.length - 1;
  bool get isFirstQuestion => currentIndex == 0;
  double get progress =>
      orderedQuestions.isEmpty ? 0 : (currentIndex + 1) / orderedQuestions.length;

  bool get hasAnswers => answers.values.any(ConsentFieldValidator.hasValue);

  bool get isIdentifiedSubmission {
    for (final question in orderedQuestions) {
      if (question.type == QuestionType.consentCheckbox) {
        return answers[question.id] == true;
      }
    }
    return false;
  }

  bool get canGoNext {
    final question = currentQuestion;
    if (question == null) return false;

    final value = answers[question.id];

    if (question.type == QuestionType.signature && isIdentifiedSubmission) {
      return ConsentFieldValidator.isValidSignature(value);
    }

    if (!question.required) return true;
    return ConsentFieldValidator.hasValue(value);
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
    bool? savedOffline,
    String? fieldErrorCode,
    bool clearFieldError = false,
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
      savedOffline: savedOffline ?? this.savedOffline,
      fieldErrorCode: clearFieldError ? null : (fieldErrorCode ?? this.fieldErrorCode),
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
        savedOffline,
        fieldErrorCode,
      ];
}

class DynamicSurveyCubit extends Cubit<DynamicSurveyState> {
  DynamicSurveyCubit(
    this._getActiveSurveyUseCase,
    this._submitResponseUseCase,
    this._getSquadProgressUseCase,
    this._draftStore,
    this._schemaCache,
  ) : super(const DynamicSurveyState());

  final GetActiveSurveyUseCase _getActiveSurveyUseCase;
  final SubmitSurveyResponseUseCase _submitResponseUseCase;
  final GetSquadProgressUseCase _getSquadProgressUseCase;
  final SurveyDraftStore _draftStore;
  final SurveySchemaCache _schemaCache;

  String _segment = '';
  String _userId = '';
  String _squadId = '';
  String _governorate = '';

  Future<void> load(
    String segment, {
    required String userId,
    required String squadId,
    required String governorate,
  }) async {
    _segment = segment;
    _userId = userId;
    _squadId = squadId;
    _governorate = governorate;

    emit(const DynamicSurveyState(isLoading: true));

    final progressResponse = await _getSquadProgressUseCase(squadId);
    final pendingForSegment = (await _draftStore.listPending()).any(
      (item) => item.userId == userId && item.segment == segment,
    );
    if (progressResponse.progress?.isTargetReached == true && !pendingForSegment) {
      emit(const DynamicSurveyState(error: ServerFailure(code: 'SURVEY_TARGET_REACHED')));
      return;
    }

    final cached = await _schemaCache.getBySegment(segment);
    if (cached != null && cached.questions.isNotEmpty) {
      await _presentSurvey(cached, userId: userId, segment: segment);
      return;
    }

    final response = await _getActiveSurveyUseCase(segment);
    if (response.survey != null && response.survey!.questions.isNotEmpty) {
      await _presentSurvey(response.survey!, userId: userId, segment: segment);
      return;
    }
    emit(DynamicSurveyState(error: response.failure ?? const CacheFailure()));
  }

  Future<void> _presentSurvey(
    DynamicSurvey survey, {
    required String userId,
    required String segment,
  }) async {
    final ordered = [...survey.feedbackQuestions, ...survey.consentQuestions];

    final draft = await _draftStore.loadProgress(
      userId: userId,
      segment: segment,
      surveyId: survey.id,
    );

    final restoredIndex = draft == null
        ? 0
        : draft.currentIndex.clamp(0, ordered.isEmpty ? 0 : ordered.length - 1);

    emit(DynamicSurveyState(
      survey: survey,
      orderedQuestions: ordered,
      answers: draft?.answers ?? const {},
      currentIndex: restoredIndex,
    ));
  }

  Future<void> saveDraftOnClose() async {
    if (state.submitSuccess) return;
    await _persistProgress();
  }

  void setAnswer(String questionId, dynamic value) {
    final updated = Map<String, dynamic>.from(state.answers);
    updated[questionId] = value;
    emit(state.copyWith(answers: updated, savedOffline: false, clearFieldError: true));
    _persistProgress();
  }

  void next() {
    final question = state.currentQuestion;
    if (question != null) {
      final code = ConsentFieldValidator.validateQuestion(
        question,
        state.answers[question.id],
        identified: false,
      );
      if (code != null) {
        emit(state.copyWith(fieldErrorCode: code));
        return;
      }
    }
    if (!state.canGoNext) return;
    if (state.isLastQuestion) return;
    emit(state.copyWith(currentIndex: state.currentIndex + 1, clearFieldError: true));
    _persistProgress();
  }

  void back() {
    if (state.isFirstQuestion) return;
    emit(state.copyWith(currentIndex: state.currentIndex - 1, clearFieldError: true));
    _persistProgress();
  }

  /// Validates identified consent fields before confirm/submit.
  /// Returns false and jumps to the first invalid field when validation fails.
  bool prepareSubmit() {
    if (state.survey == null) return false;

    if (state.isIdentifiedSubmission) {
      for (var i = 0; i < state.orderedQuestions.length; i++) {
        final question = state.orderedQuestions[i];
        if (!question.isConsentSection) continue;
        final code = ConsentFieldValidator.validateQuestion(
          question,
          state.answers[question.id],
          identified: true,
        );
        if (code != null) {
          emit(state.copyWith(
            currentIndex: i,
            fieldErrorCode: code,
            clearSubmitError: true,
          ));
          return false;
        }
      }
    } else {
      final question = state.currentQuestion;
      if (question != null) {
        final code = ConsentFieldValidator.validateQuestion(
          question,
          state.answers[question.id],
          identified: false,
        );
        if (code != null) {
          emit(state.copyWith(fieldErrorCode: code));
          return false;
        }
      }
    }

    emit(state.copyWith(clearFieldError: true));
    return true;
  }

  Future<void> submit({
    required String squadId,
    required String userId,
    required String governorate,
  }) async {
    if (state.survey == null) return;
    if (!prepareSubmit()) return;

    _squadId = squadId;
    _userId = userId;
    _governorate = governorate;

    emit(state.copyWith(isSubmitting: true, clearSubmitError: true, savedOffline: false));
    final answers = state.answers.entries.map((e) => {'questionId': e.key, 'value': e.value}).toList();
    final response = await _submitResponseUseCase(
      surveyId: state.survey!.id,
      squadId: squadId,
      userId: userId,
      governorate: governorate,
      answers: answers,
      anonymous: !state.isIdentifiedSubmission,
    );

    if (response.failure != null) {
      if (response.failure is NetworkFailure ||
          response.failure?.code == 'BACKEND_UNAVAILABLE') {
        await _saveOfflinePending();
        emit(state.copyWith(isSubmitting: false, savedOffline: true, clearSubmitError: true));
        return;
      }
      emit(state.copyWith(isSubmitting: false, submitError: response.failure));
      return;
    }

    await _clearLocal();
    emit(state.copyWith(isSubmitting: false, submitSuccess: true, savedOffline: false));
  }

  Future<void> _saveOfflinePending() async {
    if (state.survey == null || _userId.isEmpty) return;
    final pending = SurveyPendingSubmission(
      surveyId: state.survey!.id,
      segment: _segment,
      userId: _userId,
      squadId: _squadId,
      governorate: _governorate,
      answers: Map<String, dynamic>.from(state.answers),
      savedAt: DateTime.now(),
      anonymous: !state.isIdentifiedSubmission,
    );
    await _draftStore.enqueuePending(pending);
    await _draftStore.saveProgress(
      SurveyDraft(
        surveyId: state.survey!.id,
        segment: _segment,
        userId: _userId,
        squadId: _squadId,
        governorate: _governorate,
        answers: Map<String, dynamic>.from(state.answers),
        currentIndex: state.currentIndex,
        updatedAt: DateTime.now(),
        pendingSubmit: true,
      ),
    );
  }

  Future<void> _persistProgress() async {
    if (state.survey == null || _userId.isEmpty) return;
    await _draftStore.saveProgress(
      SurveyDraft(
        surveyId: state.survey!.id,
        segment: _segment,
        userId: _userId,
        squadId: _squadId,
        governorate: _governorate,
        answers: Map<String, dynamic>.from(state.answers),
        currentIndex: state.currentIndex,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _clearLocal() async {
    if (_userId.isEmpty || _segment.isEmpty) return;
    await _draftStore.clearProgress(userId: _userId, segment: _segment);
    if (state.survey != null) {
      await _draftStore.removePending(
        userId: _userId,
        surveyId: state.survey!.id,
        segment: _segment,
      );
    }
  }
}
