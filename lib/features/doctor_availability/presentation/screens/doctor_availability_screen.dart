import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_args_model.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/bloc/doctor_availability_bloc.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/date_card_list_view.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/doctor_details_widget.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/session_card_widget.dart';
import 'package:shefaa_app/features/payment/data/models/payment_args_model.dart';
import 'package:shefaa_app/features/payment/presentation/screens/payment_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';

class DoctorAvailabilityScreen extends StatelessWidget {
  const DoctorAvailabilityScreen({super.key, required this.args});

  final DoctorAvailabilityArgsModel args;

  static const String routeName = AppRoutes.doctorAvailability;

  /// How far ahead a patient may book. Long enough to plan around, short enough
  /// that the doctor's schedule is unlikely to have changed underneath it.
  static const int _bookingHorizonDays = 30;

  static const List<String> _dayNames = [
    'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];

  static const List<String> _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  List<DateTime> get _days {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return List.generate(
      _bookingHorizonDays,
      (i) => start.add(Duration(days: i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;

    return BlocProvider(
      create: (context) => getIt<DoctorAvailabilityBloc>()
        ..add(GetDoctorAvailabilityEvent(
          doctorId: args.doctorId,
          date: days.first,
        )),
      child: Scaffold(
        appBar: CustomAppBar(title: S.of(context).select_appointment),
        body: BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(
          builder: (context, state) {
            if (state.getDoctorAvailabilityState == RequestState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.getDoctorAvailabilityState == RequestState.error) {
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<DoctorAvailabilityBloc>().add(
                      GetDoctorAvailabilityEvent(
                        doctorId: args.doctorId,
                        date: state.selectedDate,
                      ),
                    ),
              );
            }

            final doctor = state.doctorDetails?.doctor;
            final selectedIndex = days.indexWhere((d) =>
                d.year == state.selectedDate.year &&
                d.month == state.selectedDate.month &&
                d.day == state.selectedDate.day);

            return Padding(
              padding: const EdgeInsets.all(Constants.padding),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DoctorDetailsWidget(
                            imageUrl: doctor?.image ?? '',
                            name: doctor?.name ?? '',
                            specialty: doctor?.specialaization ?? '',
                            consultationFee: doctor?.consultationFee ?? 0,
                            location: doctor?.location ?? '',
                            waitingTime: doctor?.waitingTime != null
                                ? '${doctor!.waitingTime} دقيقة'
                                : '—',
                          ),
                          const SizedBox(height: 16),
                          DateCardListView(
                            daysData: days
                                .map((date) => {
                                      'dayName': _dayNames[date.weekday % 7],
                                      'dayNumber': date.day.toString(),
                                      'month': _monthNames[date.month - 1],
                                    })
                                .toList(),
                            selectedIndex:
                                selectedIndex.clamp(0, days.length - 1),
                            onDaySelected: (index) => context
                                .read<DoctorAvailabilityBloc>()
                                .add(SelectDateEvent(days[index])),
                          ),
                          const SizedBox(height: 24),
                          Text('اختر الفترة', style: TextStyles.bold18),
                          const SizedBox(height: 12),
                          _SessionsArea(state: state),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    title: S.of(context).confirm_booking,
                    onPressed: state.canConfirm
                        ? () {
                            final session = state.selected!;
                            Navigator.pushNamed(
                              context,
                              PaymentScreen.routeName,
                              arguments: PaymentArgsModel(
                                doctorId: args.doctorId,
                                doctorName: doctor?.name ?? '',
                                date: state.selectedDate,
                                session: session.session,
                                startTime: session.startTime,
                                endTime: session.endTime,
                                queueNumber: session.nextQueueNumber,
                                amount:
                                    (doctor?.consultationFee as num?)?.toDouble() ??
                                        0,
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionsArea extends StatelessWidget {
  const _SessionsArea({required this.state});

  final DoctorAvailabilityState state;

  @override
  Widget build(BuildContext context) {
    if (state.getSlotsState == RequestState.loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.getSlotsState == RequestState.error) {
      return _ErrorView(message: state.errorMessage);
    }

    if (state.sessions.isEmpty) {
      // A doctor who does not work this weekday is the ordinary case, not an
      // error, so it reads as information and points at what to do instead.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined,
                size: 36, color: Colors.grey.shade500),
            const SizedBox(height: 10),
            Text(
              'الطبيب لا يعمل في هذا اليوم',
              style: TextStyles.meduim14.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'اختر يوماً آخر من الأعلى',
              style: TextStyles.meduim12.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final session in state.sessions) ...[
          SessionCardWidget(
            session: session,
            isSelected: state.selectedSession == session.session,
            onTap: () => context
                .read<DoctorAvailabilityBloc>()
                .add(SelectSessionEvent(session.session)),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              message?.isNotEmpty == true ? message! : 'حدث خطأ',
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
