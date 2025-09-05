import 'package:Aman/core/shared/services/dio_service.dart';
import 'package:Aman/features/driver/profile_management/presentation/bloc/driver_profile_bloc.dart';
import 'package:Aman/features/driver/trips_management/presentation/bloc/driver_trips_bloc.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/locale/auth_local_data_source.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/remote/auth_remote_data_source.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/usecases/get_user_usecase.dart';
import 'package:get_it/get_it.dart';
import '../core/shared/services/storage_service.dart';
import 'platform/platform_service.dart';
import '../core/shared/theme/cubit/theme_cubit.dart';
import '../features/passenger/profile/presentation/viewModel/settings/settings_cubit.dart';
import '../features/passenger/profile/presentation/viewModel/language/language_cubit.dart';
import '../features/passenger/profile/presentation/viewModel/profile_cubit/passenger_profile_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/shared_fetaures/layout/presentation/navigationController/navigation_bloc.dart';
import '../features/shared_fetaures/auth/data/datasource/remote/auth_remote_data_source_abstract.dart';
import '../features/shared_fetaures/auth/data/repository_impl/auth_repo_impl.dart';
import '../features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import '../features/shared_fetaures/auth/domain/usecases/login_usecase.dart';
import '../features/shared_fetaures/auth/domain/usecases/logout_usecase.dart';
import '../features/shared_fetaures/auth/domain/usecases/register_usecase.dart';
import '../features/shared_fetaures/auth/presentation/bloc/auth_cubit.dart';

// Driver Profile Management Imports
import '../features/driver/profile_management/data/datasources/driver_profile_local_data_source.dart';
import '../features/driver/profile_management/data/repositories/driver_profile_repository_impl.dart';
import '../features/driver/profile_management/domain/repositories/driver_profile_repository.dart';
import '../features/driver/profile_management/domain/usecases/get_driver_profile.dart';
import '../features/driver/profile_management/domain/usecases/create_driver_profile.dart';
import '../features/driver/profile_management/domain/usecases/update_driver_profile.dart';
import '../features/driver/profile_management/domain/usecases/contact_admin.dart';

// Driver Trips Management Imports
import '../features/driver/trips_management/data/datasources/driver_trips_local_data_source.dart';
import '../features/driver/trips_management/data/datasources/driver_trips_remote_data_source.dart';
import '../features/driver/trips_management/data/repositories/driver_trips_repository_impl.dart';
import '../features/driver/trips_management/domain/repositories/driver_trips_repository.dart';
import '../features/driver/trips_management/domain/usecases/get_current_trips.dart';
import '../features/driver/trips_management/domain/usecases/get_trip_history.dart';
import '../features/driver/trips_management/domain/usecases/get_trips_by_status.dart';
import '../features/driver/trips_management/domain/usecases/get_trip_passengers.dart';
import '../features/driver/trips_management/domain/usecases/update_passenger_status.dart';
import '../features/driver/trips_management/domain/usecases/notify_passenger_arrival.dart';
import '../features/driver/trips_management/domain/usecases/start_trip.dart';
import '../features/driver/trips_management/domain/usecases/complete_trip.dart';
import '../features/driver/trips_management/domain/usecases/update_trip_status.dart';

// Passenger Profile Management Imports
import '../features/passenger/profile/data/datasources/passenger_profile_data_source.dart';
import '../features/passenger/profile/data/datasources/passenger_profile_local_data_source_impl.dart';
import '../features/passenger/profile/data/datasources/passenger_profile_remote_data_source_impl.dart';
import '../features/passenger/profile/data/repositories/passenger_profile_repository_impl.dart';
import '../features/passenger/profile/domain/repositories/passenger_profile_repository.dart';
import '../features/passenger/profile/domain/usecases/passenger_profile_usecases.dart';

final sl = GetIt.instance;

Future<void> initGitIt() async {
  // Core Services - Add this FIRST
  await _initCoreServices();

  // External
  await _initExternal();

  // Features
  await _initializeAuthFeature();
  await _initializeLayoutFeature();
  await _initializeProfileFeature();
  await _initializeDriverFeature();
  _initializeTheme();
}

