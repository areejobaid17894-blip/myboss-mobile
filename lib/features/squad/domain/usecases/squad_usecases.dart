import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/squad/domain/entities/squad.dart';
import 'package:myboss_mobile/features/squad/domain/repositories/squad_repository.dart';

class GetSquadStatsUseCase {
  const GetSquadStatsUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, SquadStats? stats})> call() => _repository.getStats();
}

class ListSquadsUseCase {
  const ListSquadsUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, List<PublicSquad>? squads})> call({String? query, String? governorate}) {
    return _repository.listSquads(query: query, governorate: governorate);
  }
}

class CreateSquadUseCase {
  const CreateSquadUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String name,
    required String badge,
    required String leaderId,
    required String leaderFirstName,
    required String leaderLastName,
    required String governorate,
    String? building,
  }) {
    return _repository.createSquad(
      name: name,
      badge: badge,
      leaderId: leaderId,
      leaderFirstName: leaderFirstName,
      leaderLastName: leaderLastName,
      governorate: governorate,
      building: building,
    );
  }
}

class JoinSquadUseCase {
  const JoinSquadUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, SquadJoinRequest? request})> call({
    required String squadId,
    required String userId,
    required String firstName,
    required String lastName,
    String? building,
  }) {
    return _repository.joinSquad(
      squadId: squadId,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      building: building,
    );
  }
}

class GetMySquadUseCase {
  const GetMySquadUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call(String userId) => _repository.getMySquad(userId);
}

class GetJoinStatusUseCase {
  const GetJoinStatusUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, SquadJoinStatus? status})> call(String userId) =>
      _repository.getJoinStatus(userId);
}

class GetSquadUseCase {
  const GetSquadUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call(String squadId) => _repository.getSquad(squadId);
}

class RespondToJoinRequestUseCase {
  const RespondToJoinRequestUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String squadId,
    required String requestId,
    required String leaderId,
    required bool accept,
  }) {
    return _repository.respondToJoinRequest(
      squadId: squadId,
      requestId: requestId,
      leaderId: leaderId,
      accept: accept,
    );
  }
}

class ListSuggestedMembersUseCase {
  const ListSuggestedMembersUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, SuggestedSquadMembers? suggestions})> call(String squadId) {
    return _repository.listSuggestedMembers(squadId);
  }
}

class InviteMemberUseCase {
  const InviteMemberUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, SquadJoinRequest? request})> call({
    required String squadId,
    required String userId,
  }) {
    return _repository.inviteMember(squadId: squadId, userId: userId);
  }
}

class CancelInviteUseCase {
  const CancelInviteUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String squadId,
    required String requestId,
  }) {
    return _repository.cancelInvite(squadId: squadId, requestId: requestId);
  }
}

class RespondToInviteUseCase {
  const RespondToInviteUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String squadId,
    required String requestId,
    required bool accept,
  }) {
    return _repository.respondToInvite(
      squadId: squadId,
      requestId: requestId,
      accept: accept,
    );
  }
}

class LeaveSquadUseCase {
  const LeaveSquadUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String squadId,
    required String userId,
  }) {
    return _repository.leaveSquad(squadId: squadId, userId: userId);
  }
}

class TransferLeadershipUseCase {
  const TransferLeadershipUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String squadId,
    required String leaderId,
    required String newLeaderId,
  }) {
    return _repository.transferLeadership(
      squadId: squadId,
      leaderId: leaderId,
      newLeaderId: newLeaderId,
    );
  }
}

class RemoveSquadMemberUseCase {
  const RemoveSquadMemberUseCase(this._repository);
  final SquadRepository _repository;

  Future<({Failure? failure, Squad? squad})> call({
    required String squadId,
    required String leaderId,
    required String memberId,
  }) {
    return _repository.removeMember(
      squadId: squadId,
      leaderId: leaderId,
      memberId: memberId,
    );
  }
}
