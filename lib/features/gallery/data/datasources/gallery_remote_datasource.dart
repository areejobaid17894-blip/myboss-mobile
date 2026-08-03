abstract class GalleryRemoteDataSource {
  Future<Map<String, dynamic>> getGallery({String? governorate});

  Future<Map<String, dynamic>> upload({
    required String userId,
    required String squadId,
    required String governorate,
    required String type,
    required String url,
    String? caption,
  });

  Future<int> getUnreadNotificationCount({
    required String userId,
    bool? onboardingCompleted,
    bool? openToTravel,
    bool? isLeader,
  });

  Future<void> markNotificationRead({required String notificationId, required String userId});
}
