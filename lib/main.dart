import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myboss_mobile/app/app.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/notifications/push_service.dart';
import 'package:myboss_mobile/core/router/app_router.dart';
import 'package:myboss_mobile/core/session/session_bootstrap.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('ar'),
    initializeDateFormatting('en'),
  ]);
  await configureDependencies();
  final initialRoute = await resolveInitialRoute();
  configureAppRouter(initialLocation: initialRoute);
  runApp(const MyBossApp());
  // Do not block first frame — FCM/getToken can hang on first launch (no GMS yet).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    initPushNotifications();
  });
}
