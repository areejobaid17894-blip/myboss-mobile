import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/notifications/notification_unread_tracker.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/gallery/domain/usecases/gallery_usecases.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';
import 'package:myboss_mobile/features/survey/data/survey_offline_sync.dart';
import 'package:myboss_mobile/features/survey/data/survey_schema_cache.dart';
import 'package:myboss_mobile/features/survey/domain/entities/survey.dart';
import 'package:myboss_mobile/features/survey/domain/usecases/survey_usecases.dart';

class HomeState extends Equatable {
  const HomeState({
    this.isLoading = false,
    this.squad,
    this.joinStatus,
    this.progress,
    this.report,
    this.surveys = const [],
    this.unreadNotifications = 0,
    this.confirmedNoSquad = false,
    this.squadLoadFailed = false,
    this.error,
  });

  final bool isLoading;
  final Squad? squad;
  final SquadJoinStatus? joinStatus;
  final SquadProgress? progress;
  final SurveyReport? report;
  final List<DynamicSurvey> surveys;
  final int unreadNotifications;
  final bool confirmedNoSquad;
  final bool squadLoadFailed;
  final Failure? error;

  bool get hasActiveSquad => squad != null;
  bool get hasPendingJoinRequest => joinStatus?.hasPendingJoinRequest ?? false;
  bool get showNoSquadExperience => confirmedNoSquad && !hasActiveSquad;

  HomeState copyWith({
    bool? isLoading,
    Squad? squad,
    SquadJoinStatus? joinStatus,
    bool clearJoinStatus = false,
    SquadProgress? progress,
    SurveyReport? report,
    List<DynamicSurvey>? surveys,
    int? unreadNotifications,
    bool? confirmedNoSquad,
    bool? squadLoadFailed,
    Failure? error,
    bool clearError = false,
    bool clearSquad = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      squad: clearSquad ? null : (squad ?? this.squad),
      joinStatus: clearJoinStatus ? null : (joinStatus ?? this.joinStatus),
      progress: progress ?? this.progress,
      report: report ?? this.report,
      surveys: surveys ?? this.surveys,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      confirmedNoSquad: confirmedNoSquad ?? this.confirmedNoSquad,
      squadLoadFailed: squadLoadFailed ?? this.squadLoadFailed,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isLoading, squad, joinStatus, progress, report, surveys, unreadNotifications, confirmedNoSquad, squadLoadFailed, error];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._resolveUserSquadUseCase,
    this._getJoinStatusUseCase,
    this._getSquadProgressUseCase,
    this._getSurveyReportUseCase,
    this._listSurveysUseCase,
    this._getNotificationsForUserUseCase,
    this._unreadTracker,
    this._schemaCache,
  ) : super(const HomeState());

  final ResolveUserSquadUseCase _resolveUserSquadUseCase;
  final GetJoinStatusUseCase _getJoinStatusUseCase;
  final GetSquadProgressUseCase _getSquadProgressUseCase;
  final GetSurveyReportUseCase _getSurveyReportUseCase;
  final ListSurveysUseCase _listSurveysUseCase;
  final GetNotificationsForUserUseCase _getNotificationsForUserUseCase;
  final NotificationUnreadTracker _unreadTracker;
  final SurveySchemaCache _schemaCache;

  static const _fallbackSurveys = [
    DynamicSurvey(
      id: 'survey-consumer',
      segment: 'consumer',
      title: 'Customer visit survey',
      description: 'Feedback survey for consumer segment',
      isActive: true,
      questions: [],
    ),
    DynamicSurvey(
      id: 'survey-business',
      segment: 'business',
      title: 'Business Customer Survey',
      description: 'Feedback survey for business segment customers',
      isActive: true,
      questions: [],
    ),
    DynamicSurvey(
      id: 'survey-employee',
      segment: 'employee',
      title: 'Employee feedback loop',
      description: 'Post-event employee experience survey',
      isActive: true,
      questions: [],
    ),
  ];

  Future<void> load(String userId) async {
    final session = getIt<SessionManager>();
    final cachedSurveys = await _schemaCache.listAll();
    final cachedSquad = session.currentSquad;
    final hasOfflineStart = cachedSquad != null && cachedSurveys.any((survey) => survey.questions.isNotEmpty);

    emit(state.copyWith(
      isLoading: !hasOfflineStart,
      squad: cachedSquad,
      surveys: cachedSurveys.isNotEmpty ? cachedSurveys : state.surveys,
      confirmedNoSquad: cachedSquad == null && session.confirmedNoSquad,
      squadLoadFailed: false,
      clearError: true,
    ));

    if (userId.isNotEmpty) {
      unawaited(getIt<SurveyOfflineSync>().flushPending(userId: userId));
    }

    final surveysResponse = await _listSurveysUseCase();
    final surveys = surveysResponse.surveys.isNotEmpty
        ? surveysResponse.surveys
        : (cachedSurveys.isNotEmpty ? cachedSurveys : _fallbackSurveys);

    if (userId.isEmpty) {
      emit(state.copyWith(isLoading: false, surveys: surveys, clearSquad: true, clearJoinStatus: true));
      return;
    }

    final user = session.currentUser;

    final squadResponse = await _resolveUserSquadUseCase(userId);
    final squad = squadResponse.squad ?? cachedSquad;

    Future<int> fetchUnread({Squad? activeSquad}) async {
      final listResponse = await _getNotificationsForUserUseCase(
        userId: userId,
        onboardingCompleted: user?.onboardingCompleted,
        openToTravel: user?.openToTravel,
        isLeader: activeSquad?.isLeader(userId) ?? false,
      );
      if (listResponse.failure != null) return _unreadTracker.count;
      final count = listResponse.items.where((item) => !item.isRead).length;
      _unreadTracker.update(count);
      return count;
    }

    if (squad == null && squadResponse.confirmedNoSquad) {
      getIt<SessionManager>().markConfirmedNoSquad();
      final statusResponse = await _getJoinStatusUseCase(userId);
      final unreadCount = await fetchUnread();
      emit(state.copyWith(
        isLoading: false,
        surveys: surveys,
        clearSquad: true,
        joinStatus: statusResponse.status,
        unreadNotifications: unreadCount,
        confirmedNoSquad: true,
        squadLoadFailed: false,
      ));
      return;
    }

    if (squad == null) {
      final unreadCount = await fetchUnread();
      emit(state.copyWith(
        isLoading: false,
        surveys: surveys,
        error: squadResponse.failure,
        unreadNotifications: unreadCount,
        squadLoadFailed: squadResponse.failure != null,
        confirmedNoSquad: false,
      ));
      return;
    }

    final progressResponse = await _getSquadProgressUseCase(squad.id, target: squad.surveyTarget);
    final reportResponse = await _getSurveyReportUseCase('governorate', id: squad.governorate);
    final unreadCount = await fetchUnread(activeSquad: squad);

    getIt<SessionManager>().setSquad(squad);

    emit(state.copyWith(
      isLoading: false,
      squad: squad,
      clearJoinStatus: true,
      progress: progressResponse.progress,
      report: reportResponse.report,
      surveys: surveys,
      unreadNotifications: unreadCount,
      confirmedNoSquad: false,
      squadLoadFailed: false,
      error: squadResponse.failure,
    ));
  }
}
