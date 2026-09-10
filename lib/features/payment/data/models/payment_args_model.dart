/// What the availability screen hands to the payment screen.
class PaymentArgsModel {
  final int doctorId;
  final String doctorName;

  final DateTime date;

  /// 'morning' or 'evening'. Replaces the slot id: a patient books a place in
  /// a session, not a specific minute.
  final String session;

  /// The session window, kept so the booking records the times it was made
  /// against even if the doctor later changes their schedule.
  final String startTime;
  final String endTime;

  /// The place the patient will hold if they confirm.
  final int queueNumber;

  final double amount;

  const PaymentArgsModel({
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.session,
    required this.startTime,
    required this.endTime,
    required this.queueNumber,
    required this.amount,
  });
}
