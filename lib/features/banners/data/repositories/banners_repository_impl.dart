import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/banners/data/datasources/banners_remote_datasource.dart';
import 'package:shefaa_app/features/banners/domain/entities/banner.dart';
import 'package:shefaa_app/features/banners/domain/repositories/banners_repository.dart';

class BannersRepositoryImpl implements BannersRepository {
  final BannersRemoteDatasource remoteDatasource;

  BannersRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      return Right(await remoteDatasource.getBanners());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
