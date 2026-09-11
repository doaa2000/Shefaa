/// One bookable session of a doctor's day, as returned by the
/// `doctor_sessions_on` function.
///
/// This replaces the old per-slot entity. The clinic runs a queue, not a
/// timetable: a patient takes a place in a session rather than a specific
/// 30-minute appointment the doctor was never going to keep to.
class DoctorSessionEntity {
  /// 'morning' or 'evening'.
  final String session;

  /// The window the session runs, e.g. 17:00:00 – 21:00:00.
  final String startTime;
  final String endTime;

  /// How many patients the doctor takes in this session.
  final int capacity;

  /// How many places are already taken.
  final int booked;

  /// What is left. Zero means the session is full.
  final int remaining;

  const DoctorSessionEntity({
    required this.session,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.booked,
    required this.remaining,
  });

  bool get isFull => remaining <= 0;

  bool get isMorning => session == 'morning';

  /// The place this patient would take if they booked now: everyone already
  /// booked is ahead of them.
  int get nextQueueNumber => booked + 1;
}
