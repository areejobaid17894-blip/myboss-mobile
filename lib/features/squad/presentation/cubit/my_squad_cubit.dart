import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';

class MySquadState extends Equatable {
  const MySquadState({
    this.isLoading = false,
    this.squad,
    this.joinStatus,
    this.error,
    this.respondingRequestId,
    this.notInSquad = false,
    this.isLeaving = false,
    this.removingMemberId,
  });

  final bool isLoading;
  final Squad? squad;
  final SquadJoinStatus? joinStatus;
  final Failure? error;
  final String? respondingRequestId;
  final bool notInSquad;
  final bool isLeaving;
  final String? removingMemberId;

  bool get hasPendingJoinRequest => joinStatus?.hasPendingJoinRequest ?? false;

  MySquadState copyWith({
    bool? isLoading,
    Squad? squad,
    bool clearSquad = false,
    SquadJoinStatus? joinStatus,
    bool clearJoinStatus = false,
    Failure? error,
    bool clearError = false,
    String? respondingRequestId,
    bool clearResponding = false,
    bool? notInSquad,
    bool? isLeaving,
    String? removingMemberId,
    bool clearRemovingMember = false,
  }) {
    return MySquadState(
      isLoading: isLoading ?? this.isLoading,
      squad: clearSquad ? null : (squad ?? this.squad),
      joinStatus: clearJoinStatus ? null : (joinStatus ?? this.joinStatus),
      error: clearError ? null : (error ?? this.error),
      respondingRequestId: clearResponding ? null : (respondingRequestId ?? this.respondingRequestId),
      notInSquad: notInSquad ?? this.notInSquad,
      isLeaving: isLeaving ?? this.isLeaving,
      removingMemberId: clearRemovingMember ? null : (removingMemberId ?? this.removingMemberId),
    );
  }

  @override
  List<Object?> get props => [isLoading, squad, joinStatus, error, respondingRequestId, notInSquad, isLeaving, removingMemberId];
}

class MySquadCubit extends Cubit<MySquadState> {
  MySquadCubit(
    this._resolveUserSquadUseCase,
    this._getJoinStatusUseCase,
    this._respondUseCase,
    this._leaveSquadUseCase,
    this._transferLeadershipUseCase,
    this._removeMemberUseCase,
  ) : super(const MySquadState());

  final ResolveUserSquadUseCase _resolveUserSquadUseCase;
  final GetJoinStatusUseCase _getJoinStatusUseCase;
  final RespondToJoinRequestUseCase _respondUseCase;
  final LeaveSquadUseCase _leaveSquadUseCase;
  final TransferLeadershipUseCase _transferLeadershipUseCase;
  final RemoveSquadMemberUseCase _removeMemberUseCase;

  Future<void> load(String userId) async {
    final previousSquad = state.squad;
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      notInSquad: false,
    ));

    final squadResponse = await _resolveUserSquadUseCase(userId);
    if (squadResponse.squad != null) {
      emit(state.copyWith(isLoading: false, squad: squadResponse.squad, notInSquad: false));
      return;
    }

    if (!squadResponse.confirmedNoSquad && previousSquad != null) {
      emit(state.copyWith(
        isLoading: false,
        squad: previousSquad,
        notInSquad: false,
        error: squadResponse.failure,
      ));
      return;
    }

    final statusResponse = await _getJoinStatusUseCase(userId);
    emit(state.copyWith(
      isLoading: false,
      clearSquad: true,
      notInSquad: true,
      joinStatus: statusResponse.status,
      error: squadResponse.failure,
    ));
  }

  Future<void> respond({
    required String requestId,
    required String leaderId,
    required bool accept,
  }) async {
    if (state.squad == null) return;
    emit(state.copyWith(respondingRequestId: requestId, clearError: true));
    final response = await _respondUseCase(
      squadId: state.squad!.id,
      requestId: requestId,
      leaderId: leaderId,
      accept: accept,
    );
    if (response.failure != null) {
      emit(state.copyWith(clearResponding: true, error: response.failure));
      return;
    }
    emit(state.copyWith(clearResponding: true, squad: response.squad));
  }

  Future<bool> leaveSquad({required String squadId, required String userId}) async {
    emit(state.copyWith(isLeaving: true, clearError: true));
    final response = await _leaveSquadUseCase(squadId: squadId, userId: userId);
    if (response.failure != null) {
      emit(state.copyWith(isLeaving: false, error: response.failure));
      return false;
    }
    emit(state.copyWith(isLeaving: false, clearSquad: true, notInSquad: true));
    return true;
  }

  Future<bool> transferAndLeave({
    required String squadId,
    required String leaderId,
    required String newLeaderId,
  }) async {
    emit(state.copyWith(isLeaving: true, clearError: true));
    final transfer = await _transferLeadershipUseCase(
      squadId: squadId,
      leaderId: leaderId,
      newLeaderId: newLeaderId,
    );
    if (transfer.failure != null) {
      emit(state.copyWith(isLeaving: false, error: transfer.failure));
      return false;
    }
    final leave = await _leaveSquadUseCase(squadId: squadId, userId: leaderId);
    if (leave.failure != null) {
      emit(state.copyWith(isLeaving: false, squad: transfer.squad, error: leave.failure));
      return false;
    }
    emit(state.copyWith(isLeaving: false, clearSquad: true, notInSquad: true));
    return true;
  }

  Future<bool> removeMember({
    required String squadId,
    required String leaderId,
    required String memberId,
  }) async {
    emit(state.copyWith(removingMemberId: memberId, clearError: true));
    final response = await _removeMemberUseCase(
      squadId: squadId,
      leaderId: leaderId,
      memberId: memberId,
    );
    if (response.failure != null) {
      emit(state.copyWith(clearRemovingMember: true, error: response.failure));
      return false;
    }
    emit(state.copyWith(clearRemovingMember: true, squad: response.squad));
    return true;
  }
}
