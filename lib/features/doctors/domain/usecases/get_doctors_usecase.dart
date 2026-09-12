import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor_schedule.dart';
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
  final int specialtyId;

  GetDoctorsUsecaseParameters({required this.specialtyId});
}

class GetDoctorScheduleUseCase
    extends BaseUsecase<List<DoctorScheduleEntity>, int> {
  final DoctorsRepository repository;

  GetDoctorScheduleUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorScheduleEntity>>> call(int doctorId) {
    return repository.getWeeklySchedule(doctorId);
  }
}

class SearchDoctorsUseCase extends BaseUsecase<List<DoctorEntity>, String> {
  final DoctorsRepository repository;

  SearchDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(String query) {
    return repository.searchDoctors(query);
  }
}
