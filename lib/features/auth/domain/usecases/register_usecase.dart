import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase extends BaseUsecase<UserEntity, RegisterUseCaseParameters> {
  final AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterUseCaseParameters params) async =>
      await authRepository.register(
        email: params.email,
        password: params.password,
        name: params.name,
        phone: params.phone,
        birthDate: params.birthDate,
        gender: params.gender,
        healthConsentVersion: params.healthConsentVersion,
      );
}

class RegisterUseCaseParameters {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String ?birthDate;
  final String ?gender;

  /// Sent as signup metadata; the database trigger turns it into the consent
  /// row, because there is no session to write one with.
  final String healthConsentVersion;

  RegisterUseCaseParameters({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.healthConsentVersion,
    this.birthDate,
    this.gender,
  });
}
