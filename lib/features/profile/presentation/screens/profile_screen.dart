import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/logout_button.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/quick_action_card.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/settings_card.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/support_card.dart';
import 'package:shefaa_app/generated/l10n.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ProfileHeaderCard(),
            SizedBox(height: 25),
            QuickActionsRow(),
            SizedBox(height: 30),
            //    SectionTitle(title: "الحساب"),
            SizedBox(height: 10),
            SettingsCard(),
            SizedBox(height: 25),
            // SectionTitle(title: "الدعم"),
            SizedBox(height: 10),
            SupportCard(),
            SizedBox(height: 25),
            LogoutButton(),
          ],
        ),
      ),
    );
  }
}
