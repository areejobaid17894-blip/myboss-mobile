import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';

class AcceptTermsUseCase {
  const AcceptTermsUseCase(this._repository);

  final UserRepository _repository;

  Future<({Failure? failure, UserProfile? profile})> call({required String id}) {
    return _repository.acceptTerms(id: id);
  }
}
