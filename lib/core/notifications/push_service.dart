import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/notifications/notification_route.dart';
import 'package:myboss_mobile/core/notifications/push_log.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/router/app_router.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/firebase_options.dart';

/// Background FCM handler — must be top-level with vm:entry-point (PDF §5.3).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// FCM + local notifications — integrated with existing auth and go_router.
class PushService {
  PushService(this._pushRegistration);

  static const pushEnabled = bool.fromEnvironment('PUSH_ENABLED', defaultValue: false);

  final PushRegistrationService _pushRegistration;
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Important notifications',
    description: 'the Boss operational alerts',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  bool _initialized = false;
  bool _listenersAttached = false;
  Future<void>? _initFuture;

  Future<void> init() async {
    if (kIsWeb || !pushEnabled) return;
    _initFuture ??= _initWithTimeout();
    try {
      await _initFuture;
    } catch (error) {
      pushLog('init failed: $error');
    }
  }

  Future<void> _initWithTimeout() async {
    await Future<void>(() async {
      await _ensureFirebase();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          _routeFromPayload(response.payload);
        },
      );

      if (!_listenersAttached) {
        _fcm.onTokenRefresh.listen((token) async {
          pushLog('FCM token refreshed (${token.substring(0, 16)}...)');
          await _pushRegistration.storeDeviceToken(token);
          final userId = getIt<SessionManager>().currentUser?.id;
          if (userId != null) await _pushRegistration.registerIfAvailable(userId);
        });

        FirebaseMessaging.onMessage.listen(_showForeground);
        FirebaseMessaging.onMessageOpenedApp.listen((message) => _routeFromData(message.data));

        _listenersAttached = true;
      }

      if (Platform.isIOS) {
        for (var i = 0; i < 5; i++) {
          if (await _fcm.getAPNSToken() != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      await acquireAndStoreToken();

      final initial = await _fcm.getInitialMessage();
      if (initial != null) {
        _routeFromData(initial.data);
      }

      _initialized = true;
    }).timeout(const Duration(seconds: 60));
  }

  Future<void> _ensureFirebase() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      pushLog('Firebase initialized');
    } catch (error) {
      final message = error.toString();
      if (message.contains('duplicate-app') || Firebase.apps.isNotEmpty) {
        pushLog('Firebase already initialized');
        return;
      }
      pushLog('Firebase.initializeApp failed: $error');
      rethrow;
    }
  }

  /// Fetch FCM token from Firebase and persist locally.
  Future<String?> acquireAndStoreToken() async {
    if (kIsWeb || !pushEnabled) return null;

    try {
      if (!_initialized && _initFuture == null) {
        await init();
      } else if (!_initialized && _initFuture != null) {
        await _initFuture;
      }

      final token = await _fcm.getToken().timeout(const Duration(seconds: 30));
      if (token != null && token.isNotEmpty) {
        await _pushRegistration.storeDeviceToken(token);
        pushLog('FCM token acquired: $token');
        return token;
      }

      pushLog('FCM getToken returned empty — check Google Play Services and Firebase SHA-1');
      return null;
    } catch (error) {
      pushLog('getToken failed: $error');
      return null;
    }
  }

  Future<void> refreshRegistration() async {
    if (kIsWeb || !pushEnabled) return;

    try {
      if (!_initialized) {
        await init();
        return;
      }
      await acquireAndStoreToken();
    } catch (error) {
      pushLog('refreshRegistration failed: $error');
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? 'the Boss';
    final body = notification?.body ?? 'You have a new update. Tap to open.';
    final route = message.data['route'] as String?;

    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: route,
    );
  }

  void _routeFromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    _routeFromPayload(route);
  }

  void _routeFromPayload(String? route) {
    if (route == null || route.isEmpty) return;
    appRouter.go(resolveNotificationRoute(route));
  }
}

Future<void> initPushNotifications() async {
  if (!PushService.pushEnabled || kIsWeb) return;
  await getIt<PushService>().init();
}

Future<void> refreshPushRegistration() async {
  if (!PushService.pushEnabled || kIsWeb) return;
  await getIt<PushService>().refreshRegistration();
}

Future<String?> acquireFcmToken() async {
  if (!PushService.pushEnabled || kIsWeb) return null;
  return getIt<PushService>().acquireAndStoreToken();
}
