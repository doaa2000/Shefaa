import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/arabic_date.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onTap,
  });

  final BookingEntity booking;

  /// Null hides the cancel action — a past or already cancelled booking has
  /// nothing left to cancel.
  final VoidCallback? onCancel;

  /// Opens the full details. Null leaves the card inert.
  final VoidCallback? onTap;

  String get _date => shortArabicDate(booking.bookedDate);

  String get _sessionLabel =>
      booking.session == 'morning' ? 'الفترة الصباحية' : 'الفترة المسائية';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: (booking.doctor.image?.isNotEmpty ?? false)
                      ? NetworkImage(booking.doctor.image!)
                      : null,
                  child: (booking.doctor.image?.isNotEmpty ?? false)
                      ? null
                      : const Icon(Icons.person, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.doctor.name,
                          style: TextStyles.bold16.copyWith(color: Colors.black)),
                      const SizedBox(height: 2),
                      Text(booking.doctor.specialaization,
                          style: TextStyles.meduim12
                              .copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _StatusChip(status: booking.status),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 15, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(_date, style: TextStyles.meduim14),
                const SizedBox(width: 14),
                Icon(Icons.access_time, size: 15, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$_sessionLabel · '
                    '${DoctorSessionModel.formatTime(booking.startTime)}',
                    style: TextStyles.meduim14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Only worth showing while the visit is still ahead: a queue position
            // on a booking that has already happened means nothing.
            if (booking.queueNumber != null && booking.isUpcoming) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        size: 18, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Text('دورك رقم ${booking.queueNumber}',
                        style: TextStyles.bold14
                            .copyWith(color: AppColors.primaryColor)),
                    if (booking.queueNumber! > 1) ...[
                      const SizedBox(width: 8),
                      Text('· قدامك ${booking.queueNumber! - 1}',
                          style: TextStyles.meduim12
                              .copyWith(color: Colors.grey.shade600)),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${booking.payment.amount.toStringAsFixed(0)} جنيه',
                  style: TextStyles.bold14.copyWith(color: Colors.black),
                ),
                const SizedBox(width: 6),
                Text(
                  booking.payment.isPaid ? '· مدفوع' : '· يُدفع في العيادة',
                  style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('إلغاء'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  static const Map<String, (String, Color)> _map = {
    'confirmed': ('مؤكد', Colors.green),
    'pending': ('قيد التأكيد', Colors.orange),
    'completed': ('تم', Colors.blue),
    'cancelled': ('ملغي', Colors.grey),
    'no_show': ('لم يحضر', Colors.brown),
  };

  @override
  Widget build(BuildContext context) {
    final (label, color) = _map[status] ?? (status, Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyles.meduim12.copyWith(color: color)),
    );
  }
}
