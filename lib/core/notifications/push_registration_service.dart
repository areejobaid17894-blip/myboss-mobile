import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/config/env_config.dart';
import 'package:myboss_mobile/core/notifications/push_log.dart';
import 'package:myboss_mobile/core/notifications/push_registration_state.dart';
import 'package:myboss_mobile/core/notifications/push_service.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';

/// Registers FCM device tokens with user-service when available.
class PushRegistrationService {
  PushRegistrationService(this._userRepository, this._secureStorage);

  final UserRepository _userRepository;
  final SecureStorageService _secureStorage;
  bool _registerInFlight = false;

  PushRegistrationState get _state => PushRegistrationState.instance;

  Future<String?> currentToken() => _secureStorage.getFcmToken();

  Future<bool> registerIfAvailable(String userId) async {
    if (userId.isEmpty || _registerInFlight) return false;

    final token = await _secureStorage.getFcmToken();
    if (token == null || token.isEmpty) {
      pushLog('No FCM token stored yet for user $userId');
      _state.recordFailure('No FCM token on device yet');
      return false;
    }

    _state.recordLocalToken(token);

    final platform = _platform();
    if (platform == null) {
      _state.recordFailure('Unsupported platform');
      return false;
    }

    _registerInFlight = true;
    try {
      final ok = await _userRepository.registerDeviceToken(
        userId: userId,
        token: token,
        platform: platform,
      );
      if (ok) {
        pushLog('Registered device token for user $userId (${token.substring(0, 16)}...)');
        _state.recordSuccess(token);
      } else {
        final base = getIt.isRegistered<EnvConfig>() ? getIt<EnvConfig>().userBaseUrl : 'unknown';
        final message = 'Backend registration failed ($base)';
        pushLog('$message for user $userId');
        _state.recordFailure(message);
      }
      return ok;
    } finally {
      _registerInFlight = false;
    }
  }

  /// Ensures FCM token exists locally, then registers with backend.
  Future<bool> registerWhenReady(
    String userId, {
    Duration timeout = const Duration(seconds: 120),
  }) async {
    if (userId.isEmpty || kIsWeb || !PushService.pushEnabled) {
      _state.recordFailure('Push disabled or unsupported platform');
      return false;
    }

    pushLog('Starting registration for user $userId');
    await initPushNotifications();

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await acquireFcmToken();
      if (await registerIfAvailable(userId)) return true;
      await Future<void>.delayed(const Duration(seconds: 3));
    }

    final message = 'Timed out after ${timeout.inSeconds}s waiting for FCM + backend registration';
    pushLog('$message for user $userId');
    _state.recordFailure(message);
    return false;
  }

  Future<void> revokeAll(String userId) async {
    final token = await _secureStorage.getFcmToken();
    await _userRepository.revokeDeviceTokens(userId: userId, token: token);
    await _secureStorage.clearFcmToken();
  }

  Future<void> storeDeviceToken(String token) async {
    await _secureStorage.saveFcmToken(token);
    _state.recordLocalToken(token);
  }

  String? _platform() {
    if (kIsWeb) return null;
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }
}

Future<void> registerPushTokenIfAvailable(String userId) =>
    getIt<PushRegistrationService>().registerIfAvailable(userId);

Future<bool> registerPushTokenWhenReady(String userId) =>
    getIt<PushRegistrationService>().registerWhenReady(userId);

Future<void> revokePushTokens(String userId) =>
    getIt<PushRegistrationService>().revokeAll(userId);
