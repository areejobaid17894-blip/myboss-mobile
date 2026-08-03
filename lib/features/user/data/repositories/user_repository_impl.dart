import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/features/user/data/datasources/user_remote_datasource.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<({Failure? failure, UserProfile? profile})> getUser(String id) async {
    try {
      final data = await _remoteDataSource.getUser(id);
      return (failure: null, profile: UserProfile.fromJson(data));
    } on DioException catch (e) {
      return (failure: mapDioError(e), profile: null);
    } catch (_) {
      return (failure: const ServerFailure(), profile: null);
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
}
