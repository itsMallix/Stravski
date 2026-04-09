import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/activity/data/datasources/activity_local_datasource.dart';
import '../../features/activity/data/datasources/activity_remote_datasource.dart';
import '../../features/activity/data/repositories/activity_repository_impl.dart';
import '../../features/activity/domain/repositories/activity_repository.dart';
import '../../features/activity/domain/usecases/save_activity_usecase.dart';
import '../../features/activity/domain/usecases/get_activities_usecase.dart';
import '../../features/activity/domain/usecases/get_activity_detail_usecase.dart';
import '../../features/activity/domain/usecases/export_gpx_usecase.dart';
import '../../features/activity/presentation/bloc/activity_bloc.dart';

import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_weekly_stats_usecase.dart';
import '../../features/analytics/domain/usecases/get_monthly_stats_usecase.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../services/location_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // ── Core Services ─────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LocationService());

  // ── AUTH (Firebase Auth + Firestore) ─────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),  // uses FirebaseAuth.instance + FirebaseFirestore.instance
  );
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        authRepository: sl(),
      ));

  // ── ACTIVITY (in-memory) ──────────────────────────────────────────────────
  sl.registerLazySingleton<ActivityLocalDataSource>(
    () => ActivityLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ActivityRemoteDataSource>(
    () => ActivityRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => SaveActivityUseCase(sl()));
  sl.registerLazySingleton(() => GetActivitiesUseCase(sl()));
  sl.registerLazySingleton(() => GetActivityDetailUseCase(sl()));
  sl.registerLazySingleton(() => ExportGpxUseCase(sl()));
  sl.registerFactory(() => ActivityBloc(
        saveActivityUseCase: sl(),
        getActivitiesUseCase: sl(),
        getActivityDetailUseCase: sl(),
        exportGpxUseCase: sl(),
        locationService: sl(),
      ));

  // ── ANALYTICS (demo data) ─────────────────────────────────────────────────
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWeeklyStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetMonthlyStatsUseCase(sl()));
  sl.registerFactory(() => AnalyticsBloc(
        getWeeklyStatsUseCase: sl(),
        getMonthlyStatsUseCase: sl(),
      ));

  // ── PROFILE (in-memory) ────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerFactory(() => ProfileBloc(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
      ));
}
