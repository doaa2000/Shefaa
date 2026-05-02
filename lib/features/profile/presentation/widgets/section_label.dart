import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyles.bold14.copyWith(color: theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }
}