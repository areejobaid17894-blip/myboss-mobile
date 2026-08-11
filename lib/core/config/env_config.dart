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

    // All environments use direct microservice ports on API_HOST (or dev defaults).
    final host = resolveDevApiHost();
    logDevApiHostIfDebug(host);

    switch (envString) {
      case 'demo':
        return _directPorts(host, AppEnvironment.demo);
      case 'uat':
        return _directPorts(host, AppEnvironment.uat);
      case 'production':
        return _directPorts(host, AppEnvironment.production);
      default:
        return _directPorts(host, AppEnvironment.development);
    }
  }

  static EnvConfig _directPorts(String host, AppEnvironment env) {
    return EnvConfig._(
      environment: env,
      authBaseUrl: 'http://$host:3001/api/v1',
      userBaseUrl: 'http://$host:3002/api/v1',
      configBaseUrl: 'http://$host:3003/api/v1',
      squadBaseUrl: 'http://$host:3004/api/v1',
      surveyBaseUrl: 'http://$host:3005/api/v1',
    );
  }
}
