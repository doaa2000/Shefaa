import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_details_entity.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';

class DoctorDetailsModel extends DoctorDetailsEntity {
  const DoctorDetailsModel({required super.doctor, required super.sessions});

  /// Built from two sources: the doctor row, and the rows returned by
  /// `doctor_sessions_on` for the selected date.
  factory DoctorDetailsModel.fromParts({
    required Map<String, dynamic> doctorRow,
    required List<dynamic> sessionRows,
  }) {
    final sessions = sessionRows
        .map((e) => DoctorSessionModel.fromMap(e as Map<String, dynamic>))
        .toList()
      // Morning before evening, whatever order the function returned.
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return DoctorDetailsModel(
      doctor: DoctorModel.fromMap(doctorRow),
      sessions: sessions,
    );
  }
}
