import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<Map<String, dynamic>> signIn({required String email}) async {
    final response = await _client.auth.post('/auth/sign-in', data: {'email': email});
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String sessionId,
    required String code,
  }) async {
    final response = await _client.auth.post('/auth/verify-2fa', data: {
      'sessionId': sessionId,
      'code': code,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> resendOtp({required String sessionId}) async {
    final response = await _client.auth.post('/auth/resend-otp', data: {'sessionId': sessionId});
    return response.data as Map<String, dynamic>;
  }
}
