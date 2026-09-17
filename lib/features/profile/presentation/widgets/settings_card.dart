import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/screens/update_profile_screen.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/settings_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: .05)),
        ],
      ),
      child: Column(
        children: [
          // The same screen the header card opens, named. Tapping a picture of
          // yourself is not an obvious way to reach the place your password is
          // changed, and this row is where somebody looks for it.
          //
          // "تقييم التطبيق" used to sit underneath and do nothing. It needs a
          // store listing to open, and there is not one yet.
          SettingsTile(
            title: "إعدادات الحساب",
            icon: Icons.settings,
            onTap: () => _openAccountSettings(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openAccountSettings(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    await Navigator.pushNamed(context, UpdateProfileScreen.routeName);
    // Re-read on the way back, as the header card does: the copy shown here is
    // the one the home bar reads its name from.
    if (userId != null) bloc.add(GetProfileEvent(userId: userId));
  }
}
