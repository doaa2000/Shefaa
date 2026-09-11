import 'package:flutter/material.dart';
import 'package:shefaa_app/features/auth/presentation/screens/login_screen.dart';
import 'package:shefaa_app/features/auth/presentation/screens/register_screen.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_args_model.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/screens/doctor_availability_screen.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_details_screen.dart';
import 'package:shefaa_app/features/doctors/data/models/doctors_args_model.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctors_screen.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:shefaa_app/features/location/presentation/screens/location_screen.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:shefaa_app/features/profile/presentation/screens/update_profile_screen.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());

    case RegisterScreen.routeName:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());

    case LocationScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LocationScreen());

    case HomeScreen.routeName:
      // An int argument selects the tab to land on, so a flow that ends
      // somewhere specific can say where.
      final tab = settings.arguments is int
          ? settings.arguments as int
          : HomeScreen.homeTab;
      return MaterialPageRoute(
        builder: (context) => HomeScreen(initialTab: tab),
        settings: settings,
      );

    case DoctorsScreen.routeName:
      // The screen cannot render without knowing which specialty it lists, so
      // a call without proper arguments is a routing mistake, not an empty
      // list. Surface it instead of silently showing every doctor.
      final doctorsArgs = settings.arguments;
      if (doctorsArgs is! DoctorsArgsModel) {
        return _errorRoute('لم يتم تحديد التخصص');
      }
      return MaterialPageRoute(
        builder: (context) => DoctorsScreen(args: doctorsArgs),
        settings: settings,
      );

    case UpdateProfileScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UpdateProfileScreen(),
      );

    case DoctorAvailabilityScreen.routeName:
      final availabilityArgs = settings.arguments;
      if (availabilityArgs is! DoctorAvailabilityArgsModel) {
        return _errorRoute('لم يتم تحديد الطبيب');
      }
      return MaterialPageRoute(
        builder: (context) => DoctorAvailabilityScreen(args: availabilityArgs),
        settings: settings,
      );

    case BookingsDetailsScreen.routeName:
      // The screen is nothing but this one booking's details, so a call
      // without it is a routing mistake, not an empty screen.
      final booking = settings.arguments;
      if (booking is! BookingEntity) {
        return _errorRoute('لم يتم تحديد الحجز');
      }
      return MaterialPageRoute(
        builder: (context) => BookingsDetailsScreen(booking: booking),
        settings: settings,
      );

    case PaymentScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
        settings: settings,
      );

    default:
      return _errorRoute('الصفحة غير موجودة');
  }
}

Route<dynamic> _errorRoute(String message) {
  return MaterialPageRoute(
    builder: (context) => Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44, color: Colors.grey),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}
