/// Maps backend notification pointer routes to app shell paths.
String resolveNotificationRoute(String? route) {
  final normalized = (route ?? '/notifications').trim();
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
