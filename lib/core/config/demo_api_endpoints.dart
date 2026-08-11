import 'demo_server_host.dart';

/// Demo server endpoints baked into release APK builds.
/// Build script passes --dart-define=API_HOSTS=host1,host2,...
class DemoApiEndpoint {
  const DemoApiEndpoint({
    required this.host,
    required this.useHttps,
    this.gatewayPort = '8090',
  });

  final String host;
  final bool useHttps;
  final String gatewayPort;

  String get scheme => useHttps ? 'https' : 'http';

  String get portSuffix {
    if (useHttps && !host.contains(':')) return '';
    if (host.contains(':')) return '';
    return ':$gatewayPort';
  }

  String get baseOrigin => '$scheme://$host$portSuffix';

  String get healthUrl {
    if (_isApigeeHost(host)) {
      return '$baseOrigin/auth/api/v1/health';
    }
    return '$baseOrigin/health';
  }

  String authBaseUrl() => '$baseOrigin/auth/api/v1';
  String userBaseUrl() => '$baseOrigin/user/api/v1';
  String configBaseUrl() => '$baseOrigin/config/api/v1';
  String squadBaseUrl() => '$baseOrigin/squad/api/v1';
  String surveyBaseUrl() => '$baseOrigin/survey/api/v1';

  static bool _isApigeeHost(String host) =>
      host.endsWith('.orange.com') || host.endsWith('.orange.jo');

  static bool _isTunnelHost(String host) =>
      host.contains('trycloudflare.com') ||
      host.contains('ngrok') ||
      _isApigeeHost(host);

  static DemoApiEndpoint fromHost(String raw) {
    final host = raw.trim();
    final useHttps = _isTunnelHost(host) || !host.contains(':');
    return DemoApiEndpoint(
      host: host,
      useHttps: useHttps,
      gatewayPort: useHttps && !host.contains(':') ? '' : '8090',
    );
  }

  static List<DemoApiEndpoint> fromEnvironment() {
    const gatewayOrigin = String.fromEnvironment('GATEWAY_ORIGIN');
    final endpoints = <DemoApiEndpoint>[];

    if (gatewayOrigin.isNotEmpty) {
      endpoints.add(_fromOrigin(gatewayOrigin));
    }

    const hostsCsv = String.fromEnvironment('API_HOSTS');
    if (hostsCsv.isNotEmpty) {
      endpoints.addAll(
        hostsCsv
            .split(',')
            .map((h) => h.trim())
            .where((h) => h.isNotEmpty)
            .map(fromHost),
      );
    }

    const singleHost = String.fromEnvironment('API_HOST');
    if (singleHost.isNotEmpty) {
      endpoints.add(fromHost(singleHost));
    }

    if (endpoints.isNotEmpty) {
      return _dedupe(endpoints);
    }

    return defaultEndpoints;
  }

  static DemoApiEndpoint _fromOrigin(String origin) {
    final uri = Uri.parse(origin);
    final host = uri.hasPort && uri.port != 80 && uri.port != 443
        ? '${uri.host}:${uri.port}'
        : uri.host;
    return DemoApiEndpoint(
      host: host,
      useHttps: uri.scheme == 'https',
      gatewayPort: uri.hasPort
          ? uri.port.toString()
          : (uri.scheme == 'https' ? '' : '8090'),
    );
  }

  static List<DemoApiEndpoint> _dedupe(List<DemoApiEndpoint> endpoints) {
    final seen = <String>{};
    return endpoints.where((endpoint) {
      final key = endpoint.baseOrigin;
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  /// Apigee first, then legacy LAN nginx fallback.
  static final defaultEndpoints = [
    DemoApiEndpoint(host: 'api-demo.orange.com', useHttps: true, gatewayPort: ''),
    DemoApiEndpoint(host: demoServerHost, useHttps: false),
  ];
}
