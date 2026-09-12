import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase
    extends BaseUsecase<UserEntity, GetProfileUseCaseParams> {
  final ProfileRepository profileRepository;

  GetProfileUseCase(this.profileRepository);

  @override
  Future<Either<Failure, UserEntity>> call(
    GetProfileUseCaseParams params,
  ) async {
    return await profileRepository.getProfile(userId: params.userId);
  }
}

class GetProfileUseCaseParams {
  final String userId;

  GetProfileUseCaseParams({required this.userId});
}

class UpdateProfileUseCase
    extends BaseUsecase<UserEntity, UpdateProfileUseCaseParams> {
  final ProfileRepository profileRepository;

  UpdateProfileUseCase(this.profileRepository);

  @override
  Future<Either<Failure, UserEntity>> call(
    UpdateProfileUseCaseParams params,
  ) async {
    return await profileRepository.updateProfile(
      user: params.user,
      newPassword: params.newPassword,
    );
  }
}

class UpdateProfileUseCaseParams {
  final UserEntity user;
  final String? newPassword;

  UpdateProfileUseCaseParams({required this.user, this.newPassword});
}

class UpdateAvatarUseCase
    extends BaseUsecase<UserEntity, UpdateAvatarUseCaseParams> {
  final ProfileRepository profileRepository;

  UpdateAvatarUseCase(this.profileRepository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateAvatarUseCaseParams params) {
    return profileRepository.updateAvatar(
      userId: params.userId,
      bytes: params.bytes,
      extension: params.extension,
      contentType: params.contentType,
    );
  }
}

class UpdateAvatarUseCaseParams {
  final String userId;
  final List<int> bytes;
  final String extension;
  final String? contentType;

  UpdateAvatarUseCaseParams({
    required this.userId,
    required this.bytes,
    required this.extension,
    this.contentType,
  });
}
