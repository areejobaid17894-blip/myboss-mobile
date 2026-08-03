import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<({Failure? failure, AuthResult? result})> signIn({required String email});

  Future<({Failure? failure, AuthResult? result})> signUp({required String email});

  Future<({Failure? failure, AuthResult? result})> verifyTwoFactor({
    required String sessionId,
    required String code,
  });

  Future<({Failure? failure, String? demoOtpCode})> resendOtp({
    required String sessionId,
  });

  Future<void> signOut();
}
