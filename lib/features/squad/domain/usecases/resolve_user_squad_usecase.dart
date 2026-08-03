import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';

/// Resolves the active squad without wiping session state on transient API errors.
class ResolveUserSquadUseCase {
  const ResolveUserSquadUseCase(
    this._getMySquadUseCase,
    this._getSquadUseCase,
    this._session,
  );

  final GetMySquadUseCase _getMySquadUseCase;
  final GetSquadUseCase _getSquadUseCase;
  final SessionManager _session;

  Future<({Failure? failure, Squad? squad, bool confirmedNoSquad})> call(String userId) async {
    final profileSquadId = _session.currentUser?.squadId;
    final cached = _session.currentSquad;

    final myResponse = await _getMySquadUseCase(userId);
    if (myResponse.squad != null) {
      _session.setSquad(myResponse.squad);
      return (failure: null, squad: myResponse.squad, confirmedNoSquad: false);
    }

    if (myResponse.failure != null) {
      if (cached != null) {
        return (failure: myResponse.failure, squad: cached, confirmedNoSquad: false);
      }
      final fallback = await _loadSquadByProfileId(profileSquadId);
      if (fallback != null) {
        _session.setSquad(fallback);
        return (failure: myResponse.failure, squad: fallback, confirmedNoSquad: false);
      }
      return (failure: myResponse.failure, squad: cached, confirmedNoSquad: false);
    }

    final fallback = await _loadSquadByProfileId(profileSquadId);
    if (fallback != null) {
      _session.setSquad(fallback);
      return (failure: null, squad: fallback, confirmedNoSquad: false);
    }

    _session.setSquad(null);
    _session.markConfirmedNoSquad();
    final user = _session.currentUser;
    if (user != null && (user.squadId ?? '').isNotEmpty) {
      _session.setUser(user.copyWith(clearSquadId: true));
    }
    return (failure: null, squad: null, confirmedNoSquad: true);
  }

  Future<Squad?> _loadSquadByProfileId(String? squadId) async {
    if (squadId == null || squadId.isEmpty) return null;
    final response = await _getSquadUseCase(squadId);
    return response.squad;
  }
}
