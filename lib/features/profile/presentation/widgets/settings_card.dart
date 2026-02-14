import 'package:flutter/material.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/settings_tile.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.05)),
        ],
      ),
      child: const Column(
        children: [
          SettingsTile(title: "إعدادات الحساب", icon: Icons.settings),
          SettingsTile(title: "الإشعارات", icon: Icons.notifications_none),
          SettingsTile(
            title: "السجلات الطبية",
            icon: Icons.description_outlined,
          ),
        ],
      ),
    );
  }
}
