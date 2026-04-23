import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_details_entity.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';

class DoctorDetailsModel extends DoctorDetailsEntity {
  DoctorDetailsModel({
    required super.doctor,
    required super.morningSlots,
    required super.eveningSlots,
  });

  factory DoctorDetailsModel.fromMap(Map<String, dynamic> map) {
    // ✅ Parse all slots
    final allSlots = (map['doctor_availability'] as List? ?? [])
        .map((e) => DoctorAvailabilityModel.fromMap(e))
        .toList();

    // ✅ Group by session
    final morning = allSlots
        .where((s) => s.session == 'morning')
        .toList();

    final evening = allSlots
        .where((s) => s.session == 'evening')
        .toList();

    return DoctorDetailsModel(
      doctor:       DoctorModel.fromMap(map),
      morningSlots: morning,
      eveningSlots: evening,
    );
  }
}