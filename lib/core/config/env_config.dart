import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:myboss_mobile/core/config/demo_api_endpoints.dart';
import 'package:myboss_mobile/core/config/dev_api_host.dart';

enum AppEnvironment {
  development,
  demo,
  uat,
  production,
}

class EnvConfig {
  const EnvConfig._({
    required this.environment,
    required this.authBaseUrl,
    required this.userBaseUrl,
    required this.configBaseUrl,
    required this.squadBaseUrl,
    required this.surveyBaseUrl,
  });

  final AppEnvironment environment;
  final String authBaseUrl;
  final String userBaseUrl;
  final String configBaseUrl;
  final String squadBaseUrl;
  final String surveyBaseUrl;

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;
  bool get isDemo => environment == AppEnvironment.demo;

  /// Web app served from the API gateway (same origin — no CORS).
  static EnvConfig fromWebSameOrigin() {
    final origin = Uri.base.origin;
    return fromGatewayOrigin(origin);
  }

  static EnvConfig fromGatewayOrigin(String origin) {
    final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
    return EnvConfig._(
      environment: AppEnvironment.demo,
      authBaseUrl: '$base/auth/api/v1',
      userBaseUrl: '$base/user/api/v1',
      configBaseUrl: '$base/config/api/v1',
      squadBaseUrl: '$base/squad/api/v1',
      surveyBaseUrl: '$base/survey/api/v1',
    );
  }

  static EnvConfig fromDemoEndpoint(DemoApiEndpoint endpoint) {
    return EnvConfig._(
      environment: AppEnvironment.demo,
      authBaseUrl: endpoint.authBaseUrl(),
      userBaseUrl: endpoint.userBaseUrl(),
      configBaseUrl: endpoint.configBaseUrl(),
      squadBaseUrl: endpoint.squadBaseUrl(),
      surveyBaseUrl: endpoint.surveyBaseUrl(),
    );
  }

  static EnvConfig fromEnvironment() {
    const gatewayOrigin = String.fromEnvironment('GATEWAY_ORIGIN');
    if (gatewayOrigin.isNotEmpty) {
      return fromGatewayOrigin(gatewayOrigin);
    }

    const envString = String.fromEnvironment('ENV', defaultValue: 'development');

    switch (envString) {
      case 'demo':
        return _demo;
      case 'uat':
        return _uat;
      case 'production':
        return _production;
      default:
        if (kIsWeb) {
          return fromWebSameOrigin();
        }
        return _development();
    }
  }

  static EnvConfig _development() {
    final host = resolveDevApiHost();
    logDevApiHostIfDebug(host);

    return EnvConfig._(
      environment: AppEnvironment.development,
      authBaseUrl: 'http://$host:3001/api/v1',
      userBaseUrl: 'http://$host:3002/api/v1',
      configBaseUrl: 'http://$host:3003/api/v1',
      squadBaseUrl: 'http://$host:3004/api/v1',
      surveyBaseUrl: 'http://$host:3005/api/v1',
    );
  }

  static const _demo = EnvConfig._(
    environment: AppEnvironment.demo,
    authBaseUrl: 'https://api-demo.example.com/auth/api/v1',
    userBaseUrl: 'https://api-demo.example.com/user/api/v1',
    configBaseUrl: 'https://api-demo.example.com/config/api/v1',
    squadBaseUrl: 'https://api-demo.example.com/squad/api/v1',
    surveyBaseUrl: 'https://api-demo.example.com/survey/api/v1',
  );

  static const _uat = EnvConfig._(
    environment: AppEnvironment.uat,
    authBaseUrl: 'https://api-uat.example.com/auth/api/v1',
    userBaseUrl: 'https://api-uat.example.com/user/api/v1',
    configBaseUrl: 'https://api-uat.example.com/config/api/v1',
    squadBaseUrl: 'https://api-uat.example.com/squad/api/v1',
    surveyBaseUrl: 'https://api-uat.example.com/survey/api/v1',
  );

  static const _production = EnvConfig._(
    environment: AppEnvironment.production,
    authBaseUrl: 'https://api.example.com/auth/api/v1',
    userBaseUrl: 'https://api.example.com/user/api/v1',
    configBaseUrl: 'https://api.example.com/config/api/v1',
    squadBaseUrl: 'https://api.example.com/squad/api/v1',
    surveyBaseUrl: 'https://api.example.com/survey/api/v1',
  );
}
