import 'package:flutter/material.dart';
import 'package:shefaa_app/features/auth/presentation/screens/login_screen.dart';
import 'package:shefaa_app/features/auth/presentation/screens/register_screen.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/screens/doctor_availability_screen.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_details_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctors_screen.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case RegisterScreen.routeName:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case DoctorsScreen.routeName:
      return MaterialPageRoute(builder: (context) => const DoctorsScreen());
    case DoctorAvailabilityScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const DoctorAvailabilityScreen(),
      );

    case BookingsDetailsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const BookingsDetailsScreen(),
      );
    case PaymentScreen.routeName:
      return MaterialPageRoute(builder: (context) => const PaymentScreen());
    default:
      return MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: const Center(child: Text('404 - Page Not Found')),
            ),
      );
  }
}
