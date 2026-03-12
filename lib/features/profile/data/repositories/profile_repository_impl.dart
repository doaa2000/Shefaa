import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:shefaa_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileRepositoryImpl(this.profileRemoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> getProfile({required String userId}) async {
    try {
      final user = await profileRemoteDataSource.getProfile(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // @override
  // Future<Either<Failure, void>> updateProfile(UserEntity user) async {
  //   try {
  //     await profileRemoteDataSource.updateProfile(user);
  //     return const Right(null);
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }
}