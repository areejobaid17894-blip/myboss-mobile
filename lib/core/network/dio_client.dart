import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/auth/session_lifecycle.dart';
import 'package:myboss_mobile/core/config/env_config.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/network/dio_error_mapper.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';

class DioClient {
  DioClient(this._envConfig, this._secureStorage) {
    _authDio = _createDio(_envConfig.authBaseUrl, attachAuth: true);
    _userDio = _createDio(_envConfig.userBaseUrl);
    _configDio = _createDio(_envConfig.configBaseUrl);
    _squadDio = _createDio(_envConfig.squadBaseUrl);
    _surveyDio = _createDio(_envConfig.surveyBaseUrl);
  }

  final EnvConfig _envConfig;
  final SecureStorageService _secureStorage;
  late final Dio _authDio;
  late final Dio _userDio;
  late final Dio _configDio;
  late final Dio _squadDio;
  late final Dio _surveyDio;

  Future<bool>? _refreshInFlight;

  Dio get auth => _authDio;
  Dio get user => _userDio;
  Dio get config => _configDio;
  Dio get squad => _squadDio;
  Dio get survey => _surveyDio;

  Dio _createDio(String baseUrl, {bool attachAuth = true}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (getIt.isRegistered<LocaleCubit>()) {
          options.headers['Accept-Language'] = getIt<LocaleCubit>().state.languageCode;
        }

        if (attachAuth) {
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        if (!attachAuth) {
          handler.next(error);
          return;
        }

        final statusCode = error.response?.statusCode;
        final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');

        if (statusCode == 401 && !isRefreshCall) {
          final refreshed = await _tryRefreshAccessToken();
          if (refreshed) {
            try {
              final token = await _secureStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (retryError) {
              if (retryError is DioException) {
                handler.next(retryError);
                return;
              }
            }
          }
        }

        final data = error.response?.data;
        final code = extractDioCode(data);
        final orangeCode = data is Map<String, dynamic> && data['code'] is int ? data['code'] as int : null;
        final path = error.requestOptions.path;
        if (!isPreAuthUnauthorizedPath(path) &&
            (shouldEndSessionForUnauthorized(statusCode: statusCode, errorCode: code) ||
                shouldEndSessionForOrangeCode(orangeCode))) {
          await endUserSession();
        }
        handler.next(error);
      },
    ));

    if (_envConfig.isDevelopment) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    return dio;
  }

  Future<bool> _tryRefreshAccessToken() async {
    if (_refreshInFlight != null) {
      await _refreshInFlight;
      final token = await _secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    }

    _refreshInFlight = _refreshAccessToken();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _authDio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) return false;

      await _secureStorage.saveAccessToken(accessToken);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await _secureStorage.saveRefreshToken(newRefresh);
      }
      setAuthToken(accessToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreAuthTokenFromStorage() async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      setAuthToken(token);
    }
  }

  void setAuthToken(String token) {
    for (final dio in [_authDio, _userDio, _configDio, _squadDio, _surveyDio]) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void clearAuthToken() {
    for (final dio in [_authDio, _userDio, _configDio, _squadDio, _surveyDio]) {
      dio.options.headers.remove('Authorization');
    }
  }
}
