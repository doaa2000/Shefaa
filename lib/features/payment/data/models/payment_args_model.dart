/// What the availability screen hands to the payment screen.
class PaymentArgsModel {
  final int doctorId;
  final String doctorName;

  final DateTime date;

  /// 'morning' or 'evening'.
  final String session;

  /// The window the patient is asked to arrive in, kept so the booking records
  /// the times it was made against even if the doctor later changes their
  /// schedule.
  final String startTime;
  final String endTime;

  final double amount;

  const PaymentArgsModel({
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.session,
    required this.startTime,
    required this.endTime,
    required this.amount,
  });
}
