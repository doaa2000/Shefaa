import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctor_availability/data/datasources/doctor_availability_remote_datasource.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_details_entity.dart';
import 'package:shefaa_app/features/doctor_availability/domain/repositories/doctor_availability_repository.dart';


class DoctorAvailabilityRepositoryImpl implements DoctorAvailabilityRepository {
  final DoctorAvailabilityRemoteDatasource remoteDatasource;

  DoctorAvailabilityRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, DoctorDetailsEntity>> getDoctorAvailability(
    int doctorId,
    DateTime date, // ✅ add date
  ) async {
    try {
      final availability = await remoteDatasource.getDoctorAvailability(
        doctorId,
        date, // ✅ pass date
      );
      return Right(availability);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}