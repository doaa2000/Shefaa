import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

/// A doctor together with what they have open on one date.
class DoctorDetailsEntity {
  final DoctorEntity doctor;

  /// The sessions open on the selected date, morning first. Empty means the
  /// doctor does not work that day, or the day is fully booked out.
  final List<DoctorSessionEntity> sessions;

  const DoctorDetailsEntity({required this.doctor, required this.sessions});

  DoctorSessionEntity? get morning =>
      sessions.where((s) => s.isMorning).firstOrNull;

  DoctorSessionEntity? get evening =>
      sessions.where((s) => !s.isMorning).firstOrNull;

  bool get hasAnySession => sessions.isNotEmpty;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
