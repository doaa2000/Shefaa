import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/core/widgets/doctor_widget.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/appointment_card.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/payment_summary_card.dart';
import 'package:shefaa_app/generated/l10n.dart';

class BookingsDetailsScreen extends StatelessWidget {
  const BookingsDetailsScreen({super.key});
  static const routeName = '/bookings_details_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).booking_details),

      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xffE8F3FF),
                              backgroundImage: NetworkImage(
                                "https://i.pravatar.cc/150?img=4",
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Dr. Mohamed Hassan",
                                  style: TextStyles.bold18,
                                ),
                                Text(
                                  "Pediatrician",
                                  style: TextStyles.regular14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    AppointmentCard(),
                    SizedBox(height: 5),
                    PaymentSummaryCard(),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            CustomButton(title: S.of(context).cancel_booking, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
