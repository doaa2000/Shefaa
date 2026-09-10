import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

abstract class DoctorsRepository {
  Future<Either<Failure, List<DoctorEntity>>> getDoctors(
    int specialtyId,
  );
}