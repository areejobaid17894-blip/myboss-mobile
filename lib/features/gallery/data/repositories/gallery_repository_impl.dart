import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/features/gallery/data/datasources/gallery_remote_datasource.dart';
import 'package:myboss_mobile/features/gallery/domain/entities/gallery_item.dart';
import 'package:myboss_mobile/features/gallery/domain/repositories/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  const GalleryRepositoryImpl(this._remoteDataSource);

  final GalleryRemoteDataSource _remoteDataSource;

  @override
  Future<({Failure? failure, GalleryFeed? feed})> getGallery({String? governorate}) async {
    try {
      final data = await _remoteDataSource.getGallery(governorate: governorate);
      return (failure: null, feed: GalleryFeed.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), feed: null);
    } catch (_) {
      return (failure: const ServerFailure(), feed: null);
    }
  }

  @override
  Future<({Failure? failure, GalleryItem? item})> upload({
    required String userId,
    required String squadId,
    required String governorate,
    required String type,
    required String url,
    String? caption,
  }) async {
    try {
      final data = await _remoteDataSource.upload(
        userId: userId,
        squadId: squadId,
        governorate: governorate,
        type: type,
        url: url,
        caption: caption,
      );
      return (failure: null, item: GalleryItem.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), item: null);
    } catch (_) {
      return (failure: const ServerFailure(), item: null);
    }
  }

  @override
  Future<Failure?> markNotificationRead({required String notificationId, required String userId}) async {
    try {
      await _remoteDataSource.markNotificationRead(notificationId: notificationId, userId: userId);
      return null;
    } on DioException catch (e) {
      return mapDioError(e);
    } catch (_) {
      return const ServerFailure();
    }
  }

  @override
  Future<({Failure? failure, List<AppNotification> items})> getNotificationsForUser({
    required String userId,
    bool? onboardingCompleted,
    bool? openToTravel,
    bool? isLeader,
  }) async {
    try {
      final rows = await _remoteDataSource.getNotificationsForUser(
        userId: userId,
        onboardingCompleted: onboardingCompleted,
        openToTravel: openToTravel,
        isLeader: isLeader,
      );
      final items = rows.map(AppNotification.fromJson).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return (failure: null, items: items);
    } on DioException catch (e) {
      return (failure: mapDioError(e), items: <AppNotification>[]);
    } catch (_) {
      return (failure: const ServerFailure(), items: <AppNotification>[]);
    }
  }

  @override
  Future<({Failure? failure, AppNotification? item})> getNotificationById({
    required String id,
    required String userId,
  }) async {
    try {
      final data = await _remoteDataSource.getNotificationById(id: id, userId: userId);
      return (failure: null, item: AppNotification.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), item: null);
    } catch (_) {
      return (failure: const ServerFailure(), item: null);
    }
  }
}
