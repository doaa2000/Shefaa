import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    required super.id,
    required super.amount,
    required super.paymentMethod,
    required super.status,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id:            map['id'],
      amount:        (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'],
      status:        map['status'],
    );
  }
}