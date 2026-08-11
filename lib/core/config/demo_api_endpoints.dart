import 'demo_server_host.dart';

/// Direct microservice endpoints for demo/release builds (no Apigee, no nginx gateway).
/// Build script passes --dart-define=API_HOST=host or API_HOSTS=host1,host2
class DemoApiEndpoint {
  const DemoApiEndpoint({required this.host});

  final String host;

  String get baseOrigin => 'http://$host';

  String authBaseUrl() => 'http://$host:3001/api/v1';
  String userBaseUrl() => 'http://$host:3002/api/v1';
  String configBaseUrl() => 'http://$host:3003/api/v1';
  String squadBaseUrl() => 'http://$host:3004/api/v1';
  String surveyBaseUrl() => 'http://$host:3005/api/v1';

  String get healthUrl => 'http://$host:3001/api/v1/health';

  static DemoApiEndpoint fromHost(String raw) {
    final host = raw.trim();
    // Strip scheme/port if someone passes a full URL by mistake
    final cleaned = host
        .replaceFirst(RegExp(r'^https?://'), '')
        .split(':')
        .first
        .split('/')
        .first;
    return DemoApiEndpoint(host: cleaned);
  }

  static List<DemoApiEndpoint> fromEnvironment() {
    const hostsCsv = String.fromEnvironment('API_HOSTS');
    const singleHost = String.fromEnvironment('API_HOST');
    final endpoints = <DemoApiEndpoint>[];

    if (hostsCsv.isNotEmpty) {
      endpoints.addAll(
        hostsCsv
            .split(',')
            .map((h) => h.trim())
            .where((h) => h.isNotEmpty)
            .map(fromHost),
      );
    }

    if (singleHost.isNotEmpty) {
      endpoints.add(fromHost(singleHost));
    }

    if (endpoints.isNotEmpty) {
      return _dedupe(endpoints);
    }

    return defaultEndpoints;
  }

  static List<DemoApiEndpoint> _dedupe(List<DemoApiEndpoint> endpoints) {
    final seen = <String>{};
    return endpoints.where((endpoint) {
      if (seen.contains(endpoint.host)) return false;
      seen.add(endpoint.host);
      return true;
    }).toList();
  }

  static final defaultEndpoints = [
    DemoApiEndpoint(host: demoServerHost),
  ];
}
