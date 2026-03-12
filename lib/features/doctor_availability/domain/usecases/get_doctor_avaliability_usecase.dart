import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import '../entities/doctor_availability.dart';
import '../repositories/doctor_availability_repository.dart';

class GetDoctorAvailabilityUsecase
    extends
        BaseUsecase<
          List<DoctorAvailabilityEntity>,
          GetDoctorAvailabilityUsecaseParameters
        > {
  final DoctorAvailabilityRepository repository;

  GetDoctorAvailabilityUsecase(this.repository);

  @override
  Future<Either<Failure, List<DoctorAvailabilityEntity>>> call(
    GetDoctorAvailabilityUsecaseParameters params,
  ) async {
    return await repository.getDoctorAvailability(params.doctorId);
  }
}

class GetDoctorAvailabilityUsecaseParameters {
  final String doctorId;

  GetDoctorAvailabilityUsecaseParameters({required this.doctorId});
}
