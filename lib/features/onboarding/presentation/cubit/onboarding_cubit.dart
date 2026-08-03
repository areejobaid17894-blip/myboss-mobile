import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/building.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_buildings_usecase.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/usecases/update_onboarding_usecase.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.isLoadingBuildings = false,
    this.buildings = const [],
    this.buildingsError,
    this.isSubmitting = false,
    this.submitError,
    this.updatedProfile,
  });

  final bool isLoadingBuildings;
  final List<Building> buildings;
  final Failure? buildingsError;
  final bool isSubmitting;
  final Failure? submitError;
  final UserProfile? updatedProfile;

  OnboardingState copyWith({
    bool? isLoadingBuildings,
    List<Building>? buildings,
    Failure? buildingsError,
    bool clearBuildingsError = false,
    bool? isSubmitting,
    Failure? submitError,
    bool clearSubmitError = false,
    UserProfile? updatedProfile,
  }) {
    return OnboardingState(
      isLoadingBuildings: isLoadingBuildings ?? this.isLoadingBuildings,
      buildings: buildings ?? this.buildings,
      buildingsError: clearBuildingsError ? null : (buildingsError ?? this.buildingsError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      updatedProfile: updatedProfile ?? this.updatedProfile,
    );
  }

  @override
  List<Object?> get props =>
      [isLoadingBuildings, buildings, buildingsError, isSubmitting, submitError, updatedProfile];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._getBuildingsUseCase, this._updateOnboardingUseCase) : super(const OnboardingState());
  final GetBuildingsUseCase _getBuildingsUseCase;
  final UpdateOnboardingUseCase _updateOnboardingUseCase;

  Future<void> loadBuildings() async {
    emit(state.copyWith(isLoadingBuildings: true, clearBuildingsError: true));
    final response = await _getBuildingsUseCase();
    if (response.failure != null) {
      emit(state.copyWith(isLoadingBuildings: false, buildingsError: response.failure));
      return;
    }
    emit(state.copyWith(isLoadingBuildings: false, buildings: response.buildings!));
  }

  Future<void> submit({
    required String userId,
    required String vestSize,
    required String buildingId,
    required String buildingName,
    required String governorate,
    required bool openToTravel,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    final response = await _updateOnboardingUseCase(
      id: userId,
      vestSize: vestSize,
      buildingId: buildingId,
      buildingName: buildingName,
      governorate: governorate,
      openToTravel: openToTravel,
      onboardingCompleted: true,
    );
    if (response.failure != null) {
      emit(state.copyWith(isSubmitting: false, submitError: response.failure));
      return;
    }
    emit(state.copyWith(isSubmitting: false, updatedProfile: response.profile));
  }
}
