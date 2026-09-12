import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase extends BaseUsecase<Unit, NoParameters> {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  @override
  Future<Either<Failure, Unit>> call(NoParameters params) async {
    return await authRepository.logout();
  }
}