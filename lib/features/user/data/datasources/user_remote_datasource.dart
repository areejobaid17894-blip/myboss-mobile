abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> getUser(String id);

  Future<Map<String, dynamic>> updateOnboarding({
    required String id,
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    List<String>? preferredGovernorates,
    bool? onboardingCompleted,
  });

  Future<Map<String, dynamic>> updateProfile({
    required String id,
    String? vestSize,
    bool? openToTravel,
  });

  Future<Map<String, dynamic>> acceptTerms({required String id});

  Future<void> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<void> revokeDeviceTokens({
    required String userId,
    String? token,
  });
}
