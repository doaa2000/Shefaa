import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import '../entities/doctor_availability.dart';

abstract class DoctorAvailabilityRepository {
  Future<Either<Failure, List<DoctorAvailabilityEntity>>> getDoctorAvailability(
    String doctorId,
  );
}
