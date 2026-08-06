import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/user/data/datasources/user_remote_datasource.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<Map<String, dynamic>> getUser(String id) async {
    final response = await _client.user.get('/users/$id');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateOnboarding({
    required String id,
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    bool? onboardingCompleted,
  }) async {
    final body = <String, dynamic>{
      if (vestSize != null) 'vestSize': vestSize,
      if (buildingId != null) 'buildingId': buildingId,
      if (buildingName != null) 'buildingName': buildingName,
      if (governorate != null) 'governorate': governorate,
      if (openToTravel != null) 'openToTravel': openToTravel,
      if (onboardingCompleted != null) 'onboardingCompleted': onboardingCompleted,
    };
    final response = await _client.user.put('/users/$id/onboarding', data: body);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String id,
    String? vestSize,
    bool? openToTravel,
  }) async {
    final body = <String, dynamic>{
      if (vestSize != null) 'vestSize': vestSize,
      if (openToTravel != null) 'openToTravel': openToTravel,
    };
    final response = await _client.user.put('/users/$id/profile', data: body);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> acceptTerms({required String id}) async {
    final response = await _client.user.put('/users/$id/terms', data: {'accepted': true});
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    await _client.user.post('/users/$userId/device-token', data: {
      'token': token,
      'platform': platform,
    });
  }

  @override
  Future<void> revokeDeviceTokens({
    required String userId,
    String? token,
  }) async {
    await _client.user.delete('/users/$userId/device-token', data: {
      if (token != null) 'token': token,
    });
  }
}
