class PaymentEntity {
  final int id;
  final double amount;
  final String paymentMethod;

  /// 'pending' until the money is actually collected at the clinic, then
  /// 'paid'. With cash, a booking is not revenue on the day it is made.
  final String status;

  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });

  bool get isPaid => status == 'paid';
}
