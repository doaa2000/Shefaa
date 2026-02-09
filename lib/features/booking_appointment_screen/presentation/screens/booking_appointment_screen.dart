import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/booking_appointment_screen/presentation/widgets/date_card_list_view.dart';
import 'package:shefaa_app/features/booking_appointment_screen/presentation/widgets/date_card_widget.dart';
import 'package:shefaa_app/core/widgets/doctor_widget.dart';
import 'package:shefaa_app/features/booking_appointment_screen/presentation/widgets/time_card_list_widget.dart';
import 'package:shefaa_app/features/booking_appointment_screen/presentation/widgets/time_card_widget.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';

class BookingAppointmentScreen extends StatelessWidget {
  const BookingAppointmentScreen({super.key});

  static const String routeName = "/booking-appointment";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).select_appointment),
      body: Padding(
        padding: EdgeInsets.all(Constants.padding),
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DoctorWidget(),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).available_days,
                      style: TextStyles.bold18,
                    ),
                    const SizedBox(height: 10),

                    DateCardListView(
                      daysData: [
                        {'dayName': 'Mon', 'dayNumber': '21', 'month': 'Sep'},
                        {'dayName': 'Tue', 'dayNumber': '22', 'month': 'Sep'},
                        {'dayName': 'Wed', 'dayNumber': '23', 'month': 'Sep'},
                        {'dayName': 'Thu', 'dayNumber': '24', 'month': 'Sep'},
                        {'dayName': 'Fri', 'dayNumber': '25', 'month': 'Sep'},
                      ],
                      selectedIndex: 0,
                      onDaySelected: (index) {
                        print("Selected day index: $index");
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).available_time,
                      style: TextStyles.bold18,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).morning,
                      style: TextStyles.bold16.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TimeCardListWidget(
                      hours: ["09:00 AM", "10:00 AM", "11:00 AM"],
                      selectedIndex: 0,
                      onHourSelected: (index) {
                        print("Selected hour index: $index");
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).evening,
                      style: TextStyles.bold16.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TimeCardListWidget(
                      hours: ["12:00 PM", "01:00 PM", "02:00 PM"],
                      selectedIndex: 0,
                      onHourSelected: (index) {
                        print("Selected hour index: $index");
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Fixed button at bottom
            CustomButton(
              title: S.of(context).confirm_booking,
              onPressed: () {
                Navigator.pushNamed(context, PaymentScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
