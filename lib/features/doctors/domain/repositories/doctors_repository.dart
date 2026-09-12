import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor_schedule.dart';

abstract class DoctorsRepository {
  Future<Either<Failure, List<DoctorEntity>>> getDoctors(
    int specialtyId,
  );

  Future<Either<Failure, List<DoctorScheduleEntity>>> getWeeklySchedule(
    int doctorId,
  );
}