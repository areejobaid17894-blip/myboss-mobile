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
    const envString = String.fromEnvironment('ENV', defaultValue: 'development');

    final host = resolveDevApiHost();
    logDevApiHostIfDebug(host);

    switch (envString) {
      case 'demo':
        return _singleApi(host, AppEnvironment.demo);
      case 'uat':
        return _singleApi(host, AppEnvironment.uat);
      case 'production':
        return _singleApi(host, AppEnvironment.production);
      default:
        return _singleApi(host, AppEnvironment.development);
    }
  }

  static EnvConfig _singleApi(String host, AppEnvironment env) {
    const port = int.fromEnvironment('API_PORT', defaultValue: 3001);
    const scheme = String.fromEnvironment('API_SCHEME', defaultValue: 'http');
    final omitPort =
        (scheme == 'https' && (port == 443 || port == 0)) || (scheme == 'http' && port == 80);
    final origin = omitPort ? '$scheme://$host' : '$scheme://$host:$port';
    final base = '$origin/api/v1';
    return EnvConfig._(
      environment: env,
      authBaseUrl: base,
      userBaseUrl: base,
      configBaseUrl: base,
      squadBaseUrl: base,
      surveyBaseUrl: base,
    );
  }
}
