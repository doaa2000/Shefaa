
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: TextStyles.medium14.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
    );
  }
}