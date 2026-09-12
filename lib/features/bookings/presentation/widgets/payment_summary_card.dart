import 'package:flutter/material.dart';
import 'package:shefaa_app/core/widgets/card_container.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.booking});

  final BookingEntity booking;

  static const Map<String, String> _methodLabels = {
    'cash': 'نقداً في العيادة',
    'vodafone_cash': 'فودافون كاش',
    'card': 'بطاقة',
  };

  @override
  Widget build(BuildContext context) {
    final payment = booking.payment;
    final method = _methodLabels[payment.paymentMethod] ?? payment.paymentMethod;
    final amount = '${payment.amount.toStringAsFixed(0)} جنيه';

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الدفع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          // One line, no invented tax: the patient pays the doctor's fee and
          // nothing else. The app's commission is settled with the clinic, not
          // added on top of the visit.
          _PriceRow(title: 'رسوم الكشف', price: amount),
          const SizedBox(height: 8),
          _PriceRow(title: 'طريقة الدفع', price: method),
          const Divider(height: 24),
          _PriceRow(title: 'الإجمالي', price: amount, isTotal: true),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: payment.isPaid ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payment.isPaid
                  ? 'تم الدفع'
                  : 'يُدفع المبلغ في العيادة يوم الكشف',
              style: TextStyle(
                color: payment.isPaid
                    ? Colors.green.shade800
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String price;
  final bool isTotal;

  const _PriceRow({
    required this.title,
    required this.price,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
