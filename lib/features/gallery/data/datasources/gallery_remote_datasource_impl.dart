import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/features/gallery/data/datasources/gallery_remote_datasource.dart';

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  const GalleryRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<Map<String, dynamic>> getGallery({String? governorate}) async {
    final response = await _client.survey.get('/gallery', queryParameters: {
      if (governorate != null && governorate.isNotEmpty) 'governorate': governorate,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> upload({
    required String userId,
    required String squadId,
    required String governorate,
    required String type,
    required String url,
    String? caption,
  }) async {
    final response = await _client.survey.post('/gallery', data: {
      'userId': userId,
      'squadId': squadId,
      'governorate': governorate,
      'type': type,
      'url': url,
      if (caption != null) 'caption': caption,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<int> getUnreadNotificationCount({
    required String userId,
    bool? onboardingCompleted,
    bool? openToTravel,
    bool? isLeader,
  }) async {
    final response = await _client.survey.get('/notifications/unread-count', queryParameters: {
      'userId': userId,
      if (onboardingCompleted != null) 'onboardingCompleted': onboardingCompleted,
      if (openToTravel != null) 'openToTravel': openToTravel,
      if (isLeader != null) 'isLeader': isLeader,
    });
    final data = response.data as Map<String, dynamic>;
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markNotificationRead({required String notificationId, required String userId}) async {
    await _client.survey.post('/notifications/$notificationId/read', data: {'userId': userId});
  }
}
