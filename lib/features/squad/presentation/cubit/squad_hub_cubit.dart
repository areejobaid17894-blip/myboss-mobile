import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_employee_settings_usecase.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';

sealed class SquadHubState extends Equatable {
  const SquadHubState();
  @override
  List<Object?> get props => [];
}

class SquadHubInitial extends SquadHubState {
  const SquadHubInitial();
}

class SquadHubLoading extends SquadHubState {
  const SquadHubLoading();
}

class SquadHubLoaded extends SquadHubState {
  const SquadHubLoaded({
    required this.stats,
    this.joinStatus,
    this.settings,
    this.isRespondingInvite = false,
    this.error,
  });

  final SquadStats stats;
  final SquadJoinStatus? joinStatus;
  final EmployeeSettings? settings;
  final bool isRespondingInvite;
  final Failure? error;

  bool get hasPendingJoinRequest => joinStatus?.hasPendingJoinRequest ?? false;
  bool get isPendingInvite => joinStatus?.isPendingInvite ?? false;
  bool get isInSquad => joinStatus?.inSquad ?? false;
  bool get employeeJoinClosed => settings?.isEmployeeJoinClosed() ?? false;
  bool get canCreateOrJoin => !hasPendingJoinRequest && !employeeJoinClosed;

  @override
  List<Object?> get props => [stats, joinStatus, settings, isRespondingInvite, error];
}

class SquadHubError extends SquadHubState {
  const SquadHubError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class SquadHubCubit extends Cubit<SquadHubState> {
  SquadHubCubit(
    this._getStatsUseCase,
    this._getJoinStatusUseCase,
    this._respondToInviteUseCase,
    this._getEmployeeSettingsUseCase,
  ) : super(const SquadHubInitial());

  final GetSquadStatsUseCase _getStatsUseCase;
  final GetJoinStatusUseCase _getJoinStatusUseCase;
  final RespondToInviteUseCase _respondToInviteUseCase;
  final GetEmployeeSettingsUseCase _getEmployeeSettingsUseCase;

  Future<void> load({required String userId}) async {
    emit(const SquadHubLoading());
    final statsResponse = await _getStatsUseCase();
    if (statsResponse.failure != null) {
      emit(SquadHubError(statsResponse.failure!));
      return;
    }

    final statusResponse = await _getJoinStatusUseCase(userId);
    final settingsResponse = await _getEmployeeSettingsUseCase();
    emit(SquadHubLoaded(
      stats: statsResponse.stats!,
      joinStatus: statusResponse.status,
      settings: settingsResponse.settings,
    ));
  }

  Future<bool> respondToInvite({required bool accept}) async {
    final current = state;
    if (current is! SquadHubLoaded) return false;
    final squadId = current.joinStatus?.squadId;
    final requestId = current.joinStatus?.requestId;
    if (squadId == null || requestId == null) return false;
    if (accept && current.employeeJoinClosed) return false;

    emit(SquadHubLoaded(
      stats: current.stats,
      joinStatus: current.joinStatus,
      settings: current.settings,
      isRespondingInvite: true,
    ));
    final response = await _respondToInviteUseCase(
      squadId: squadId,
      requestId: requestId,
      accept: accept,
    );
    if (response.failure != null) {
      emit(SquadHubLoaded(
        stats: current.stats,
        joinStatus: current.joinStatus,
        settings: current.settings,
        error: response.failure,
      ));
      return false;
    }
    if (accept) {
      emit(SquadHubLoaded(
        stats: current.stats,
        settings: current.settings,
        joinStatus: SquadJoinStatus(
          inSquad: true,
          hasPendingJoinRequest: false,
          squadId: squadId,
          squadName: current.joinStatus?.squadName,
        ),
      ));
    } else {
      emit(SquadHubLoaded(
        stats: current.stats,
        settings: current.settings,
        joinStatus: const SquadJoinStatus(inSquad: false, hasPendingJoinRequest: false),
      ));
    }
    return true;
  }
}
