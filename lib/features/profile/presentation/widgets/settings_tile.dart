import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;

  /// Null leaves the row inert, which is what most of these still are. A row
  /// that does nothing should not look pressable either, so the arrow goes
  /// with the tap.
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: onTap == null
          ? null
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
