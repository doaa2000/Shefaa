import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/home/domain/entities/specialty.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<SpecialtyEntity>>> getSpecialties();
}