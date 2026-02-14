import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const SettingsTile({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
