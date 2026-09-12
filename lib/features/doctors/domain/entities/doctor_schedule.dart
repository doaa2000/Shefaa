import 'package:equatable/equatable.dart';

/// One line of a doctor's weekly pattern: a session they hold on a weekday.
///
/// This is the pattern, not a bookable day. What is actually open on a given
/// date comes from `doctor_sessions_on`, which applies that date's exceptions.
/// This is here so a patient can see when a doctor generally works before
/// picking a date at all.
class DoctorScheduleEntity extends Equatable {
  /// 0 = Sunday .. 6 = Saturday, matching Postgres `extract(dow)`.
  final int weekday;

  /// 'morning' or 'evening'.
  final String session;

  final String startTime;
  final String endTime;
  final int capacity;

  const DoctorScheduleEntity({
    required this.weekday,
    required this.session,
    required this.startTime,
    required this.endTime,
    required this.capacity,
  });

  bool get isMorning => session == 'morning';

  @override
  List<Object?> get props => [weekday, session, startTime, endTime, capacity];
}
