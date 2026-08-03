import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';

Failure mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const NetworkFailure();
  }

  final code = extractDioCode(e.response?.data);
  final statusCode = e.response?.statusCode;

  if (statusCode == 404 && code == null) {
    return const ServerFailure(code: 'BACKEND_UNAVAILABLE');
  }
  if (statusCode == 401) {
    return AuthFailure(code: code ?? 'UNAUTHORIZED');
  }
  if (statusCode == 403) {
    return AuthFailure(code: code ?? 'FORBIDDEN');
  }
  if (statusCode == 404) {
    return ServerFailure(code: code ?? 'NOT_FOUND');
  }
  if (statusCode != null && statusCode >= 400 && statusCode < 500) {
    return ValidationFailure(code: code ?? 'VALIDATION_FAILED');
  }

  return ServerFailure(code: code ?? 'INTERNAL_ERROR');
}

/// Extracts an internal app error code from Orange or legacy error envelopes.
String? extractDioCode(dynamic data) {
  if (data is! Map<String, dynamic>) return null;

  final legacyCode = data['code'];
  if (legacyCode is String && legacyCode.isNotEmpty) return legacyCode;

  if (legacyCode is int) return _mapOrangeCode(legacyCode);

  return null;
}

String _mapOrangeCode(int orangeCode) {
  switch (orangeCode) {
    case 40:
      return 'UNAUTHORIZED';
    case 41:
      return 'AUTH_INVALID_OTP';
    case 42:
      return 'AUTH_SESSION_EXPIRED';
    case 50:
    case 51:
    case 52:
      return 'FORBIDDEN';
    case 60:
      return 'NOT_FOUND';
    case 69:
      return 'VALIDATION_FAILED';
    case 1:
    case 3:
    case 5:
    case 6:
      return 'INTERNAL_ERROR';
    default:
      if (orangeCode >= 20 && orangeCode <= 28) return 'VALIDATION_FAILED';
      return 'INTERNAL_ERROR';
  }
}

String? extractDioMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String) return message;
    if (message is List) return message.join(', ');
  }
  return null;
}

String? extractDioReason(dynamic data) {
  if (data is Map<String, dynamic>) {
    final reason = data['reason'];
    if (reason is String && reason.isNotEmpty) return reason;
  }
  return null;
}
