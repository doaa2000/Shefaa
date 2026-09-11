import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/screens/update_profile_screen.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/logout_button.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/profile_header_card.dart';
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

    return BlocProvider(
      create: (context) {
        final bloc = getIt<ProfileBloc>();
        if (userId != null) bloc.add(GetProfileEvent(userId: userId));
        return bloc;
      },
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Builder so the tap handler gets a context below BlocProvider
              // and can refresh the header with whatever was just saved.
              Builder(
                builder: (innerContext) => GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(
                      innerContext,
                      UpdateProfileScreen.routeName,
                    );
                    if (!innerContext.mounted || userId == null) return;
                    innerContext
                        .read<ProfileBloc>()
                        .add(GetProfileEvent(userId: userId));
                  },
                  child: const ProfileHeaderCard(),
                ),
              ),
              const SizedBox(height: 20),
              const SettingsCard(),
              const SizedBox(height: 20),
              const SupportCard(),
              const SizedBox(height: 25),
              const LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
