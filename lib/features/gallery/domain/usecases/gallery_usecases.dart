import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/features/gallery/domain/repositories/gallery_repository.dart';

class GetGalleryUseCase {
  const GetGalleryUseCase(this._repository);
  final GalleryRepository _repository;

  Future<({Failure? failure, GalleryFeed? feed})> call({String? governorate}) {
    return _repository.getGallery(governorate: governorate);
  }
}

class UploadGalleryItemUseCase {
  const UploadGalleryItemUseCase(this._repository);
  final GalleryRepository _repository;

  Future<({Failure? failure, GalleryItem? item})> call({
    required String userId,
    required String squadId,
    required String governorate,
    required String type,
    required String url,
    String? caption,
  }) {
    return _repository.upload(
      userId: userId,
      squadId: squadId,
      governorate: governorate,
      type: type,
      url: url,
      caption: caption,
    );
  }
}

class GetUnreadNotificationCountUseCase {
  const GetUnreadNotificationCountUseCase(this._repository);
  final GalleryRepository _repository;

  Future<({Failure? failure, int count})> call({
    required String userId,
    bool? onboardingCompleted,
    bool? openToTravel,
    bool? isLeader,
  }) {
    return _repository.getUnreadNotificationCount(
      userId: userId,
      onboardingCompleted: onboardingCompleted,
      openToTravel: openToTravel,
      isLeader: isLeader,
    );
  }
}

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);
  final GalleryRepository _repository;

  Future<Failure?> call({required String notificationId, required String userId}) {
    return _repository.markNotificationRead(notificationId: notificationId, userId: userId);
  }
}
