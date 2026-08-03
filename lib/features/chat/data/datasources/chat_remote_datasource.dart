abstract class ChatRemoteDataSource {
  Future<Map<String, dynamic>> getConfig();
  Future<Map<String, dynamic>> getVisitor();
  Future<List<Map<String, dynamic>>> getMessages({required String peerId, String? since});
  Future<Map<String, dynamic>> sendMessage({required String recipientId, required String text});
}
