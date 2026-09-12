import 'package:shefaa_app/features/doctors/domain/entities/doctor_schedule.dart';

class DoctorScheduleModel extends DoctorScheduleEntity {
  const DoctorScheduleModel({
    required super.weekday,
    required super.session,
    required super.startTime,
    required super.endTime,
    required super.capacity,
  });

  factory DoctorScheduleModel.fromMap(Map<String, dynamic> map) {
    return DoctorScheduleModel(
      weekday: (map['weekday'] as num).toInt(),
      session: map['session'] as String? ?? 'morning',
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
    );
  }
}
