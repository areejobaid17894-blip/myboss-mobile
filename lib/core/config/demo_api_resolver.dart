import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myboss_mobile/core/config/demo_api_endpoints.dart';
import 'package:myboss_mobile/core/config/env_config.dart';

/// Picks the first reachable demo server from [DemoApiEndpoint.fromEnvironment].
Future<EnvConfig> resolveDemoEnvConfig() async {
  final endpoints = DemoApiEndpoint.fromEnvironment();
  final probe = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
    validateStatus: (status) => status != null && status < 500,
  ));

  final checks = await Future.wait(endpoints.map((endpoint) async {
    try {
      final response = await probe.get<String>(endpoint.healthUrl);
      if (response.statusCode == 200) {
        return endpoint;
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[MyBoss] Demo API unreachable: ${endpoint.baseOrigin}');
      }
    }
    return null;
  })).timeout(
    const Duration(seconds: 3),
    onTimeout: () => List<DemoApiEndpoint?>.filled(endpoints.length, null),
  );

  for (final endpoint in checks) {
    if (endpoint != null) {
      if (kDebugMode) {
        debugPrint('[MyBoss] Demo API reachable: ${endpoint.baseOrigin}');
      }
      return EnvConfig.fromDemoEndpoint(endpoint);
    }
  }

  if (kDebugMode) {
    debugPrint('[MyBoss] No demo host responded; using first configured endpoint');
  }
  return EnvConfig.fromDemoEndpoint(endpoints.first);
}
