abstract class UserRemoteDataSource {
  Future<Map<String, dynamic>> getUser(String id);

  Future<Map<String, dynamic>> updateOnboarding({
    required String id,
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    bool? onboardingCompleted,
  });

  Future<Map<String, dynamic>> updateProfile({
    required String id,
    String? vestSize,
    bool? openToTravel,
  });

  Future<Map<String, dynamic>> acceptTerms({required String id});
}
