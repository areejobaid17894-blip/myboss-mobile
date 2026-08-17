import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myboss_mobile/core/config/demo_api_endpoints.dart';
import 'package:myboss_mobile/core/config/env_config.dart';

/// Picks the first reachable demo server from [DemoApiEndpoint.fromEnvironment].
Future<EnvConfig> resolveDemoEnvConfig() async {
  final endpoints = DemoApiEndpoint.fromEnvironment();
  final probe = Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: 1500),
    receiveTimeout: const Duration(milliseconds: 1500),
    validateStatus: (status) => status != null && status < 500,
  ));

  for (final endpoint in endpoints) {
    try {
      final response = await probe.get<String>(endpoint.healthUrl);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('[MyBoss] Demo API reachable: ${endpoint.baseOrigin}');
        }
        return EnvConfig.fromDemoEndpoint(endpoint);
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[MyBoss] Demo API unreachable: ${endpoint.baseOrigin}');
      }
    }
  }

  if (kDebugMode) {
    debugPrint('[MyBoss] No demo host responded; using first configured endpoint');
  }
  return EnvConfig.fromDemoEndpoint(endpoints.first);
}
