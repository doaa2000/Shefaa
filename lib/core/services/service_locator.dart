import 'package:get_it/get_it.dart';
import 'package:shefaa_app/core/services/secure_storage_service.dart';
import 'package:shefaa_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shefaa_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shefaa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shefaa_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:shefaa_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shefaa_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/doctor_availability/data/datasources/doctor_availability_remote_datasource.dart';
import 'package:shefaa_app/features/doctor_availability/data/repositories/doctor_availability_repository_impl.dart';
import 'package:shefaa_app/features/doctor_availability/domain/repositories/doctor_availability_repository.dart';
import 'package:shefaa_app/features/doctor_availability/domain/usecases/get_doctor_avaliability_usecase.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/bloc/doctor_availability_bloc.dart';
import 'package:shefaa_app/features/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:shefaa_app/features/doctors/data/repositories/doctors_repository_impl.dart';
import 'package:shefaa_app/features/doctors/domain/repositories/doctors_repository.dart';
import 'package:shefaa_app/features/doctors/domain/usecases/get_doctors_usecase.dart';
import 'package:shefaa_app/features/doctors/presentation/bloc/doctors_bloc.dart';
import 'package:shefaa_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:shefaa_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:shefaa_app/features/home/domain/repositories/home_repository.dart';
import 'package:shefaa_app/features/home/domain/usecases/get_specialties_usecase.dart';
import 'package:shefaa_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:shefaa_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:shefaa_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shefaa_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shefaa_app/features/profile/domain/usecases/profile_usecase.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // 1️⃣ SupabaseClient
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2️⃣ Remote Data Source
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt()),

  );
getIt.registerLazySingleton<HomeRemoteDatasource>(
    () => HomeRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<DoctorsRemoteDatasource>(
    () => DoctorsRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<DoctorAvailabilityRemoteDatasource>(
    () => DoctorAvailabilityRemoteDatasourceImpl(getIt()),
  );
  // 3️⃣ Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt()),

  );

  getIt.registerLazySingleton<DoctorsRepository>(
    () => DoctorsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<DoctorAvailabilityRepository>(
    () => DoctorAvailabilityRepositoryImpl(getIt()),
  );
  // 4️⃣ UseCases
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));

  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(getIt()));
getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(getIt()));

  getIt.registerLazySingleton<GetSpecialtiesUsecase>(
    () => GetSpecialtiesUsecase(getIt()),
  );

  getIt.registerLazySingleton<GetDoctorsUseCase>(
    () => GetDoctorsUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetDoctorAvailabilityUsecase>(
    () => GetDoctorAvailabilityUsecase(getIt()),
  );
  // 5️⃣ Bloc
  getIt.registerFactory<DoctorsBloc>(
    () => DoctorsBloc(getDoctorsUseCase: getIt()),
  );
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(loginUseCase: getIt(), registerUseCase: getIt(), secureStorageService: getIt(), logoutUseCase: getIt()),
  );
getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getProfileUseCase: getIt()),
  );
getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getSpecialtiesUsecase: getIt()),
  );
  getIt.registerLazySingleton<SecureStorageService>(
  () => SecureStorageService(),
);

getIt.registerFactory<DoctorAvailabilityBloc>(
    () => DoctorAvailabilityBloc(getDoctorAvailabilityUsecase: getIt()),
  );
}
