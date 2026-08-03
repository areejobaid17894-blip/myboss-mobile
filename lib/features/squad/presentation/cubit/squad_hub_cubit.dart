import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
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
  const SquadHubLoaded({required this.stats, this.joinStatus});

  final SquadStats stats;
  final SquadJoinStatus? joinStatus;

  bool get hasPendingJoinRequest => joinStatus?.hasPendingJoinRequest ?? false;
  bool get isInSquad => joinStatus?.inSquad ?? false;
  /// Only block while a join request is awaiting leader approval.
  bool get canCreateOrJoin => !hasPendingJoinRequest;

  @override
  List<Object?> get props => [stats, joinStatus];
}

class SquadHubError extends SquadHubState {
  const SquadHubError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class SquadHubCubit extends Cubit<SquadHubState> {
  SquadHubCubit(this._getStatsUseCase, this._getJoinStatusUseCase) : super(const SquadHubInitial());

  final GetSquadStatsUseCase _getStatsUseCase;
  final GetJoinStatusUseCase _getJoinStatusUseCase;

  Future<void> load({required String userId}) async {
    emit(const SquadHubLoading());
    final statsResponse = await _getStatsUseCase();
    if (statsResponse.failure != null) {
      emit(SquadHubError(statsResponse.failure!));
      return;
    }

    final statusResponse = await _getJoinStatusUseCase(userId);
    emit(SquadHubLoaded(
      stats: statsResponse.stats!,
      joinStatus: statusResponse.status,
    ));
  }
}
