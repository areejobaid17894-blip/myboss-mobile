abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signIn({required String email});
  Future<Map<String, dynamic>> verifyTwoFactor({required String sessionId, required String code});
  Future<Map<String, dynamic>> resendOtp({required String sessionId});
}
