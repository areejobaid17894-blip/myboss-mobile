import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/core/network/json_list_parser.dart';
import 'package:myboss_mobile/features/squad/data/datasources/squad_remote_datasource.dart';

class SquadRemoteDataSourceImpl implements SquadRemoteDataSource {
  const SquadRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.squad.get('/squads/stats');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<dynamic>> listSquads({String? query, String? governorate}) async {
    final response = await _client.squad.get('/squads', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query.trim(),
      if (governorate != null && governorate.isNotEmpty) 'governorate': governorate.trim(),
    });
    return parseApiListResponse(response.data);
  }

  @override
  Future<Map<String, dynamic>> createSquad({
    required String name,
    required String badge,
    required String leaderId,
    required String leaderFirstName,
    required String leaderLastName,
    required String governorate,
    String? building,
  }) async {
    final response = await _client.squad.post('/squads', data: {
      'name': name,
      'badge': badge,
      'governorate': governorate,
      if (building != null) 'building': building,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> joinSquad({
    required String squadId,
    required String userId,
    required String firstName,
    required String lastName,
    String? building,
  }) async {
    final response = await _client.squad.post('/squads/$squadId/join');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>?> getMySquad(String userId) async {
    final response = await _client.squad.get('/squads/my/$userId');
    final data = response.data;
    if (data == null || data == '' || data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<Map<String, dynamic>> getJoinStatus(String userId) async {
    final response = await _client.squad.get('/squads/join-status/$userId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getSquad(String squadId) async {
    final response = await _client.squad.get('/squads/$squadId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> respondToJoinRequest({
    required String squadId,
    required String requestId,
    required String leaderId,
    required String action,
  }) async {
    final response = await _client.squad.put(
      '/squads/$squadId/requests/$requestId',
      data: {'action': action},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> leaveSquad({
    required String squadId,
    required String userId,
  }) async {
    final response = await _client.squad.post('/squads/$squadId/leave');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> transferLeadership({
    required String squadId,
    required String leaderId,
    required String newLeaderId,
  }) async {
    final response = await _client.squad.put(
      '/squads/$squadId/leadership',
      data: {'newLeaderId': newLeaderId},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> removeMember({
    required String squadId,
    required String leaderId,
    required String memberId,
  }) async {
    final response = await _client.squad.delete('/squads/$squadId/members/$memberId');
    return response.data as Map<String, dynamic>;
  }
}
