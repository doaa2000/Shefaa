import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/repositories/doctors_repository.dart';

class GetDoctorsUseCase
    extends BaseUsecase<List<DoctorEntity>, GetDoctorsUsecaseParameters> {
  final DoctorsRepository repository;

  GetDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(
    GetDoctorsUsecaseParameters params,
  ) {
    return repository.getDoctors(params.specialtyId);
  }
}

class GetDoctorsUsecaseParameters {
  final String specialtyId;

  GetDoctorsUsecaseParameters({required this.specialtyId});
}
