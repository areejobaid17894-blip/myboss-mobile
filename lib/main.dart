import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:myboss_mobile/app/app.dart';
import 'package:myboss_mobile/core/di/injection.dart';
import 'package:myboss_mobile/core/router/app_router.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  configureAppRouter();
  runApp(const MyBossApp());
}
