import 'dart:convert';

/// Normalizes list payloads from APIs that may return a raw array or a wrapper.
List<dynamic> parseApiListResponse(dynamic data) {
  dynamic normalized = data;
  if (normalized is String && normalized.trim().isNotEmpty) {
    normalized = jsonDecode(normalized);
  }
  if (normalized is List) return normalized;
  if (normalized is Map) {
    final map = Map<String, dynamic>.from(normalized);
    for (final key in ['data', 'items', 'results', 'squads']) {
      final nested = map[key];
      if (nested is List) return nested;
    }
  }
  throw const FormatException('Expected a JSON array response');
}
