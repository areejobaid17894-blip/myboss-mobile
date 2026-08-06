import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<({Failure? failure, UserProfile? profile})> getUser(String id);

  Future<({Failure? failure, UserProfile? profile})> updateOnboarding({
    required String id,
    String? vestSize,
    String? buildingId,
    String? buildingName,
    String? governorate,
    bool? openToTravel,
    bool? onboardingCompleted,
  });

  Future<({Failure? failure, UserProfile? profile})> acceptTerms({required String id});

  Future<({Failure? failure, UserProfile? profile})> updateProfile({
    required String id,
    String? vestSize,
    bool? openToTravel,
  });

  Future<bool> registerDeviceToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<void> revokeDeviceTokens({
    required String userId,
    String? token,
  });
}
