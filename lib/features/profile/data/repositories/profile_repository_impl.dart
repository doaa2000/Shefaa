import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/data/models/user_model.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:shefaa_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileRepositoryImpl(this.profileRemoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> getProfile({
    required String userId,
  }) async {
    try {
      final user = await profileRemoteDataSource.getProfile(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(_messageOf(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required UserEntity user,
    String? newPassword,
  }) async {
    try {
      // The password goes first on purpose: Supabase rejects one that is too
      // short or unchanged, and a rejection there should leave the profile row
      // untouched rather than half saved.
      if (newPassword != null && newPassword.isNotEmpty) {
        await profileRemoteDataSource.updatePassword(newPassword);
      }

      final updated = await profileRemoteDataSource.updateProfile(
        UserModel(
          id: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          gender: user.gender,
          birthDate: user.birthDate,
        ),
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(_messageOf(e)));
    }
  }

  /// Supabase errors stringify as `AuthApiException(message: ..., statusCode:
  /// 422)`, which is not something to put in front of a patient. Pull the
  /// human sentence out when there is one.
  String _messageOf(Object error) {
    if (error is AuthException) return error.message;
    if (error is PostgrestException) return error.message;
    return error.toString();
  }
}
