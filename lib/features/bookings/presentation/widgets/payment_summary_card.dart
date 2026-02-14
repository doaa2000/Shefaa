import 'package:flutter/material.dart';
import 'package:shefaa_app/core/widgets/card_container.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ملخص الدفع",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const _PriceRow(title: "رسوم الكشف", price: "300 ريال"),
          const SizedBox(height: 8),
          const _PriceRow(title: "الضريبة (15%)", price: "45 ريال"),
          const Divider(height: 24),
          const _PriceRow(title: "الإجمالي", price: "345 ريال", isTotal: true),
          const SizedBox(height: 12),
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: Colors.green.shade100,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: const Text(
          //     "تم الدفع بنجاح باستخدام Visa **** 4242",
          //     style: TextStyle(color: Colors.green),
          //   ),
          // )
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
