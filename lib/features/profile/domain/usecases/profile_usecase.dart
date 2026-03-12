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
