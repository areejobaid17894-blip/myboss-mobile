import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_employee_settings_usecase.dart';
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
    this.suggestedMembers = const [],
    this.loadingSuggestions = false,
    this.invitingUserId,
    this.cancellingInviteId,
    this.remainingInviteSeats = 0,
    this.settings,
  });

  final bool isLoading;
  final Squad? squad;
  final SquadJoinStatus? joinStatus;
  final Failure? error;
  final String? respondingRequestId;
  final bool notInSquad;
  final bool isLeaving;
  final String? removingMemberId;
  final List<SuggestedSquadUser> suggestedMembers;
  final bool loadingSuggestions;
  final String? invitingUserId;
  final String? cancellingInviteId;
  final int remainingInviteSeats;
  final EmployeeSettings? settings;

  bool get hasPendingJoinRequest => joinStatus?.hasPendingJoinRequest ?? false;
  bool get isPendingInvite => joinStatus?.isPendingInvite ?? false;
  bool get employeeJoinClosed => settings?.isEmployeeJoinClosed() ?? false;

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
    List<SuggestedSquadUser>? suggestedMembers,
    bool? loadingSuggestions,
    String? invitingUserId,
    bool clearInviting = false,
    String? cancellingInviteId,
    bool clearCancellingInvite = false,
    int? remainingInviteSeats,
    EmployeeSettings? settings,
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
      suggestedMembers: suggestedMembers ?? this.suggestedMembers,
      loadingSuggestions: loadingSuggestions ?? this.loadingSuggestions,
      invitingUserId: clearInviting ? null : (invitingUserId ?? this.invitingUserId),
      cancellingInviteId: clearCancellingInvite ? null : (cancellingInviteId ?? this.cancellingInviteId),
      remainingInviteSeats: remainingInviteSeats ?? this.remainingInviteSeats,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        squad,
        joinStatus,
        error,
        respondingRequestId,
        notInSquad,
        isLeaving,
        removingMemberId,
        suggestedMembers,
        loadingSuggestions,
        invitingUserId,
        cancellingInviteId,
        remainingInviteSeats,
        settings,
      ];
}

class MySquadCubit extends Cubit<MySquadState> {
  MySquadCubit(
    this._resolveUserSquadUseCase,
    this._getJoinStatusUseCase,
    this._respondUseCase,
    this._listSuggestedMembersUseCase,
    this._inviteMemberUseCase,
    this._cancelInviteUseCase,
    this._respondToInviteUseCase,
    this._cancelMyJoinRequestUseCase,
    this._leaveSquadUseCase,
    this._transferLeadershipUseCase,
    this._removeMemberUseCase,
    this._getEmployeeSettingsUseCase,
  ) : super(const MySquadState());

  final ResolveUserSquadUseCase _resolveUserSquadUseCase;
  final GetJoinStatusUseCase _getJoinStatusUseCase;
  final RespondToJoinRequestUseCase _respondUseCase;
  final ListSuggestedMembersUseCase _listSuggestedMembersUseCase;
  final InviteMemberUseCase _inviteMemberUseCase;
  final CancelInviteUseCase _cancelInviteUseCase;
  final RespondToInviteUseCase _respondToInviteUseCase;
  final CancelMyJoinRequestUseCase _cancelMyJoinRequestUseCase;
  final LeaveSquadUseCase _leaveSquadUseCase;
  final TransferLeadershipUseCase _transferLeadershipUseCase;
  final RemoveSquadMemberUseCase _removeMemberUseCase;
  final GetEmployeeSettingsUseCase _getEmployeeSettingsUseCase;

