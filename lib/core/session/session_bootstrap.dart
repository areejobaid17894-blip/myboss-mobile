import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';

/// Returns the route the app should open on cold start.
Future<String> resolveInitialRoute() async {
  final storage = getIt<SecureStorageService>();
  final dio = getIt<DioClient>();

  await dio.restoreAuthTokenFromStorage();

  final userId = await storage.getUserId();
  final accessToken = await storage.getAccessToken();
  final refreshToken = await storage.getRefreshToken();

  final hasUser = userId != null && userId.isNotEmpty;
  final hasCredential = (accessToken != null && accessToken.isNotEmpty) ||
      (refreshToken != null && refreshToken.isNotEmpty);

  if (hasUser && hasCredential) {
    return '/resolve';
  }

  return '/sign-in';
}
