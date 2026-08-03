import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/chat/data/datasources/chat_remote_datasource.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<Map<String, dynamic>> getConfig() async {
    final response = await _client.config.get('/chat/config');
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<Map<String, dynamic>> getVisitor() async {
    final response = await _client.config.get('/chat/visitor');
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages({
    required String peerId,
    String? since,
  }) async {
    final response = await _client.config.get('/chat/messages', queryParameters: {
      'peerId': peerId,
      if (since != null && since.isNotEmpty) 'since': since,
    });
    final data = response.data as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String text,
  }) async {
    final response = await _client.config.post('/chat/messages', data: {
      'recipientId': recipientId,
      'text': text,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }
}
