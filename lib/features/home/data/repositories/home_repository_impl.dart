import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/home/data/datasources/home_remote_datasource.dart';
import 'package:shefaa_app/features/home/domain/entities/specialty.dart';
import 'package:shefaa_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource homeRemoteDataSource;

  HomeRepositoryImpl(this.homeRemoteDataSource);

  @override
  Future<Either<Failure, List<SpecialtyEntity>>> getSpecialties() async {
    try {
      final specialties = await homeRemoteDataSource.getSpecialties();

      return Right(specialties.map((e) => e as SpecialtyEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
