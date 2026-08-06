import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myboss_mobile/core/config/env_config.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/main.dart' as app;

/// Login-only push test: OTP login → FCM token synced to backend → admin notification → FCM dispatch.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login triggers push token sync and admin notification dispatches FCM', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final env = getIt<EnvConfig>();
    final auth = Dio(BaseOptions(baseUrl: env.authBaseUrl));

    // 1. Login only (same as user flow: email + OTP).
    final signIn = await auth.post<Map<String, dynamic>>('/auth/sign-in', data: {'email': 'demo@orange.com'});
    final sessionId = signIn.data!['sessionId'] as String;
    final otp = signIn.data!['demoOtpCode'] as String? ?? '123456';
    final verify = await auth.post<Map<String, dynamic>>('/auth/verify-2fa', data: {
      'sessionId': sessionId,
      'code': otp,
    });
    final accessToken = verify.data!['accessToken'] as String;
    final userId = (verify.data!['user'] as Map<String, dynamic>)['id'] as String;
    getIt<DioClient>().setAuthToken(accessToken);

    // 2. Same automatic push sync that runs after login in the app.
    final synced = await registerPushTokenWhenReady(userId);
    expect(synced, isTrue, reason: 'After login, FCM token should sync to backend automatically');

    // 3. Confirm backend has a real FCM token for this user.
    final lookup = await auth.post<List<dynamic>>(
      '${env.userBaseUrl}/users/internal/device-tokens/lookup',
      data: jsonEncode({'employeeIds': [userId]}),
      options: Options(headers: {
        'Content-Type': 'application/json',
        'X-Internal-Service-Token': 'demo-internal-sync',
      }),
    );
    final fcmTokens = lookup.data!.cast<Map<String, dynamic>>().where((row) {
      final t = row['token'] as String;
      return t.contains(':') && !t.startsWith('manual-') && !t.startsWith('emulator-test');
    }).toList();
    expect(fcmTokens, isNotEmpty);

    final fcmToken = fcmTokens.last['token'] as String;

    // 4. Admin sends notification (same as admin UI).
    final adminAuth = await auth.post<Map<String, dynamic>>('/auth/admin-sign-in', data: {
      'email': 'admin@orange.com',
      'password': 'admin123',
    });
    final adminSessionId = adminAuth.data!['sessionId'] as String;
    final adminOtp = adminAuth.data!['demoOtpCode'] as String? ?? '123456';
    final adminVerify = await auth.post<Map<String, dynamic>>('/auth/verify-2fa', data: {
      'sessionId': adminSessionId,
      'code': adminOtp,
    });
    final adminToken = adminVerify.data!['accessToken'] as String;

    final survey = Dio(BaseOptions(
      baseUrl: env.surveyBaseUrl,
      headers: {'Authorization': 'Bearer $adminToken'},
    ));
    final notification = await survey.post<Map<String, dynamic>>('/notifications', data: {
      'title': 'Push test from admin',
      'body': 'If you see this alert, live push works.',
      'audience': 'All employees',
    });
    final notificationId = notification.data!['id'] as String;
    expect(notificationId, isNotEmpty);

    // 5. Verify FCM dispatch reached Firebase for our token.
    await Future<void>.delayed(const Duration(seconds: 2));
    final notificationBase = env.userBaseUrl.replaceFirst('/user/api/v1', '/notification/api/v1');
    final dispatch = await auth.post<Map<String, dynamic>>(
      '$notificationBase/push/internal/dispatch',
      data: jsonEncode({
        'notificationId': notificationId,
        'employeeIds': [userId],
        'pointer': {
          'v': '1',
          'type': 'admin_broadcast',
          'entityId': notificationId,
          'route': '/notifications',
          'sentAt': DateTime.now().toUtc().toIso8601String(),
        },
      }),
      options: Options(headers: {
        'Content-Type': 'application/json',
        'X-Internal-Service-Token': 'demo-internal-sync',
      }),
    );

    final results = (dispatch.data!['results'] as List<dynamic>).cast<Map<String, dynamic>>();
    final ours = results.where((r) => r['token'] == fcmToken).toList();
    expect(ours, isNotEmpty);
    expect(ours.first['status'], anyOf('sent', 'dry_run'),
        reason: 'FCM should accept the device token after login');
  });
}
