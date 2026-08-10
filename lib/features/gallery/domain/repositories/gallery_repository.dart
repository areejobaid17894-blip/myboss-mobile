import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';

abstract class GalleryRepository {
  Future<({Failure? failure, GalleryFeed? feed})> getGallery({String? governorate});

  Future<({Failure? failure, GalleryItem? item})> upload({
    required String userId,
    required String squadId,
    required String governorate,
    required String type,
    required String url,
    String? caption,
  });

  Future<Failure?> markNotificationRead({required String notificationId, required String userId});

  Future<({Failure? failure, List<AppNotification> items})> getNotificationsForUser({
    required String userId,
    bool? onboardingCompleted,
    bool? openToTravel,
    bool? isLeader,
  });

  Future<({Failure? failure, AppNotification? item})> getNotificationById({
    required String id,
    required String userId,
  });
}
