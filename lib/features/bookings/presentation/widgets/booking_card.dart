import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/booking_action_toggle.dart';
class BookingCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final double amount;
  final String paymentMethod;

  const BookingCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(doctorName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(specialty,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Divider(height: 20),
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(date, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            const Icon(Icons.access_time_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(time, style: const TextStyle(fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.payment_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(paymentMethod == 'cash' ? 'كاش' : 'انستا باي',
                    style: const TextStyle(fontSize: 12)),
              ]),
              Text('${amount.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      'confirmed': ('قادم',     const Color(0xFFEBF6FB), const Color(0xFF0C447C)),
      'completed': ('مكتمل',   const Color(0xFFEAF3DE), const Color(0xFF27500A)),
      'cancelled': ('ملغي',    const Color(0xFFFCEBEB), const Color(0xFF791F1F)),
    };
    final (label, bg, fg) = map[status] ?? ('غير معروف', Colors.grey.shade100, Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: fg)),
    );
  }
}