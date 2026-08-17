import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/core/session/session_offline_store.dart';
import 'package:myboss_mobile/features/squad/data/datasources/squad_remote_datasource.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/repositories/squad_repository.dart';

class SquadRepositoryImpl implements SquadRepository {
  const SquadRepositoryImpl(this._remoteDataSource, this._offlineStore);

  final SquadRemoteDataSource _remoteDataSource;
  final SessionOfflineStore _offlineStore;

  @override
  Future<({Failure? failure, SquadStats? stats})> getStats() async {
    try {
      final data = await _remoteDataSource.getStats();
      return (failure: null, stats: SquadStats.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), stats: null);
    } catch (_) {
      return (failure: const ServerFailure(), stats: null);
    }
  }

  @override
  Future<({Failure? failure, List<PublicSquad>? squads})> listSquads({
    String? query,
    String? governorate,
  }) async {
    try {
      final data = await _remoteDataSource.listSquads(query: query, governorate: governorate);
      final squads = <PublicSquad>[];
      for (final entry in data) {
        if (entry is! Map) continue;
        try {
          final squad = PublicSquad.fromJson(Map<String, dynamic>.from(entry));
          if (squad.id.isNotEmpty && squad.name.isNotEmpty) {
            squads.add(squad);
          }
        } catch (_) {
          continue;
        }
      }
      return (failure: null, squads: squads);
    } on DioException catch (e) {
      return (failure: mapDioError(e), squads: null);
    } catch (_) {
      return (failure: const ServerFailure(), squads: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> createSquad({
    required String name,
    required String badge,
    required String leaderId,
    required String leaderFirstName,
    required String leaderLastName,
    required String governorate,
    String? building,
  }) async {
    try {
      final data = await _remoteDataSource.createSquad(
        name: name,
        badge: badge,
        leaderId: leaderId,
        leaderFirstName: leaderFirstName,
        leaderLastName: leaderLastName,
        governorate: governorate,
        building: building,
      );
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, SquadJoinRequest? request})> joinSquad({
    required String squadId,
    required String userId,
    required String firstName,
    required String lastName,
    String? building,
  }) async {
    try {
      final data = await _remoteDataSource.joinSquad(
        squadId: squadId,
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        building: building,
      );
      return (failure: null, request: SquadJoinRequest.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), request: null);
    } catch (_) {
      return (failure: const ServerFailure(), request: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> getMySquad(String userId) async {
    try {
      final data = await _remoteDataSource.getMySquad(userId);
      if (data == null) return (failure: null, squad: null);
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (failure: null, squad: null);
      }
      final cached = await _offlineStore.loadSquad();
      if (cached != null) {
        return (failure: null, squad: cached);
      }
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      final cached = await _offlineStore.loadSquad();
      if (cached != null) {
        return (failure: null, squad: cached);
      }
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, SquadJoinStatus? status})> getJoinStatus(String userId) async {
    try {
      final data = await _remoteDataSource.getJoinStatus(userId);
      return (failure: null, status: SquadJoinStatus.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), status: null);
    } catch (_) {
      return (failure: const ServerFailure(), status: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> getSquad(String squadId) async {
    try {
      final data = await _remoteDataSource.getSquad(squadId);
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> respondToJoinRequest({
    required String squadId,
    required String requestId,
    required String leaderId,
    required bool accept,
  }) async {
    try {
      final data = await _remoteDataSource.respondToJoinRequest(
        squadId: squadId,
        requestId: requestId,
        leaderId: leaderId,
        action: accept ? 'accepted' : 'rejected',
      );
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, SuggestedSquadMembers? suggestions})> listSuggestedMembers(String squadId) async {
    try {
      final data = await _remoteDataSource.listSuggestedMembers(squadId);
      return (failure: null, suggestions: SuggestedSquadMembers.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), suggestions: null);
    } catch (_) {
      return (failure: const ServerFailure(), suggestions: null);
    }
  }

  @override
  Future<({Failure? failure, SquadJoinRequest? request})> inviteMember({
    required String squadId,
    required String userId,
  }) async {
    try {
      final data = await _remoteDataSource.inviteMember(squadId: squadId, userId: userId);
      return (failure: null, request: SquadJoinRequest.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), request: null);
    } catch (_) {
      return (failure: const ServerFailure(), request: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> respondToInvite({
    required String squadId,
    required String requestId,
    required bool accept,
  }) async {
    try {
      final data = await _remoteDataSource.respondToInvite(
        squadId: squadId,
        requestId: requestId,
        action: accept ? 'accepted' : 'rejected',
      );
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> cancelInvite({
    required String squadId,
    required String requestId,
  }) async {
    try {
      final data = await _remoteDataSource.cancelInvite(squadId: squadId, requestId: requestId);
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, SquadJoinStatus? status})> cancelMyJoinRequest() async {
    try {
      final data = await _remoteDataSource.cancelMyJoinRequest();
      return (failure: null, status: SquadJoinStatus.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), status: null);
    } catch (_) {
      return (failure: const ServerFailure(), status: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> leaveSquad({
    required String squadId,
    required String userId,
  }) async {
    try {
      final data = await _remoteDataSource.leaveSquad(squadId: squadId, userId: userId);
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> transferLeadership({
    required String squadId,
    required String leaderId,
    required String newLeaderId,
  }) async {
    try {
      final data = await _remoteDataSource.transferLeadership(
        squadId: squadId,
        leaderId: leaderId,
        newLeaderId: newLeaderId,
      );
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }

  @override
  Future<({Failure? failure, Squad? squad})> removeMember({
    required String squadId,
    required String leaderId,
    required String memberId,
  }) async {
    try {
      final data = await _remoteDataSource.removeMember(
        squadId: squadId,
        leaderId: leaderId,
        memberId: memberId,
      );
      return (failure: null, squad: Squad.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), squad: null);
    } catch (_) {
      return (failure: const ServerFailure(), squad: null);
    }
  }
}
