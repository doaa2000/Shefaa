import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/home/domain/entities/specialty.dart';
import 'package:shefaa_app/features/home/domain/repositories/home_repository.dart';

class GetSpecialtiesUsecase
    extends BaseUsecase<List<SpecialtyEntity>, NoParameters> {
  final HomeRepository homeRepository;

  GetSpecialtiesUsecase(this.homeRepository);

  @override
  Future<Either<Failure, List<SpecialtyEntity>>> call(NoParameters params) async {
    return await homeRepository.getSpecialties();
  }
}