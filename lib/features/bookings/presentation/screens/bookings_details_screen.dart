import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/appointment_card.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/payment_summary_card.dart';
import 'package:shefaa_app/generated/l10n.dart';

class BookingsDetailsScreen extends StatelessWidget {
  const BookingsDetailsScreen({super.key, required this.booking});

  static const routeName = '/bookings_details_screen';

  final BookingEntity booking;

  static const List<String> _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// "٤:٠٠ م" for today, and the date as well for any other day: a bare time
  /// on a booking three days out says nothing about which day it runs out.
  static String _formatDeadline(DateTime deadline) {
    final hour12 = deadline.hour % 12 == 0 ? 12 : deadline.hour % 12;
    final minute = deadline.minute.toString().padLeft(2, '0');
    final period = deadline.hour < 12 ? 'ص' : 'م';
    final time = '$hour12:$minute $period';

    final now = DateTime.now();
    final isToday = deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
    if (isToday) return time;

    return '$time يوم ${deadline.day} ${_monthNames[deadline.month - 1]}';
  }

  /// Popping with true means "cancel this booking". The bookings list owns the
  /// BookingBloc, so it is the one that dispatches the cancel and reports the
  /// result -- this screen is gone by then.
  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).cancel_booking),
        content: Text(
          'إلغاء حجزك مع ${booking.doctor.name}؟\n'
          'سيصبح مكانك متاحاً لغيرك، ولا يمكن التراجع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: Text(S.of(context).cancel_booking),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = booking.doctor;
    final hasImage = doctor.image?.isNotEmpty ?? false;

    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).booking_details),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xffE8F3FF),
                            backgroundImage:
                                hasImage ? NetworkImage(doctor.image!) : null,
                            child: hasImage
                                ? null
                                : const Icon(
                                    Icons.person,
                                    size: 32,
                                    color: AppColors.primaryColor,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(doctor.name, style: TextStyles.bold18),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialaization,
                                  style: TextStyles.regular14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppointmentCard(booking: booking),
                    const SizedBox(height: 12),
                    PaymentSummaryCard(booking: booking),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // A booking that has already happened or was cancelled has nothing
            // left to cancel, so the button is simply not there.
            if (booking.canCancel) ...[
              const SizedBox(height: 8),
              Text(
                'يمكن الإلغاء حتى ${_formatDeadline(booking.cancelDeadline)}',
                style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              CustomButton(
                title: S.of(context).cancel_booking,
                backgroundColor: Colors.red.shade700,
                onPressed: () => _confirmCancel(context),
              ),
            ] else if (booking.isUpcoming) ...[
              // Said plainly rather than by leaving a gap where the button was.
              // A patient who came looking for it deserves to know it closed
              // and what to do instead.
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'انتهت مهلة إلغاء هذا الحجز. إذا تعذّر عليك الحضور، '
                  'يرجى التواصل مع العيادة.',
                  style: TextStyles.meduim12
                      .copyWith(color: Colors.grey.shade700, height: 1.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
