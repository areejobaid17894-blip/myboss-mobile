import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';
import 'package:myboss_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:myboss_mobile/features/auth/domain/entities/user.dart';
import 'package:myboss_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._secureStorage, this._dioClient);

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final DioClient _dioClient;

  @override
  Future<({Failure? failure, AuthResult? result})> signIn({required String email}) async {
    try {
      final data = await _remoteDataSource.signIn(email: email.trim().toLowerCase());
      return _mapResponse(data);
    } on DioException catch (e) {
      return (failure: mapDioError(e), result: null);
    } catch (_) {
      return (failure: const ServerFailure(code: 'INTERNAL_ERROR'), result: null);
    }
  }

  @override
  Future<({Failure? failure, AuthResult? result})> signUp({required String email}) async {
    try {
      final data = await _remoteDataSource.signUp(email: email.trim().toLowerCase());
      return _mapResponse(data);
    } on DioException catch (e) {
      return (failure: mapDioError(e), result: null);
    } catch (_) {
      return (failure: const ServerFailure(code: 'INTERNAL_ERROR'), result: null);
    }
  }

  @override
  Future<({Failure? failure, AuthResult? result})> verifyTwoFactor({
    required String sessionId,
    required String code,
  }) async {
    try {
      final data = await _remoteDataSource.verifyTwoFactor(sessionId: sessionId, code: code);
      return _mapResponse(data);
    } on DioException catch (e) {
      return (failure: mapDioError(e), result: null);
    } catch (_) {
      return (failure: const ServerFailure(code: 'INTERNAL_ERROR'), result: null);
    }
  }

  @override
  Future<({Failure? failure, String? demoOtpCode})> resendOtp({
    required String sessionId,
  }) async {
    try {
      final data = await _remoteDataSource.resendOtp(sessionId: sessionId);
      return (failure: null, demoOtpCode: data['demoOtpCode'] as String?);
    } on DioException catch (e) {
      return (failure: mapDioError(e), demoOtpCode: null);
    } catch (_) {
      return (failure: const ServerFailure(code: 'INTERNAL_ERROR'), demoOtpCode: null);
    }
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.clearTokens();
    _dioClient.clearAuthToken();
  }

  Future<({Failure? failure, AuthResult? result})> _mapResponse(Map<String, dynamic> data) async {
    if (data['requiresTwoFactor'] == true) {
      return (
        failure: null,
        result: AuthResult.twoFactorRequired(
          sessionId: data['sessionId'] as String,
          email: data['email'] as String? ?? '',
          demoOtpCode: data['demoOtpCode'] as String?,
        ),
      );
    }

    final tokens = AuthTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );

    await _secureStorage.saveAccessToken(tokens.accessToken);
    await _secureStorage.saveRefreshToken(tokens.refreshToken);
    _dioClient.setAuthToken(tokens.accessToken);

    final userData = data['user'] as Map<String, dynamic>;
    return (
      failure: null,
      result: AuthResult.authenticated(
        user: User(
          id: userData['id'] as String,
          email: userData['email'] as String,
          firstName: userData['firstName'] as String,
          lastName: userData['lastName'] as String,
        ),
        tokens: tokens,
      ),
    );
  }
}
