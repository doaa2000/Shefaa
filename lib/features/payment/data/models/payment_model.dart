import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.paymentMethod,
    required super.status,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      status: map['status'] as String? ?? 'pending',
    );
  }
}
