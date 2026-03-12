import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase extends BaseUsecase<UserEntity, LoginUseCaseParameters> {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginUseCaseParameters params) async =>
      await authRepository.login(
        email: params.email,
        password: params.password,
      );
}

class LoginUseCaseParameters {
  final String email;
  final String password;

  LoginUseCaseParameters({required this.email, required this.password});
}
