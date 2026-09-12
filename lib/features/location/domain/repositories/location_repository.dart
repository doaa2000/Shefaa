import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/location/domain/entities/place.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<PlaceEntity>>> getGovernorates();

  Future<Either<Failure, List<PlaceEntity>>> getCities(int governorateId);
}
