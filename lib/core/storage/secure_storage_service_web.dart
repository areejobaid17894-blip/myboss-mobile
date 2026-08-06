import 'dart:html' as html;

/// Web demo storage — uses localStorage so token save works over HTTP/LAN.
/// flutter_secure_storage can hang on non-HTTPS origins.
class SecureStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _localeKey = 'app_locale';
  static const _fcmTokenKey = 'fcm_device_token';

  Future<void> saveAccessToken(String token) async {
    html.window.localStorage[_accessTokenKey] = token;
  }

  Future<void> saveRefreshToken(String token) async {
    html.window.localStorage[_refreshTokenKey] = token;
  }

  Future<String?> getAccessToken() async =>
      html.window.localStorage[_accessTokenKey];

  Future<String?> getRefreshToken() async =>
      html.window.localStorage[_refreshTokenKey];

  Future<void> saveLocale(String languageCode) async {
    html.window.localStorage[_localeKey] = languageCode;
  }

  Future<String?> getLocale() async => html.window.localStorage[_localeKey];

  Future<void> saveFcmToken(String token) async {
    html.window.localStorage[_fcmTokenKey] = token;
  }

  Future<String?> getFcmToken() async => html.window.localStorage[_fcmTokenKey];

  Future<void> clearFcmToken() async {
    html.window.localStorage.remove(_fcmTokenKey);
  }

  Future<void> clearTokens() async {
    html.window.localStorage.remove(_accessTokenKey);
    html.window.localStorage.remove(_refreshTokenKey);
  }
}
