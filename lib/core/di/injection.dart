import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:myboss_mobile/core/config/demo_api_resolver.dart';
import 'package:myboss_mobile/core/config/env_config.dart';
import 'package:myboss_mobile/core/network/dio_client.dart';
import 'package:myboss_mobile/core/localization/locale_cubit.dart';
import 'package:myboss_mobile/core/notifications/notification_unread_tracker.dart';
import 'package:myboss_mobile/core/notifications/push_registration_service.dart';
import 'package:myboss_mobile/core/notifications/push_service.dart';
import 'package:myboss_mobile/core/session/session_manager.dart';
import 'package:myboss_mobile/core/storage/secure_storage_service.dart';
import 'package:myboss_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:myboss_mobile/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:myboss_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:myboss_mobile/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:myboss_mobile/features/auth/domain/usecases/verify_two_factor_usecase.dart';
import 'package:myboss_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myboss_mobile/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:myboss_mobile/features/chat/data/datasources/chat_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/config/data/datasources/config_remote_datasource.dart';
import 'package:myboss_mobile/features/config/data/datasources/config_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/config/data/repositories/config_repository_impl.dart';
import 'package:myboss_mobile/features/config/domain/repositories/config_repository.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_buildings_usecase.dart';
import 'package:myboss_mobile/features/config/domain/usecases/get_employee_settings_usecase.dart';
import 'package:myboss_mobile/features/gallery/data/datasources/gallery_remote_datasource.dart';
import 'package:myboss_mobile/features/gallery/data/datasources/gallery_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:myboss_mobile/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:myboss_mobile/features/gallery/domain/usecases/gallery_usecases.dart';
import 'package:myboss_mobile/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:myboss_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:myboss_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:myboss_mobile/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:myboss_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:myboss_mobile/features/squad/data/datasources/squad_remote_datasource.dart';
import 'package:myboss_mobile/features/squad/data/datasources/squad_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/squad/data/repositories/squad_repository_impl.dart';
import 'package:myboss_mobile/features/squad/domain/repositories/squad_repository.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/squad_usecases.dart';
import 'package:myboss_mobile/features/squad/domain/usecases/resolve_user_squad_usecase.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/create_squad_cubit.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/join_squad_cubit.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/my_squad_cubit.dart';
import 'package:myboss_mobile/features/squad/presentation/cubit/squad_hub_cubit.dart';
import 'package:myboss_mobile/features/survey/data/datasources/survey_remote_datasource.dart';
import 'package:myboss_mobile/features/survey/data/datasources/survey_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/survey/data/repositories/survey_repository_impl.dart';
import 'package:myboss_mobile/features/survey/domain/repositories/survey_repository.dart';
import 'package:myboss_mobile/features/survey/domain/usecases/survey_usecases.dart';
import 'package:myboss_mobile/features/survey/presentation/cubit/dynamic_survey_cubit.dart';
import 'package:myboss_mobile/features/survey/presentation/cubit/reports_cubit.dart';
import 'package:myboss_mobile/features/user/data/datasources/user_remote_datasource.dart';
import 'package:myboss_mobile/features/user/data/datasources/user_remote_datasource_impl.dart';
import 'package:myboss_mobile/features/user/data/repositories/user_repository_impl.dart';
import 'package:myboss_mobile/features/user/domain/repositories/user_repository.dart';
import 'package:myboss_mobile/features/user/domain/usecases/get_user_usecase.dart';
import 'package:myboss_mobile/features/user/domain/usecases/accept_terms_usecase.dart';
import 'package:myboss_mobile/features/user/domain/usecases/update_onboarding_usecase.dart';
import 'package:myboss_mobile/features/user/domain/usecases/update_profile_usecase.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Config — web uses same-origin gateway URLs (see deploy at /app/)
  if (kIsWeb) {
    getIt.registerSingleton<EnvConfig>(EnvConfig.fromWebSameOrigin());
  } else if (const bool.fromEnvironment('DEMO_MODE', defaultValue: false)) {
    // Demo APK: probe LAN gateway + public tunnel at startup.
    getIt.registerSingleton<EnvConfig>(await resolveDemoEnvConfig());
  } else {
    getIt.registerSingleton<EnvConfig>(EnvConfig.fromEnvironment());
  }

  // Core
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<EnvConfig>(), getIt<SecureStorageService>()));
  await getIt<DioClient>().restoreAuthTokenFromStorage().timeout(
    const Duration(seconds: 15),
    onTimeout: () {},
  );
  getIt.registerLazySingleton<SessionManager>(() => SessionManager());
  getIt.registerLazySingleton<LocaleCubit>(() => LocaleCubit(getIt<SecureStorageService>()));
  await getIt<LocaleCubit>().loadSavedLocale().timeout(
    const Duration(seconds: 5),
    onTimeout: () {},
  );

  // Auth — Data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<SecureStorageService>(),
      getIt<DioClient>(),
    ),
  );

  // Auth — Domain
  getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyTwoFactorUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResendOtpUseCase(getIt<AuthRepository>()));

  // Auth — Presentation
  getIt.registerFactory(
    () => AuthBloc(
      signInUseCase: getIt<SignInUseCase>(),
      verifyTwoFactorUseCase: getIt<VerifyTwoFactorUseCase>(),
      resendOtpUseCase: getIt<ResendOtpUseCase>(),
    ),
  );

  // User — Data
  getIt.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt<UserRemoteDataSource>()));
  getIt.registerLazySingleton<NotificationUnreadTracker>(() => NotificationUnreadTracker());
  getIt.registerLazySingleton<PushRegistrationService>(
    () => PushRegistrationService(getIt<UserRepository>(), getIt<SecureStorageService>()),
  );
  getIt.registerLazySingleton<PushService>(
    () => PushService(getIt<PushRegistrationService>()),
  );

  // User — Domain
  getIt.registerLazySingleton(() => GetUserUseCase(getIt<UserRepository>()));
  getIt.registerLazySingleton(() => AcceptTermsUseCase(getIt<UserRepository>()));
  getIt.registerLazySingleton(() => UpdateOnboardingUseCase(getIt<UserRepository>()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt<UserRepository>()));

  // Config — Data / Domain
  getIt.registerLazySingleton<ConfigRemoteDataSource>(() => ConfigRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<ConfigRepository>(() => ConfigRepositoryImpl(getIt<ConfigRemoteDataSource>()));
  getIt.registerLazySingleton(() => GetBuildingsUseCase(getIt<ConfigRepository>()));
  getIt.registerLazySingleton(() => GetEmployeeSettingsUseCase(getIt<ConfigRepository>()));

  // Chat — Data (Apigee-backed config service)
  getIt.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(getIt<DioClient>()));

  // Squad — Data / Domain
  getIt.registerLazySingleton<SquadRemoteDataSource>(() => SquadRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<SquadRepository>(() => SquadRepositoryImpl(getIt<SquadRemoteDataSource>()));
  getIt.registerLazySingleton(() => GetSquadStatsUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => ListSquadsUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => CreateSquadUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => JoinSquadUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => GetMySquadUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => GetJoinStatusUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => GetSquadUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => RespondToJoinRequestUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => LeaveSquadUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => TransferLeadershipUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(() => RemoveSquadMemberUseCase(getIt<SquadRepository>()));
  getIt.registerLazySingleton(
    () => ResolveUserSquadUseCase(
      getIt<GetMySquadUseCase>(),
      getIt<GetSquadUseCase>(),
      getIt<SessionManager>(),
    ),
  );

  // Squad — Presentation
  getIt.registerFactory(() => SquadHubCubit(getIt<GetSquadStatsUseCase>(), getIt<GetJoinStatusUseCase>()));
  getIt.registerFactory(() => CreateSquadCubit(getIt<CreateSquadUseCase>()));
  getIt.registerFactory(() => JoinSquadCubit(
        getIt<ListSquadsUseCase>(),
        getIt<JoinSquadUseCase>(),
        getIt<GetJoinStatusUseCase>(),
      ));
  getIt.registerFactory(() => MySquadCubit(
        getIt<ResolveUserSquadUseCase>(),
        getIt<GetJoinStatusUseCase>(),
        getIt<RespondToJoinRequestUseCase>(),
        getIt<LeaveSquadUseCase>(),
        getIt<TransferLeadershipUseCase>(),
        getIt<RemoveSquadMemberUseCase>(),
      ));

  // Survey — Data / Domain
  getIt.registerLazySingleton<SurveyRemoteDataSource>(() => SurveyRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<SurveyRepository>(() => SurveyRepositoryImpl(getIt<SurveyRemoteDataSource>()));
  getIt.registerLazySingleton(() => ListSurveysUseCase(getIt<SurveyRepository>()));
  getIt.registerLazySingleton(() => GetActiveSurveyUseCase(getIt<SurveyRepository>()));
  getIt.registerLazySingleton(() => SubmitSurveyResponseUseCase(getIt<SurveyRepository>()));
  getIt.registerLazySingleton(() => GetSquadProgressUseCase(getIt<SurveyRepository>()));
  getIt.registerLazySingleton(() => GetSurveyReportUseCase(getIt<SurveyRepository>()));

  // Survey — Presentation
  getIt.registerFactory(() => DynamicSurveyCubit(getIt<GetActiveSurveyUseCase>(), getIt<SubmitSurveyResponseUseCase>()));
  getIt.registerFactory(() => ReportsCubit(getIt<GetSurveyReportUseCase>()));

  // Gallery — Data / Domain / Presentation
  getIt.registerLazySingleton<GalleryRemoteDataSource>(() => GalleryRemoteDataSourceImpl(getIt<DioClient>()));
  getIt.registerLazySingleton<GalleryRepository>(() => GalleryRepositoryImpl(getIt<GalleryRemoteDataSource>()));
  getIt.registerLazySingleton(() => GetGalleryUseCase(getIt<GalleryRepository>()));
  getIt.registerLazySingleton(() => UploadGalleryItemUseCase(getIt<GalleryRepository>()));
  getIt.registerLazySingleton(() => GetNotificationsForUserUseCase(getIt<GalleryRepository>()));
  getIt.registerLazySingleton(() => GetNotificationByIdUseCase(getIt<GalleryRepository>()));
  getIt.registerLazySingleton(() => MarkNotificationReadUseCase(getIt<GalleryRepository>()));
  getIt.registerFactory(
    () => NotificationsCubit(
      getIt<GetNotificationsForUserUseCase>(),
      getIt<MarkNotificationReadUseCase>(),
      getIt<NotificationUnreadTracker>(),
    ),
  );
  getIt.registerFactory(
    () => GalleryCubit(
      getIt<GetGalleryUseCase>(),
      getIt<UploadGalleryItemUseCase>(),
      getIt<MarkNotificationReadUseCase>(),
    ),
  );

  // Onboarding — Presentation
  getIt.registerFactory(() => OnboardingCubit(getIt<GetBuildingsUseCase>(), getIt<UpdateOnboardingUseCase>()));

  // Home — Presentation
  getIt.registerFactory(
    () => HomeCubit(
      getIt<ResolveUserSquadUseCase>(),
      getIt<GetJoinStatusUseCase>(),
      getIt<GetSquadProgressUseCase>(),
      getIt<GetSurveyReportUseCase>(),
      getIt<ListSurveysUseCase>(),
      getIt<GetNotificationsForUserUseCase>(),
      getIt<NotificationUnreadTracker>(),
    ),
  );

  // Profile — Presentation
  getIt.registerFactory(() => ProfileCubit(
        getIt<GetUserUseCase>(),
        getIt<UpdateProfileUseCase>(),
        getIt<GetEmployeeSettingsUseCase>(),
      ));
}
