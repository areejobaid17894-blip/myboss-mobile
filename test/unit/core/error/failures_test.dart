import 'package:flutter_test/flutter_test.dart';
import 'package:myboss_mobile/core/error/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure stores error code', () {
      const failure = ServerFailure(code: 'INTERNAL_ERROR');
      expect(failure.code, 'INTERNAL_ERROR');
    });

    test('NetworkFailure has no code by default', () {
      const failure = NetworkFailure();
      expect(failure.code, isNull);
    });

    test('AuthFailure stores error code', () {
      const failure = AuthFailure(code: 'AUTH_INVALID_OTP');
      expect(failure.code, 'AUTH_INVALID_OTP');
    });

    test('Failures are equatable by code', () {
      const a = ServerFailure(code: 'NOT_FOUND');
      const b = ServerFailure(code: 'NOT_FOUND');
      expect(a, equals(b));
    });
  });
}
