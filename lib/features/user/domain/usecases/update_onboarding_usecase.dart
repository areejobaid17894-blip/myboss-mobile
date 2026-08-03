import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';

class UpdateOnboardingUseCase {
  const UpdateOnboardingUseCase(this._repository);

  final UserRepository _repository;

  Future<({Failure? failure, UserProfile? profile})> call({
    required String id,
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    bool? onboardingCompleted,
  }) {
    return _repository.updateOnboarding(
      id: id,
      vestSize: vestSize,
      buildingId: buildingId,
      buildingName: buildingName,
      governorate: governorate,
      openToTravel: openToTravel,
      onboardingCompleted: onboardingCompleted,
    );
  }
}
