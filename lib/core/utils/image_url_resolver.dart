/// Rewrites notification image URLs so devices can load admin-provided links.
String resolveNotificationImageUrl(String raw, String gatewayOrigin) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('data:image')) return trimmed;

  final gateway = Uri.tryParse(gatewayOrigin);
  if (gateway == null) return trimmed;

  if (trimmed.startsWith('//')) {
    return '${gateway.scheme}:$trimmed';
  }

  if (trimmed.startsWith('/')) {
    return gatewayOrigin + trimmed;
  }

  if (!trimmed.startsWith('http')) return trimmed;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed;

  if (!_isUnreachableFromDevice(uri.host)) return trimmed;

  return uri
      .replace(
        scheme: gateway.scheme,
        host: gateway.host,
        port: gateway.hasPort ? gateway.port : null,
      )
      .toString();
}

bool _isUnreachableFromDevice(String host) {
  final normalized = host.toLowerCase();
  if (normalized == 'localhost' || normalized == '127.0.0.1' || normalized.endsWith('.local')) {
    return true;
  }
  if (normalized.startsWith('192.168.') || normalized.startsWith('10.')) {
    return true;
  }
  if (normalized.startsWith('172.')) {
    final parts = normalized.split('.');
    if (parts.length >= 2) {
      final second = int.tryParse(parts[1]);
      if (second != null && second >= 16 && second <= 31) return true;
    }
  }
  return false;
}
