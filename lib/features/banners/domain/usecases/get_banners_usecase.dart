import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/banners/domain/entities/banner.dart';
import 'package:shefaa_app/features/banners/domain/repositories/banners_repository.dart';

class GetBannersUseCase extends BaseUsecase<List<BannerEntity>, NoParameters> {
  final BannersRepository repository;

  GetBannersUseCase(this.repository);

  @override
  Future<Either<Failure, List<BannerEntity>>> call(NoParameters params) {
    return repository.getBanners();
  }
}
