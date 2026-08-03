import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';

abstract class SquadRepository {
  Future<({Failure? failure, SquadStats? stats})> getStats();

  Future<({Failure? failure, List<PublicSquad>? squads})> listSquads({
    String? query,
    String? governorate,
  });

  Future<({Failure? failure, Squad? squad})> createSquad({
    required String name,
    required String badge,
    required String leaderId,
    required String leaderFirstName,
    required String leaderLastName,
    required String governorate,
    String? building,
  });

  Future<({Failure? failure, SquadJoinRequest? request})> joinSquad({
    required String squadId,
    required String userId,
    required String firstName,
    required String lastName,
    String? building,
  });

  Future<({Failure? failure, Squad? squad})> getMySquad(String userId);

  Future<({Failure? failure, SquadJoinStatus? status})> getJoinStatus(String userId);

  Future<({Failure? failure, Squad? squad})> getSquad(String squadId);

  Future<({Failure? failure, Squad? squad})> respondToJoinRequest({
    required String squadId,
    required String requestId,
    required String leaderId,
    required bool accept,
  });

  Future<({Failure? failure, Squad? squad})> leaveSquad({
    required String squadId,
    required String userId,
  });

  Future<({Failure? failure, Squad? squad})> transferLeadership({
    required String squadId,
    required String leaderId,
    required String newLeaderId,
  });

  Future<({Failure? failure, Squad? squad})> removeMember({
    required String squadId,
    required String leaderId,
    required String memberId,
  });
}
