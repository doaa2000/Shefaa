class PaymentArgsModel {
  final String slotId;
  final double amount;
  final String doctorName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String doctorId;

  PaymentArgsModel({
    required this.slotId,
    required this.amount,
    required this.doctorName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.doctorId,
  });
}