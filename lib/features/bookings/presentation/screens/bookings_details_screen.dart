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

  /// Popping with true means "cancel this booking". The bookings list owns the
  /// BookingBloc, so it is the one that dispatches the cancel and reports the
  /// result -- this screen is gone by then.
  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).cancel_booking),
        content: Text(
          'هتلغي حجزك مع ${booking.doctor.name}؟\n'
          'مكانك هيروح لغيرك ومش هينفع ترجعيه.',
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
                            color: Colors.black.withOpacity(0.05),
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
            if (booking.isUpcoming) ...[
              const SizedBox(height: 12),
              CustomButton(
                title: S.of(context).cancel_booking,
                backgroundColor: Colors.red.shade700,
                onPressed: () => _confirmCancel(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
