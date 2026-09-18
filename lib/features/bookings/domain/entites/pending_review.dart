/// A visit the patient has not rated yet, and is old enough to be asked about.
///
/// The question is asked inside the app rather than by notification: the
/// notifications this app sends are about appointments, every one of them
/// worth interrupting somebody for, and a request to rate a doctor is not.
class PendingReviewEntity {
  final int bookingId;
  final int doctorId;
  final String doctorName;

  const PendingReviewEntity({
    required this.bookingId,
    required this.doctorId,
    required this.doctorName,
  });

  factory PendingReviewEntity.fromMap(Map<String, dynamic> map) {
    return PendingReviewEntity(
      bookingId: (map['bookingId'] as num).toInt(),
      doctorId: (map['doctorId'] as num).toInt(),
      doctorName: map['doctorName'] as String? ?? 'الطبيب',
    );
  }
}