  Future<void> load(String userId) async {
    final previousSquad = state.squad;
    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      notInSquad: false,
    ));

    final squadResponse = await _resolveUserSquadUseCase(userId);
    final settingsResponse = await _getEmployeeSettingsUseCase();
    if (squadResponse.squad != null) {
      emit(state.copyWith(
        isLoading: false,
        squad: squadResponse.squad,
        notInSquad: false,
        remainingInviteSeats: squadResponse.squad!.seatsLeft,
        settings: settingsResponse.settings,
      ));
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
      settings: settingsResponse.settings,
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
    emit(state.copyWith(
      clearResponding: true,
      squad: response.squad,
      remainingInviteSeats: response.squad?.seatsLeft ?? state.remainingInviteSeats,
    ));
  }

  Future<void> loadSuggestedMembers() async {
    final squad = state.squad;
    if (squad == null) return;
    emit(state.copyWith(loadingSuggestions: true, clearError: true));
    final response = await _listSuggestedMembersUseCase(squad.id);
    if (response.failure != null) {
      emit(state.copyWith(loadingSuggestions: false, error: response.failure));
      return;
    }
    emit(state.copyWith(
      loadingSuggestions: false,
      suggestedMembers: response.suggestions?.items ?? const [],
      remainingInviteSeats: response.suggestions?.remainingSeats ?? squad.seatsLeft,
    ));
  }

  Future<bool> inviteMember(String userId) async {
    final squad = state.squad;
    if (squad == null || state.remainingInviteSeats <= 0 || state.employeeJoinClosed) {
      return false;
    }
    emit(state.copyWith(invitingUserId: userId, clearError: true));
    final response = await _inviteMemberUseCase(squadId: squad.id, userId: userId);
    if (response.failure != null) {
      emit(state.copyWith(clearInviting: true, error: response.failure));
      return false;
    }
    emit(state.copyWith(clearInviting: true));
    final refreshed = await _resolveUserSquadUseCase(squad.leaderId);
    if (refreshed.squad != null) {
      emit(state.copyWith(
        squad: refreshed.squad,
        remainingInviteSeats: refreshed.squad!.seatsLeft,
      ));
    }
    await loadSuggestedMembers();
    return true;
  }

  Future<bool> cancelInvite(String requestId) async {
    final squad = state.squad;
    if (squad == null) return false;
    emit(state.copyWith(cancellingInviteId: requestId, clearError: true));
    final response = await _cancelInviteUseCase(squadId: squad.id, requestId: requestId);
    if (response.failure != null) {
      emit(state.copyWith(clearCancellingInvite: true, error: response.failure));
      return false;
    }
    emit(state.copyWith(
      clearCancellingInvite: true,
      squad: response.squad,
      remainingInviteSeats: response.squad?.seatsLeft ?? state.remainingInviteSeats + 1,
    ));
    await loadSuggestedMembers();
    return true;
  }

  Future<bool> respondToInvite({required bool accept}) async {
    final status = state.joinStatus;
    final squadId = status?.squadId;
    final requestId = status?.requestId;
    if (squadId == null || requestId == null) return false;
    if (accept && state.employeeJoinClosed) return false;
    emit(state.copyWith(respondingRequestId: requestId, clearError: true));
    final response = await _respondToInviteUseCase(
      squadId: squadId,
      requestId: requestId,
      accept: accept,
    );
    if (response.failure != null) {
      emit(state.copyWith(clearResponding: true, error: response.failure));
      return false;
    }
    if (accept) {
      emit(state.copyWith(
        clearResponding: true,
        squad: response.squad,
        notInSquad: false,
        clearJoinStatus: true,
      ));
    } else {
      emit(state.copyWith(
        clearResponding: true,
        clearSquad: true,
        notInSquad: true,
        clearJoinStatus: true,
      ));
    }
    return true;
  }

  Future<bool> cancelMyJoinRequest() async {
    if (!state.hasPendingJoinRequest || state.isPendingInvite) return false;
    emit(state.copyWith(respondingRequestId: state.joinStatus?.requestId ?? 'cancel', clearError: true));
    final response = await _cancelMyJoinRequestUseCase();
    if (response.failure != null) {
      emit(state.copyWith(clearResponding: true, error: response.failure));
      return false;
    }
    emit(state.copyWith(
      clearResponding: true,
      clearSquad: true,
      notInSquad: true,
      joinStatus: response.status ??
          const SquadJoinStatus(inSquad: false, hasPendingJoinRequest: false),
    ));
    return true;
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
    emit(state.copyWith(
      clearRemovingMember: true,
      squad: response.squad,
      remainingInviteSeats: response.squad?.seatsLeft ?? state.remainingInviteSeats,
    ));
    return true;
  }
}
