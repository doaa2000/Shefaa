import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    String? birthDate,
    String? gender,
    required String name,
    required String phone,
  }) async {
    try {
      final user = await authRemoteDataSource.register(
        email: email,
        password: password,
        birthDate: birthDate,
        gender: gender,
        name: name,
        phone: phone,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

    @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await authRemoteDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
