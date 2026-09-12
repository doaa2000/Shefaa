import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile({required String userId});

  /// Saves the editable profile fields, and the account password too when
  /// [newPassword] is given. Returns the profile as it now stands so the
  /// caller can show the saved values without a second round trip.
  Future<Either<Failure, UserEntity>> updateProfile({
    required UserEntity user,
    String? newPassword,
  });

  /// Stores a photograph and puts it on the profile. Returns the profile as it
  /// now stands.
  Future<Either<Failure, UserEntity>> updateAvatar({
    required String userId,
    required List<int> bytes,
    required String extension,
    String? contentType,
  });
}
