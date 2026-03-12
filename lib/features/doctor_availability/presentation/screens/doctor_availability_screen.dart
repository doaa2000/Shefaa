import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/bloc/doctor_availability_bloc.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/date_card_list_view.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/date_card_widget.dart';
import 'package:shefaa_app/core/widgets/doctor_widget.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/time_card_list_widget.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/time_card_widget.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';

class DoctorAvailabilityScreen extends StatelessWidget {
  const DoctorAvailabilityScreen({super.key});

  static const String routeName = "/doctor-availability";
  String getDayName(DateTime date) {
  const days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  return days[date.weekday % 7];
}

String getMonthName(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[date.month - 1];
}
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DoctorAvailabilityBloc>()..add(GetDoctorAvailabilityEvent(doctorId: "6",)),
      child: Scaffold(
        appBar: CustomAppBar(title: S.of(context).select_appointment),
        body: Padding(
          padding: EdgeInsets.all(Constants.padding),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child:BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(
  builder: (context, state) {
    // الأيام
    final daysData = state.doctorAvailability.map((d) {
      final date = d.date; // DateTime
      return {
        'dayName': getDayName(date), 
        'dayNumber': date.day.toString(),
        'month': getMonthName(date),
      };
    }).toList();

    final morningHours = state.doctorAvailability.isNotEmpty
        ? state.doctorAvailability[state.selectedDayIndex].morningHours
        : [];
    final eveningHours = state.doctorAvailability.isNotEmpty
        ? state.doctorAvailability[state.selectedDayIndex].eveningHours
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateCardListView(
          daysData: daysData,
          selectedIndex: state.selectedDayIndex,
          onDaySelected: (index) {
            context
                .read<DoctorAvailabilityBloc>()
                .add(SelectDayEvent(selectedDay: index));
          },
        ),
        const SizedBox(height: 16),
        Text("Available Time", style: TextStyles.bold18),
        const SizedBox(height: 8),
        Text("Morning", style: TextStyles.bold16.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 10),
        TimeCardListWidget(
          hours: morningHours,
          selectedIndex: state.selectedHourIndex,
          onHourSelected: (index) {
            context
                .read<DoctorAvailabilityBloc>()
                .add(SelectHourEvent(selectedHour: index));
          },
        ),
        const SizedBox(height: 16),
        Text("Evening", style: TextStyles.bold16.copyWith(color: Colors.grey.shade600)),
        const SizedBox(height: 10),
        TimeCardListWidget(
          hours: eveningHours,
          selectedIndex: state.selectedHourIndex,
          onHourSelected: (index) {
            context
                .read<DoctorAvailabilityBloc>()
                .add(SelectHourEvent(selectedHour: index));
          },
        ),
      ],
    );
  },
)
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
      ),
    );
  }
}
