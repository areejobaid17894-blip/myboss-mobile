import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<({Failure? failure, UserProfile? profile})> call({
    required String id,
    String? vestSize,
    bool? openToTravel,
  }) {
    return _repository.updateProfile(id: id, vestSize: vestSize, openToTravel: openToTravel);
  }
}
