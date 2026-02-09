import 'package:flutter/material.dart';
import 'package:shefaa_app/features/booking_appointment_screen/presentation/screens/booking_appointment_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctors_screen.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case DoctorsScreen.routeName:
      return MaterialPageRoute(builder: (context) => const DoctorsScreen());
    case BookingAppointmentScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const BookingAppointmentScreen(),
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
