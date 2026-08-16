import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/notifications/push_log.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/core/session/session_offline_store.dart';
import 'package:myboss_mobile/features/user/data/datasources/user_remote_datasource.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDataSource, this._offlineStore);

  final UserRemoteDataSource _remoteDataSource;
  final SessionOfflineStore _offlineStore;

  @override
  Future<({Failure? failure, UserProfile? profile})> getUser(String id) async {
    try {
      final data = await _remoteDataSource.getUser(id);
      return (failure: null, profile: UserProfile.fromJson(data));
    } on DioException catch (e) {
      final cached = await _offlineStore.loadProfile(userId: id);
      return (failure: mapDioError(e), profile: cached);
    } catch (_) {
      final cached = await _offlineStore.loadProfile(userId: id);
      return (failure: const ServerFailure(), profile: cached);
    }
  }

  @override
  Future<({Failure? failure, UserProfile? profile})> updateOnboarding({
    required String id,
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    List<String>? preferredGovernorates,
    bool? onboardingCompleted,
  }) async {
    try {
      final data = await _remoteDataSource.updateOnboarding(
        id: id,
        vestSize: vestSize,
        buildingId: buildingId,
        buildingName: buildingName,
        governorate: governorate,
        openToTravel: openToTravel,
        preferredGovernorates: preferredGovernorates,
        onboardingCompleted: onboardingCompleted,
      );
      return (failure: null, profile: UserProfile.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), profile: null);
    } catch (_) {
      return (failure: const ServerFailure(), profile: null);
    }
  }

  @override
  Future<({Failure? failure, UserProfile? profile})> acceptTerms({required String id}) async {
    try {
      final data = await _remoteDataSource.acceptTerms(id: id);
      return (failure: null, profile: UserProfile.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), profile: null);
    } catch (_) {
      return (failure: const ServerFailure(), profile: null);
    }
  }

  @override
  Future<({Failure? failure, UserProfile? profile})> updateProfile({
    required String id,
    String? vestSize,
    bool? openToTravel,
  }) async {
    try {
      final data = await _remoteDataSource.updateProfile(
        id: id,
        vestSize: vestSize,
        openToTravel: openToTravel,
      );
      return (failure: null, profile: UserProfile.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), profile: null);
    } catch (_) {
      return (failure: const ServerFailure(), profile: null);
    }
  }

  @override
  Future<bool> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _remoteDataSource.registerDeviceToken(
        userId: userId,
        token: token,
        platform: platform,
      );
      return true;
    } on DioException catch (e) {
      final body = e.response?.data;
      pushLog('registerDeviceToken HTTP ${e.response?.statusCode}: $body');
      return false;
    } catch (error) {
      pushLog('registerDeviceToken error: $error');
      return false;
    }
  }

  @override
  Future<void> revokeDeviceTokens({
    required String userId,
    String? token,
  }) async {
    try {
      await _remoteDataSource.revokeDeviceTokens(userId: userId, token: token);
    } catch (_) {
      // Best-effort on logout.
    }
  }
}