Future<void> _initCoreServices() async {
  // Register PlatformService as a singleton
  sl.registerLazySingleton<PlatformService>(() => PlatformServiceImpl());

  // Register StorageService as a singleton
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // Register and initialize FirebaseService as a singleton
  // final firebaseService = FirebaseService();
  // await firebaseService.initialize();
  // sl.registerSingleton<FirebaseService>(firebaseService);
}

Future<void> _initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
}

Future<void> _initializeAuthFeature() async {
  // Register DioService if not already registered
  if (!sl.isRegistered<DioService>()) {
    sl.registerLazySingleton<DioService>(() => DioService.instance);
  }

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dioService: sl<DioService>(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Cubit
  sl.registerFactory(() => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));
}

Future<void> _initializeLayoutFeature() async {
  // Navigation Bloc
  sl.registerLazySingleton<NavigationBloc>(() => NavigationBloc());
}

void _initializeTheme() {
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}

Future<void> _initializeProfileFeature() async {
  // Profile Feature Cubits
  sl.registerFactory<SettingsCubit>(() => SettingsCubit());
  sl.registerFactory<LanguageCubit>(() => LanguageCubit());

  // Passenger Profile Management - Data Sources
  sl.registerLazySingleton<PassengerProfileLocalDataSource>(
    () => PassengerProfileLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<PassengerProfileRemoteDataSource>(
    () => PassengerProfileRemoteDataSourceImpl(),
  );

  // Passenger Profile Management - Repositories
  sl.registerLazySingleton<PassengerProfileRepository>(
    () => PassengerProfileRepositoryImpl(
      remoteDataSource: sl<PassengerProfileRemoteDataSource>(),
      localDataSource: sl<PassengerProfileLocalDataSource>(),
    ),
  );

  // Passenger Profile Management - Use Cases
  sl.registerLazySingleton(() => GetPassengerProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePassengerProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePassengerPreferencesUseCase(sl()));

  // Register PassengerProfileCubit
  sl.registerFactory(() => PassengerProfileCubit(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        updatePreferencesUseCase: sl(),
        logoutUseCase: sl(),
      ));
}

Future<void> _initializeDriverFeature() async {
  // Profile Management - Data Sources
  sl.registerLazySingleton<DriverProfileLocalDataSource>(
    () => DriverProfileLocalDataSourceImpl(),
  );

  // Profile Management - Repositories
  sl.registerLazySingleton<DriverProfileRepository>(
    () => DriverProfileRepositoryImpl(localDataSource: sl()),
  );

  // Profile Management - Use Cases
  sl.registerLazySingleton(() => GetDriverProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateDriverProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDriverProfileUseCase(sl()));
  sl.registerLazySingleton(() => ContactAdminUseCase(sl()));

  // Trips Management - Data Sources
  sl.registerLazySingleton<DriverTripsLocalDataSource>(
    () => DriverTripsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<DriverTripsRemoteDataSource>(
    () => DriverTripsRemoteDataSourceImpl(),
  );

  // Trips Management - Repositories
  sl.registerLazySingleton<DriverTripsRepository>(
    () => DriverTripsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Trips Management - Use Cases
  sl.registerLazySingleton(() => GetCurrentTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetTripHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsByStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetTripPassengersUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePassengerStatusUseCase(sl()));
  sl.registerLazySingleton(() => NotifyPassengerArrivalUseCase(sl()));
  sl.registerLazySingleton(() => StartTripUseCase(sl()));
  sl.registerLazySingleton(() => CompleteTripUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripStatusUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => DriverProfileBloc(
        getDriverProfileUseCase: sl(),
        createDriverProfileUseCase: sl(),
        updateDriverProfileUseCase: sl(),
        contactAdminUseCase: sl(),
        logoutUseCase: sl(),
      ));
  sl.registerFactory(() => DriverTripsBloc(
        getCurrentTripsUseCase: sl(),
        getTripHistoryUseCase: sl(),
        getTripPassengersUseCase: sl(),
        updatePassengerStatusUseCase: sl(),
        notifyPassengerArrivalUseCase: sl(),
        startTripUseCase: sl(),
        completeTripUseCase: sl(),
        getTripsByStatusUseCase: sl(),
        updateTripStatusUseCase: sl(),
      ));
}
