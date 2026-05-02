import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/core/widgets/doctor_widget.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';
import 'package:shefaa_app/features/payment/data/models/payment_args_model.dart';
import 'package:shefaa_app/generated/l10n.dart';

class PaymentScreenBody extends StatelessWidget {
  const PaymentScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
        final args = ModalRoute.of(context)!.settings.arguments as PaymentArgsModel;

    return  Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor card
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
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
                    child: DoctorWidget(),
                  ),
                  const SizedBox(height: 20),

                  // Appointment details
                  Container(
                    height: 140,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("الأحد 15 يوليو 2026"),
                                Text(
                                  " 5 مساء",
                                  style: TextStyles.meduim14.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.pin_drop_outlined,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("عيادة كيور الطبية"),
                                Text(
                                  "الرياض - شارع الملك فهد",
                                  style: TextStyles.meduim14.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment summary
                  Container(
                    height: 170,
                    padding: const EdgeInsets.all(12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).payment_summary,
                          style: TextStyles.meduim14.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).consultation_fee,
                              style: TextStyles.meduim14.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              " 300  جنيه",
                              style: TextStyles.meduim14.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).discount,
                              style: TextStyles.meduim14.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "0",
                              style: TextStyles.meduim14.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 30, color: Colors.grey.shade300),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).total_amount,
                              style: TextStyles.bold14.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              " 300  جنيه",
                              style: TextStyles.bold14.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    S.of(context).select_payment_method,
                    style: TextStyles.bold16.copyWith(color: Colors.black),
                  ),

                  const SizedBox(height: 10),

                  // Payment methods cards
                  Container(
                    height: 70,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 70,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Fixed button at the bottom
          BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              // ✅ نجح
              if (state.createBookingState == RequestState.loaded) {
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   BookingSuccessScreen.routeName,
                //   (route) => false,
                // );
              }
              // ❌ فشل
              if (state.createBookingState == RequestState.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Booking failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: CustomButton(
              title: S.of(context).confirm_booking_payment,
              onPressed: () {
                context.read<BookingBloc>().add(
                  CreateBookingEvent(
                    doctorId: args.doctorId,
                   
                    bookedDate: args.date,
                    startTime: args.startTime,
                    endTime: args.endTime,
                    amount: args.amount,
                    paymentMethod: 'cash', // 'cash' or 'instapay'
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
