import 'package:flutter/material.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:shefaa_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:shefaa_app/features/home/presentation/widgets/home_app_bar.dart';
import 'package:shefaa_app/features/home/presentation/widgets/home_page_widget.dart';
import 'package:shefaa_app/features/home/presentation/widgets/custom_bottom_nav_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = "/home-screen";
  List<Widget> _pages(BuildContext context) {
    return [
      HomePageWidget(),
      BookingsScreen(),
      Center(child: Text("Profile Page")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
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
