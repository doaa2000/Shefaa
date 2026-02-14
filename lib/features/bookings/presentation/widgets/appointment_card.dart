import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/widgets/card_container.dart';
import 'package:shefaa_app/generated/l10n.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context).your_appointment,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("مؤكد"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AppointmentRow(
            icon: Icons.calendar_month,
            title: "التاريخ",
            value: "الأحد 28 يوليو 2024",
          ),
          const SizedBox(height: 12),
          _AppointmentRow(
            icon: Icons.access_time,
            title: "الوقت",
            value: "10:30 صباحاً - 11:00 صباحاً",
          ),
          const SizedBox(height: 12),
          _AppointmentRow(
            icon: Icons.confirmation_number,
            title: "رقم الحجز",
            value: "BOK-1721-CLNC",
          ),
        ],
      ),
    );
  }
}



class _AppointmentRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AppointmentRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
