abstract class SquadRemoteDataSource {
  Future<Map<String, dynamic>> getStats();

  Future<List<dynamic>> listSquads({String? query, String? governorate});

  Future<Map<String, dynamic>> createSquad({
    required String name,
    required String badge,
    required String leaderId,
    required String leaderFirstName,
    required String leaderLastName,
    required String governorate,
    String? building,
  });

  Future<Map<String, dynamic>> joinSquad({
    required String squadId,
    required String userId,
    required String firstName,
    required String lastName,
    String? building,
  });

  Future<Map<String, dynamic>?> getMySquad(String userId);

  Future<Map<String, dynamic>> getJoinStatus(String userId);

  Future<Map<String, dynamic>> getSquad(String squadId);

  Future<Map<String, dynamic>> respondToJoinRequest({
    required String squadId,
    required String requestId,
    required String leaderId,
    required String action,
  });

  Future<Map<String, dynamic>> listSuggestedMembers(String squadId);

  Future<Map<String, dynamic>> inviteMember({
    required String squadId,
    required String userId,
  });

  Future<Map<String, dynamic>> respondToInvite({
    required String squadId,
    required String requestId,
    required String action,
  });

  Future<Map<String, dynamic>> cancelInvite({
    required String squadId,
    required String requestId,
  });

  Future<Map<String, dynamic>> cancelMyJoinRequest();

  Future<Map<String, dynamic>> leaveSquad({
    required String squadId,
    required String userId,
  });

  Future<Map<String, dynamic>> transferLeadership({
    required String squadId,
    required String leaderId,
    required String newLeaderId,
  });

  Future<Map<String, dynamic>> removeMember({
    required String squadId,
    required String leaderId,
    required String memberId,
  });
}
