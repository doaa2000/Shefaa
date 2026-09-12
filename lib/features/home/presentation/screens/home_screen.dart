import 'package:flutter/material.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:shefaa_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:shefaa_app/features/home/presentation/widgets/home_app_bar.dart';
import 'package:shefaa_app/features/home/presentation/widgets/home_page_widget.dart';
import 'package:shefaa_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.initialTab = homeTab});

  /// Which tab to open on. Confirming a booking sends the patient straight to
  /// [bookingsTab]; without this the screen always opened on the home tab and
  /// the "حجوزاتي" button appeared to do nothing.
  final int initialTab;

  static const int homeTab = 0;
  static const int bookingsTab = 1;
  static const int profileTab = 2;

  static const String routeName = AppRoutes.home;

  List<Widget> _pages(BuildContext context) {
    return [
      HomePageWidget(),
      BookingsScreen(),
     ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>()
            ..add(GetSpecialtiesEvent())
            ..add(HomePageChanged(initialTab)),
        ),
        // Above the tab switch, not inside the app bar: the bar is thrown away
        // and rebuilt every time the patient leaves the home tab, and a bloc
        // created there would re-read the profile on every trip back.
        BlocProvider(
          create: (_) {
            final bloc = getIt<ProfileBloc>();
            if (userId != null) bloc.add(GetProfileEvent(userId: userId));
            return bloc;
          },
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final pages = _pages(context);
          return Scaffold(
            appBar:
                state.currentIndex == 0
                    ? HomeAppBar()
                    : CustomAppBar(title: ''),
            body: pages[state.currentIndex],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: state.currentIndex,
              onTap: (index) {
                context.read<HomeBloc>().add(HomePageChanged(index));
              },
            ),
          );
        },
      ),
    );
  }
}
