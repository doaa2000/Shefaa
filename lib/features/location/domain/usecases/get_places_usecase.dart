import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/location/domain/entities/place.dart';
import 'package:shefaa_app/features/location/domain/repositories/location_repository.dart';

class GetGovernoratesUseCase
    extends BaseUsecase<List<PlaceEntity>, NoParameters> {
  final LocationRepository repository;

  GetGovernoratesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlaceEntity>>> call(NoParameters params) {
    return repository.getGovernorates();
  }
}

class GetCitiesUseCase extends BaseUsecase<List<PlaceEntity>, int> {
  final LocationRepository repository;

  GetCitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlaceEntity>>> call(int governorateId) {
    return repository.getCities(governorateId);
  }
}
