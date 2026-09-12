import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:shefaa_app/features/payment/data/models/payment_args_model.dart';
import 'package:shefaa_app/generated/l10n.dart';

class PaymentScreenBody extends StatelessWidget {
  const PaymentScreenBody({super.key});

  static const List<String> _dayNames = [
    'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];
  static const List<String> _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static String _formatDate(DateTime d) =>
      '${_dayNames[d.weekday % 7]} ${d.day} ${_monthNames[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PaymentArgsModel;

    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The place in the queue is the thing being bought, so it
                  // leads. The old screen showed a fixed time the clinic was
                  // never going to keep to.
                  _QueueCard(args: args),
                  const SizedBox(height: 16),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Row(
                          icon: Icons.person_outline,
                          title: args.doctorName,
                          subtitle: 'الطبيب',
                        ),
                        const SizedBox(height: 16),
                        _Row(
                          icon: Icons.calendar_today,
                          title: _formatDate(args.date),
                          subtitle: args.session == 'morning'
                              ? 'الفترة الصباحية'
                              : 'الفترة المسائية',
                        ),
                        const SizedBox(height: 16),
                        _Row(
                          icon: Icons.access_time,
                          title:
                              '${DoctorSessionModel.formatTime(args.startTime)}'
                              ' – '
                              '${DoctorSessionModel.formatTime(args.endTime)}',
                          subtitle: 'وقت الفترة',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.of(context).payment_summary,
                            style: TextStyles.bold16.copyWith(color: Colors.black)),
                        const SizedBox(height: 12),
                        _AmountRow(
                          label: S.of(context).consultation_fee,
                          value: '${args.amount.toStringAsFixed(0)} ${S.of(context).currency}',
                        ),
                        Divider(height: 24, color: Colors.grey.shade300),
                        _AmountRow(
                          label: S.of(context).total_amount,
                          value: '${args.amount.toStringAsFixed(0)} ${S.of(context).currency}',
                          bold: true,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.payments_outlined,
                                  size: 20, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'الدفع نقداً في العيادة',
                                  style: TextStyles.meduim14
                                      .copyWith(color: Colors.orange.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          BlocConsumer<BookingBloc, BookingState>(
            listenWhen: (p, c) => p.createBookingState != c.createBookingState,
            listener: (context, state) {
              if (state.createBookingState == RequestState.loaded) {
                // The number the database assigned, not the one predicted on
                // the session card before anyone else had committed.
                _showSuccess(
                  context,
                  args,
                  state.bookedQueueNumber ?? args.queueNumber,
                );
              }
              if (state.createBookingState == RequestState.error) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(state.errorMessage ?? 'تعذر إتمام الحجز'),
                    backgroundColor: Colors.red.shade700,
                  ));
              }
            },
            builder: (context, state) {
              return CustomButton(
                title: S.of(context).confirm_booking_payment,
                isLoading: state.createBookingState == RequestState.loading,
                onPressed: () {
                  context.read<BookingBloc>().add(
                        CreateBookingEvent(
                          doctorId: args.doctorId,
                          amount: args.amount,
                          paymentMethod: 'cash',
                          bookedDate: args.date,
                          session: args.session,
                          startTime: args.startTime,
                          endTime: args.endTime,
                        ),
                      );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Confirmation, then straight to the bookings tab.
  ///
  /// popUntil(isFirst) only went back to the home tab, which read as the button
  /// doing nothing. The whole stack is replaced instead, so back does not lead
  /// into a payment flow that is already finished, and BookingsScreen re-reads
  /// on open so the new booking is there.
  void _showSuccess(
    BuildContext context,
    PaymentArgsModel args,
    int queueNumber,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 40, color: Colors.green.shade700),
            ),
            const SizedBox(height: 16),
            Text('تم تأكيد الحجز', style: TextStyles.bold18),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(args.date)}\n'
              '${args.session == 'morning' ? 'الفترة الصباحية' : 'الفترة المسائية'}',
              textAlign: TextAlign.center,
              style: TextStyles.meduim14.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'دورك رقم $queueNumber',
                style: TextStyles.bold18.copyWith(color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'إذا ألغى أحد قبلك يقل رقمك — ولا يزيد أبداً',
              textAlign: TextAlign.center,
              style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                  arguments: HomeScreen.bookingsTab,
                );
              },
              child: const Text('حجوزاتي'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.args});
  final PaymentArgsModel args;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('دورك سيكون',
              style: TextStyles.meduim14.copyWith(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text('رقم ${args.queueNumber}',
              style: TextStyles.bold24.copyWith(color: AppColors.primaryColor)),
          const SizedBox(height: 6),
          Text(
            'ترتيبك داخل الفترة، وليس موعداً محدداً',
            style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyles.bold14.copyWith(color: Colors.black)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? TextStyles.bold14.copyWith(color: Colors.black)
        : TextStyles.meduim14.copyWith(color: Colors.grey.shade700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}
