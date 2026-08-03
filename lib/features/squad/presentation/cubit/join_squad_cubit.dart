import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';

class JoinSquadState extends Equatable {
  const JoinSquadState({
    this.isLoading = false,
    this.allSquads = const [],
    this.searchQuery,
    this.governorateFilter,
    this.error,
    this.joiningSquadId,
    this.joinedRequest,
    this.joinError,
    this.pendingSquadId,
    this.pendingSquadName,
  });

  final bool isLoading;
  final List<PublicSquad> allSquads;
  final String? searchQuery;
  final String? governorateFilter;
  final Failure? error;
  final String? joiningSquadId;
  final SquadJoinRequest? joinedRequest;
  final Failure? joinError;
  final String? pendingSquadId;
  final String? pendingSquadName;

  List<PublicSquad> get squads {
    var results = allSquads;

    final governorate = (governorateFilter ?? '').trim();
    if (governorate.isNotEmpty) {
      final g = governorate.toLowerCase();
      results = results.where((s) => s.governorate.toLowerCase() == g).toList();
    }

    final q = (searchQuery ?? '').trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.squadCode.toLowerCase().contains(q) ||
            s.governorate.toLowerCase().contains(q);
      }).toList();
    }

    return results;
  }

  List<String> get availableGovernorates {
    final governorates = allSquads.map((s) => s.governorate).where((g) => g.trim().isNotEmpty).toSet().toList();
    governorates.sort();
    return governorates;
  }

  JoinSquadState copyWith({
    bool? isLoading,
    List<PublicSquad>? allSquads,
    String? searchQuery,
    bool clearSearchQuery = false,
    String? governorateFilter,
    bool clearGovernorateFilter = false,
    Failure? error,
    bool clearError = false,
    String? joiningSquadId,
    bool clearJoiningSquadId = false,
    SquadJoinRequest? joinedRequest,
    Failure? joinError,
    bool clearJoinError = false,
    String? pendingSquadId,
    String? pendingSquadName,
    bool clearPending = false,
  }) {
    return JoinSquadState(
      isLoading: isLoading ?? this.isLoading,
      allSquads: allSquads ?? this.allSquads,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      governorateFilter: clearGovernorateFilter ? null : (governorateFilter ?? this.governorateFilter),
      error: clearError ? null : (error ?? this.error),
      joiningSquadId: clearJoiningSquadId ? null : (joiningSquadId ?? this.joiningSquadId),
      joinedRequest: joinedRequest ?? this.joinedRequest,
      joinError: clearJoinError ? null : (joinError ?? this.joinError),
      pendingSquadId: clearPending ? null : (pendingSquadId ?? this.pendingSquadId),
      pendingSquadName: clearPending ? null : (pendingSquadName ?? this.pendingSquadName),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        allSquads,
        searchQuery,
        governorateFilter,
        error,
        joiningSquadId,
        joinedRequest,
        joinError,
        pendingSquadId,
        pendingSquadName,
      ];
}

class JoinSquadCubit extends Cubit<JoinSquadState> {
  JoinSquadCubit(
    this._listSquadsUseCase,
    this._joinSquadUseCase,
    this._getJoinStatusUseCase,
  ) : super(const JoinSquadState());

  final ListSquadsUseCase _listSquadsUseCase;
  final JoinSquadUseCase _joinSquadUseCase;
  final GetJoinStatusUseCase _getJoinStatusUseCase;

  Future<void> load({String? userId}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await getIt<DioClient>().restoreAuthTokenFromStorage();

    SquadJoinStatus? joinStatus;
    if (userId != null && userId.isNotEmpty) {
      final statusResponse = await _getJoinStatusUseCase(userId);
      joinStatus = statusResponse.status;
    }

    final response = await _listSquadsUseCase();
    if (response.failure != null) {
      emit(state.copyWith(isLoading: false, error: response.failure));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      allSquads: response.squads ?? const [],
      pendingSquadId: joinStatus?.hasPendingJoinRequest == true ? joinStatus?.squadId : null,
      pendingSquadName: joinStatus?.hasPendingJoinRequest == true ? joinStatus?.squadName : null,
    ));
  }

  void setSearchQuery(String? query) {
    emit(state.copyWith(
      searchQuery: (query ?? '').trim().isEmpty ? null : query?.trim(),
      clearSearchQuery: (query ?? '').trim().isEmpty,
    ));
  }

  void setGovernorateFilter(String? governorate) {
    emit(state.copyWith(
      governorateFilter: governorate,
      clearGovernorateFilter: governorate == null || governorate.isEmpty,
    ));
  }

  Future<void> join({
    required String squadId,
    required String userId,
    required String firstName,
    required String lastName,
    String? building,
  }) async {
    emit(state.copyWith(joiningSquadId: squadId, clearJoinError: true));
    final response = await _joinSquadUseCase(
      squadId: squadId,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      building: building,
    );
    if (response.failure != null) {
      emit(state.copyWith(clearJoiningSquadId: true, joinError: response.failure));
      return;
    }
    final squad = state.allSquads.where((s) => s.id == squadId).firstOrNull;
    emit(state.copyWith(
      clearJoiningSquadId: true,
      joinedRequest: response.request,
      pendingSquadId: squadId,
      pendingSquadName: squad?.name,
    ));
  }
}
