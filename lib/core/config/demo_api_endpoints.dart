import 'demo_server_host.dart';
import 'dev_api_host.dart';

/// Single backend origin. Build/run scripts pass `--dart-define=API_HOST=host`.
class DemoApiEndpoint {
  const DemoApiEndpoint({required this.host});

  final String host;
  static const int apiPort = int.fromEnvironment('API_PORT', defaultValue: 3001);

  String get baseOrigin => 'http://$host';
  String get apiBaseUrl => 'http://$host:$apiPort/api/v1';

  String authBaseUrl() => apiBaseUrl;
  String userBaseUrl() => apiBaseUrl;
  String configBaseUrl() => apiBaseUrl;
  String squadBaseUrl() => apiBaseUrl;
  String surveyBaseUrl() => apiBaseUrl;

  String get healthUrl => '$apiBaseUrl/health';

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

    // Prefer the same host resolution as local development (emulator → 10.0.2.2).
    final local = resolveDevApiHost();
    if (local.isNotEmpty) {
      return [DemoApiEndpoint(host: local)];
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
