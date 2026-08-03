import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myboss_mobile/core/error/failures.dart';
import 'package:myboss_mobile/features/config/domain/entities/employee_settings.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_employee_settings_usecase.dart';
import 'package:myboss_mobile/features/user/domain/entities/user_profile.dart';
import 'package:myboss_mobile/features/user/domain/usecases/get_user_usecase.dart';
import 'package:myboss_mobile/features/user/domain/usecases/update_profile_usecase.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.settings,
    this.error,
    this.isSaving = false,
    this.saveError,
  });
  final bool isLoading;
  final UserProfile? profile;
  final EmployeeSettings? settings;
  final Failure? error;
  final bool isSaving;
  final Failure? saveError;

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? profile,
    EmployeeSettings? settings,
    Failure? error,
    bool clearError = false,
    bool? isSaving,
    Failure? saveError,
    bool clearSaveError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      error: clearError ? null : (error ?? this.error),
      isSaving: isSaving ?? this.isSaving,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, settings, error, isSaving, saveError];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getUserUseCase,
    this._updateProfileUseCase,
    this._getEmployeeSettingsUseCase,
  ) : super(const ProfileState());

  final GetUserUseCase _getUserUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetEmployeeSettingsUseCase _getEmployeeSettingsUseCase;

  Future<void> load(String id) async {
    if (id.isEmpty) {
      emit(state.copyWith(isLoading: false, error: const ValidationFailure(code: 'USER_ID_REQUIRED')));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    final settingsResponse = await _getEmployeeSettingsUseCase();
    final response = await _getUserUseCase(id);
    if (response.failure != null) {
      emit(state.copyWith(isLoading: false, error: response.failure, settings: settingsResponse.settings));
      return;
    }
    emit(state.copyWith(
      isLoading: false,
      profile: response.profile,
      settings: settingsResponse.settings ?? const EmployeeSettings(
        profileEditLimit: 2,
        vestSizeEditWindowStart: '',
        vestSizeEditWindowEnd: '',
      ),
    ));
  }

  Future<void> save({required String id, String? vestSize, bool? openToTravel}) async {
    emit(state.copyWith(isSaving: true, clearSaveError: true));
    final response = await _updateProfileUseCase(id: id, vestSize: vestSize, openToTravel: openToTravel);
    if (response.failure != null) {
      emit(state.copyWith(isSaving: false, saveError: response.failure));
      return;
    }
    emit(state.copyWith(isSaving: false, profile: response.profile));
  }
}
