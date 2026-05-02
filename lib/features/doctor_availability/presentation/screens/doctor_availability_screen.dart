import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/bloc/doctor_availability_bloc.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/date_card_list_view.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/doctor_details_widget.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/time_card_list_widget.dart';
import 'package:shefaa_app/features/payment/data/models/payment_args_model.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';

class DoctorAvailabilityScreen extends StatelessWidget {
  const DoctorAvailabilityScreen({super.key});

  static const String routeName = "/doctor-availability";

  List<DateTime> _getNextDays({int count = 7}) {
    final today = DateTime.now();
    return List.generate(count, (i) => today.add(Duration(days: i)));
  }

  String _getDayName(DateTime date) {
    const days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday',
    ];
    return days[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = _getNextDays(); // ✅ [today, tomorrow, ...]

    return BlocProvider(
      create: (context) => getIt<DoctorAvailabilityBloc>()
        ..add(GetDoctorAvailabilityEvent(
          doctorId: "6",
          date: DateTime.now(), // ✅ load today's slots on open
        )),
      child: Scaffold(
        appBar: CustomAppBar(title: S.of(context).select_appointment),
        body: Padding(
          padding: EdgeInsets.all(Constants.padding),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(
                  builder: (context, state) {
                    final doctor = state.doctorDetails?.doctor;

                    if (state.getDoctorAvailabilityState == RequestState.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.getDoctorAvailabilityState == RequestState.error) {
                      return Center(
                        child: Text(state.errorMessage ?? "Something went wrong"),
                      );
                    }

                    // ✅ Build days data from generated dates
                    final daysData = days.map((date) => {
                      'dayName':   _getDayName(date),
                      'dayNumber': date.day.toString(),
                      'month':     _getMonthName(date),
                    }).toList();

                    // ✅ Find selected index from selectedDate
                    final selectedIndex = days.indexWhere((d) =>
                      d.year  == state.selectedDate.year &&
                      d.month == state.selectedDate.month &&
                      d.day   == state.selectedDate.day,
                    );

                    return  SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      DoctorDetailsWidget(
        imageUrl:        doctor?.image ?? '',
        name:            doctor?.name ?? '',
        specialty:       doctor?.specialaization ?? '',
        consultationFee: doctor?.consultationFee ?? 0,
        location:        doctor?.location ?? '',
        waitingTime:     doctor?.waitingTime != null
            ? '${doctor!.waitingTime} mins'
            : 'N/A',
      ),

      const SizedBox(height: 10),

      DateCardListView(
        daysData:      daysData,
        selectedIndex: selectedIndex.clamp(0, days.length - 1),
        onDaySelected: (index) {
          context.read<DoctorAvailabilityBloc>().add(
            SelectDateEvent(days[index]),
          );
        },
      ),

      const SizedBox(height: 20),

      Text("Available Time", style: TextStyles.bold18),
      const SizedBox(height: 12),

      if (state.getSlotsState == RequestState.loading)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(), 
          ),
        )
      else ...[
        Text("Morning",
            style: TextStyles.bold16.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        state.morningSlots.isEmpty
            ? const Text("No morning slots")
            : TimeCardListWidget(
                hours: state.morningSlots.map((s) => s.startTime).toList(),
                selectedIndex: state.morningSlots.indexWhere(
                  (s) => s.id == state.selectedMorningSlotId.toString(),
                ),
                onHourSelected: (index) {
                  context.read<DoctorAvailabilityBloc>().add(
                    SelectMorningSlotEvent(
                      int.parse(state.morningSlots[index].id),
                    ),
                  );
                },
              ),

        const SizedBox(height: 16),

        Text("Evening",
            style: TextStyles.bold16.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        state.eveningSlots.isEmpty
            ? const Text("No evening slots")
            : TimeCardListWidget(
                hours: state.eveningSlots.map((s) => s.startTime).toList(),
                selectedIndex: state.eveningSlots.indexWhere(
                  (s) => s.id == state.selectedEveningSlotId.toString(),
                ),
                onHourSelected: (index) {
                  context.read<DoctorAvailabilityBloc>().add(
                    SelectEveningSlotEvent(
                      int.parse(state.eveningSlots[index].id),
                    ),
                  );
                },
              ),
      ],
    ],
  ),
);
                  },
                ),
              ),
      const SizedBox(height: 20),

              // ✅ Confirm button — only active when a slot is selected
              BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(
                builder: (context, state) {
                                      final doctor = state.doctorDetails?.doctor;

                  final hasSelection =
                      state.selectedMorningSlotId != null ||
                      state.selectedEveningSlotId != null;

                  return CustomButton(
                    title: S.of(context).confirm_booking,
                    onPressed: hasSelection
                        ? () {
                            // ✅ Pass selected slot to payment
                            final slot = state.selectedMorningSlot ??
                                         state.selectedEveningSlot;

                          Navigator.pushNamed(
  context,
  PaymentScreen.routeName,
  arguments: PaymentArgsModel(
    slotId: slot!.id,
    doctorId: slot.doctorId,
    endTime: slot.endTime,
    amount: doctor!.consultationFee,
    doctorName: doctor.name,
    date: state.selectedDate,
    startTime: slot.startTime,
  ),
);
                          }
                        : null, // ✅ disabled if nothing selected
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}