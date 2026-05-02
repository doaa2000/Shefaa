class PaymentEntity {
  final int id;
  final double amount;
  final String paymentMethod;
  final String status;

  PaymentEntity({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });
}
