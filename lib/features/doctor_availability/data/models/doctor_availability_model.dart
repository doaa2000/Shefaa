import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';

class DoctorSessionModel extends DoctorSessionEntity {
  const DoctorSessionModel({
    required super.session,
    required super.startTime,
    required super.endTime,
    required super.capacity,
    required super.booked,
    required super.remaining,
  });

  /// One row of `doctor_sessions_on(doctor, date)`.
  factory DoctorSessionModel.fromMap(Map<String, dynamic> map) {
    return DoctorSessionModel(
      session:   map['session'] as String,
      startTime: map['start_time'] as String,
      endTime:   map['end_time'] as String,
      capacity:  (map['capacity'] as num).toInt(),
      // `booked` is a count, which Postgres returns as bigint; over the wire it
      // can arrive as either a number or a string.
      booked:    _asInt(map['booked']),
      remaining: _asInt(map['remaining']),
    );
  }

  static int _asInt(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Formats "17:00:00" as "5:00 م".
  String get formattedStart => formatTime(startTime);
  String get formattedEnd => formatTime(endTime);

  static String formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $period';
  }
}
