/// One bookable window of a doctor's day, as returned by the
/// `doctor_sessions_on` function.
///
/// How long a window is belongs to the doctor: a session left whole is one
/// window from its start to its end, and a session with a slot length set is
/// cut into windows of that length. Either way it is a window to arrive in,
/// not a minute the doctor promises to be free.
class DoctorSessionEntity {
  /// 'morning' or 'evening'.
  final String session;

  /// The window itself, e.g. 17:00:00 – 21:00:00.
  final String startTime;
  final String endTime;

  /// How many patients the doctor takes in this window.
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
}
