import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/delete_account_button.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/logout_button.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/settings_card.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/support_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static String? get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    final userId = _currentUserId;

    // No session means every query comes back empty rather than failing, so
    // without this the screen would just render a profile with no name on it
    // and no hint as to why.
    if (userId == null) return const _SignedOut();

    // The bloc comes from HomeScreen rather than being created here. Two of
    // them meant the name in the home bar stayed as it was until the app was
    // restarted, because the copy that reloaded after an edit was this one.
    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The header card that used to sit here showed the photograph, the
            // name and the email -- all of which the home bar already shows on
            // every screen. It was also the only way into the edit screen,
            // which is why it went after "إعدادات الحساب" started opening it.
            const SettingsCard(),
            const SizedBox(height: 20),
            const SupportCard(),
            const SizedBox(height: 25),
            const LogoutButton(),
            const SizedBox(height: 8),
            const DeleteAccountButton(),
          ],
        ),
      ),
    );
  }
}


class _SignedOut extends StatelessWidget {
  const _SignedOut();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              ),
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}
