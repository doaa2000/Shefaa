import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_details_entity.dart';
// doctor_availability_repository.dart
abstract class DoctorAvailabilityRepository {
  Future<Either<Failure, DoctorDetailsEntity>> getDoctorAvailability(
    int doctorId,
    DateTime date, // ✅ add date
  );
}