import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/auth/domain/entities/user.dart';
import 'package:myboss_mobile/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<({Failure? failure, AuthResult? result})> call({required String email}) {
    return _repository.signIn(email: email);
  }
}
