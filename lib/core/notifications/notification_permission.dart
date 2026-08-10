import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/localization/app_localizations.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/notifications/push_service.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/theme/app_colors.dart';
import 'package:myboss_mobile/core/widgets/boss_buttons.dart';

/// Checks and requests system notification permission (Android 13+ / iOS).
class NotificationPermission {
  NotificationPermission._();

  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static Future<bool> isGranted() async {
    if (kIsWeb || !PushService.pushEnabled) return false;
    if (Platform.isAndroid) {
      final android = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    }
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return false;
  }

  static Future<bool> request() async {
    if (kIsWeb || !PushService.pushEnabled) return false;
    if (Platform.isAndroid) {
      final android = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return false;
  }

  static Future<void> _registerPushAfterGrant() async {
    await initPushNotifications();
    await refreshPushRegistration();
    final userId = getIt<SessionManager>().currentUser?.id;
    if (userId != null) {
      await registerPushTokenWhenReady(userId);
    }
  }

  /// Shows a dialog prompting the user to enable push notifications.
  static Future<void> maybePrompt(BuildContext context) async {
    if (kIsWeb || !PushService.pushEnabled) return;
    if (await isGranted()) {
      await _registerPushAfterGrant();
      return;
    }
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppColors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.notificationsEnableTitle)),
          ],
        ),
        content: Text(l10n.notificationsEnableBody),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final userId = getIt<SessionManager>().currentUser?.id;
              if (userId != null) {
                unawaited(registerPushTokenWhenReady(userId));
              }
            },
            child: Text(l10n.notificationsEnableLater),
          ),
          BossPrimaryButton(
            label: l10n.notificationsEnableAction,
            compact: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final granted = await request();
              if (granted) {
                await _registerPushAfterGrant();
              }
            },
          ),
        ],
      ),
    );
  }
}
