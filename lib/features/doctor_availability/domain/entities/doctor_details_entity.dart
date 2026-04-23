import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

// doctor_details_entity.dart
class DoctorDetailsEntity {
  final DoctorEntity doctor;
  final List<DoctorAvailabilityEntity> morningSlots; // ✅ replaces availability
  final List<DoctorAvailabilityEntity> eveningSlots; // ✅ new

  DoctorDetailsEntity({
    required this.doctor,
    required this.morningSlots,
    required this.eveningSlots,
  });
}