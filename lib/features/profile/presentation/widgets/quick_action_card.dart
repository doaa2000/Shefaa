import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: .05),
            )
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        QuickActionCard(
          icon: Icons.credit_card,
          color: Colors.purple,
          title: "الدفع",
        ),
        QuickActionCard(
          icon: Icons.shield,
          color: Colors.green,
          title: "تأميناتي",
        ),
        QuickActionCard(
          icon: Icons.calendar_month,
          color: Colors.blue,
          title: "مواعيدي",
        ),
      ],
    );
  }
}
