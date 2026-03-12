import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
Future<Either<Failure, UserEntity>> getProfile({required String userId});

//Future<Either<Failure, void>> updateProfile(UserEntity user);
}