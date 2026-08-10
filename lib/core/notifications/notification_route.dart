/// Maps backend notification pointer routes to app shell paths.
String resolveNotificationRoute(String? route) {
  final normalized = (route ?? '/notifications').trim();
  if (normalized.startsWith('/notifications/') && normalized.length > '/notifications/'.length) {
    return normalized;
  }
  switch (normalized) {
    case '/home':
      return '/home';
    case '/gallery':
      return '/gallery';
    case '/notifications':
      return '/notifications';
    case '/squad':
    case '/my-squad':
      return '/my-squad';
    case '/reports':
      return '/reports';
    case '/profile':
      return '/profile';
    default:
      return '/notifications';
  }
}

/// Extract notification id from routes like `/notifications/{id}`.
String? notificationIdFromRoute(String? route) {
  final normalized = (route ?? '').trim();
  const prefix = '/notifications/';
  if (!normalized.startsWith(prefix)) return null;
  final id = normalized.substring(prefix.length);
  return id.isEmpty ? null : id;
}
