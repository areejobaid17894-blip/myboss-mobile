import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/auth/domain/entities/user.dart';
import 'package:myboss_mobile/features/auth/domain/repositories/auth_repository.dart';

class VerifyTwoFactorUseCase {
  const VerifyTwoFactorUseCase(this._repository);

  final AuthRepository _repository;

  Future<({Failure? failure, AuthResult? result})> call({
    required String sessionId,
    required String code,
  }) {
    return _repository.verifyTwoFactor(sessionId: sessionId, code: code);
  }
}

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<({Failure? failure, String? demoOtpCode})> call({required String sessionId}) {
    return _repository.resendOtp(sessionId: sessionId);
  }
}
