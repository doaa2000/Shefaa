import 'package:flutter/material.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/settings_tile.dart';

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

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
          SettingsTile(title: "المساعدة والدعم", icon: Icons.help_outline),
          SettingsTile(title: "عن التطبيق", icon: Icons.info_outline),
                    SettingsTile(title: "عن المطور", icon: Icons.info_outline),

        ],
      ),
    );
  }
}
