import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/banners/domain/entities/banner.dart';

abstract class BannersRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();
}
