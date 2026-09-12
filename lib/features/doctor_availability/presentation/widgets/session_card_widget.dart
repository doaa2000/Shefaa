import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';

/// One bookable session: when it runs, how much room is left, and — once
/// chosen — the place the patient would take.
///
/// It shows a queue position rather than an exact time because that is the
/// promise the clinic can actually keep. A time would be wrong the moment the
/// doctor ran twenty minutes late; a position only ever improves.
class SessionCardWidget extends StatelessWidget {
  const SessionCardWidget({
    super.key,
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  final DoctorSessionEntity session;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final full = session.isFull;
    final borderColor = full
        ? Colors.grey.shade300
        : isSelected
            ? AppColors.primaryColor
            : Colors.grey.shade300;

    return Opacity(
      opacity: full ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: full ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected && !full
                ? AppColors.primaryColor.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected && !full ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    session.isMorning ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                    size: 20,
                    color: full ? Colors.grey : AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    session.isMorning ? 'الفترة الصباحية' : 'الفترة المسائية',
                    style: TextStyles.bold16.copyWith(color: Colors.black),
                  ),
                  const Spacer(),
                  _RemainingChip(session: session),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DoctorSessionModel.formatTime(session.startTime)}'
                ' – '
                '${DoctorSessionModel.formatTime(session.endTime)}',
                style: TextStyles.meduim14.copyWith(color: Colors.grey.shade700),
              ),
              // What the patient is agreeing to: come inside this window. No
              // number -- the clinic sees people in the order they arrive, and
              // most of them never booked through the app.
              if (isSelected && !full) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 18, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'يرجى الحضور في بداية الموعد',
                          style: TextStyles.bold14
                              .copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RemainingChip extends StatelessWidget {
  const _RemainingChip({required this.session});

  final DoctorSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final full = session.isFull;
    // Showing the exact number only while it is small keeps "3 places left"
    // meaningful instead of it reading as a permanent decoration.
    final almostFull = !full && session.remaining <= 3;

    final label = full
        ? 'مكتمل'
        : almostFull
            ? 'أماكن متبقية: ${session.remaining}'
            : 'متاح';

    final color = full
        ? Colors.grey.shade600
        : almostFull
            ? Colors.orange.shade800
            : Colors.green.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyles.meduim12.copyWith(color: color),
      ),
    );
  }
}
