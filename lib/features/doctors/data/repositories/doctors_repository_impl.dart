import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor_schedule.dart';

import 'package:shefaa_app/features/doctors/domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDatasource remoteDatasource;

  DoctorsRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctors(
    int specialtyId,
  ) async {
    try {
      final doctors =
          await remoteDatasource.getDoctors(specialtyId);
      return Right(doctors);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DoctorScheduleEntity>>> getWeeklySchedule(
    int doctorId,
  ) async {
    try {
      return Right(await remoteDatasource.getWeeklySchedule(doctorId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
