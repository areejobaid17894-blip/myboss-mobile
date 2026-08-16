import 'package:dio/dio.dart';
import 'package:myboss_mobile/core/error/failures.dart';

bool isNetworkDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    case DioExceptionType.unknown:
      return e.response == null;
    default:
      return false;
  }
}

Failure mapDioError(DioException e) {
  if (isNetworkDioException(e)) {
    return const NetworkFailure();
  }

  final data = e.response?.data;
  final code = extractDioCode(data);
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
  if (data is! Map) return null;
  final map = Map<String, dynamic>.from(data);

  final internalCode = map['internalCode'];
  if (internalCode is String && internalCode.isNotEmpty) return internalCode;

  final legacyCode = map['code'];
  if (legacyCode is String && legacyCode.isNotEmpty) return legacyCode;

  if (legacyCode is int) {
    if (legacyCode == 69) return _mapConflictFromMessage(map);
    if (legacyCode >= 20 && legacyCode <= 28) {
      return _mapValidationFromMessage(map) ?? 'VALIDATION_FAILED';
    }
    return _mapOrangeCode(legacyCode);
  }

  return null;
}

String _mapConflictFromMessage(Map<String, dynamic> data) {
  final message = '${extractDioMessage(data) ?? ''} ${extractDioReason(data) ?? ''}'.toLowerCase();
  if (message.contains('already exists') ||
      message.contains('already taken') ||
      message.contains('name is already') ||
      message.contains('موجود بالفعل') ||
      message.contains('مستخدم بالفعل') ||
      message.contains('اسم الفريق')) {
    return 'SQUAD_NAME_TAKEN';
  }
  if (message.contains('already in a squad') || message.contains('بالفعل في فريق')) {
    return 'SQUAD_ALREADY_MEMBER';
  }
  if (message.contains('join request already') || message.contains('طلب الانضمام مسبقا')) {
    return 'SQUAD_JOIN_REQUEST_EXISTS';
  }
  if (message.contains('full') || message.contains('مكتمل')) {
    return 'SQUAD_FULL';
  }
  return 'SQUAD_NAME_TAKEN';
}

String? _mapValidationFromMessage(Map<String, dynamic> data) {
  final message = (extractDioMessage(data) ?? '').toLowerCase();
  if (message.contains('squad name') ||
      message.contains('numbers or special') ||
      message.contains('must be shorter') ||
      message.contains('must be longer') ||
      message.contains('should not be empty') ||
      message.contains('اسم الفريق')) {
    return 'SQUAD_NAME_INVALID';
  }
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
      return 'SQUAD_NAME_TAKEN';
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
  if (data is Map) {
    final message = data['message'];
    if (message is String) return message;
    if (message is List) return message.join(', ');
  }
  return null;
}

String? extractDioReason(dynamic data) {
  if (data is Map) {
    final reason = data['reason'];
    if (reason is String && reason.isNotEmpty) return reason;
  }
  return null;
}
