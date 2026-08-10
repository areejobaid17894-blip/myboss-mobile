abstract class ChatRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMessages({required String peerId, String? since});
  Future<Map<String, dynamic>> sendMessage({required String recipientId, required String text});
}
