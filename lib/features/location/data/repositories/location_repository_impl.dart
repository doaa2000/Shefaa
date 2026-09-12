import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/location/data/datasources/location_remote_datasource.dart';
import 'package:shefaa_app/features/location/domain/entities/place.dart';
import 'package:shefaa_app/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDatasource remoteDatasource;

  LocationRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<PlaceEntity>>> getGovernorates() async {
    try {
      return Right(await remoteDatasource.getGovernorates());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlaceEntity>>> getCities(int governorateId) async {
    try {
      return Right(await remoteDatasource.getCities(governorateId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
