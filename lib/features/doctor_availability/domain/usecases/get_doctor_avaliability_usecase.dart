import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_details_model.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_details_entity.dart';
import '../entities/doctor_availability.dart';
import '../repositories/doctor_availability_repository.dart';

class GetDoctorAvailabilityUsecase
    extends
        BaseUsecase<
          DoctorDetailsEntity,
          GetDoctorAvailabilityUsecaseParameters
        > {
  final DoctorAvailabilityRepository repository;

  GetDoctorAvailabilityUsecase(this.repository);

  @override
  Future<Either<Failure, DoctorDetailsEntity>> call(
    GetDoctorAvailabilityUsecaseParameters params,
  ) async {
    return await repository.getDoctorAvailability(params.doctorId,   params.date,);
  }
}

class GetDoctorAvailabilityUsecaseParameters {
  final int doctorId;
  final DateTime date;

  GetDoctorAvailabilityUsecaseParameters({required this.doctorId, required this.date});
}
