import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';

/// One bookable time, as a chip in a grid of them.
///
/// It says the time and nothing else. How many places are left is the clinic's
/// business, not the patient's -- "3 places left" only ever reads as pressure --
/// and a time already taken is simply not offered rather than shown and
/// refused.
class AppointmentChip extends StatelessWidget {
  const AppointmentChip({
    super.key,
    required this.window,
    required this.isSelected,
    required this.showEndTime,
    required this.onTap,
  });

  final DoctorSessionEntity window;
  final bool isSelected;

  /// True when the doctor offers the session whole, so the chip has to name
  /// both ends: "6:00 م - 9:00 م". When the session is split, the start alone
  /// is the appointment and the end is noise.
  final bool showEndTime;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final full = window.isFull;
    final start = DoctorSessionModel.formatTime(window.startTime);
    final label = showEndTime
        ? '$start - ${DoctorSessionModel.formatTime(window.endTime)}'
        : start;

    final background = full
        ? Colors.grey.shade100
        : isSelected
            ? AppColors.primaryColor
            : Colors.white;

    final border = full
        ? Colors.grey.shade200
        : isSelected
            ? AppColors.primaryColor
            : Colors.grey.shade300;

    final textColor = full
        ? Colors.grey.shade400
        : isSelected
            ? Colors.white
            : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      // Null, not a callback that does nothing: a full time gives no ripple and
      // no press, so it reads as unavailable before it is tapped.
      onTap: full ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isSelected && !full ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyles.bold14.copyWith(
            color: textColor,
            decoration: full ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
