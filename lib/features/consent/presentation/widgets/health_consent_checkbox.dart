import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';

/// The tick on the registration form, and the way to read what it means.
///
/// The full wording is behind a sheet rather than inline: nobody reads six
/// paragraphs standing in the middle of a signup form, and a wall of text
/// there makes the form look longer than it is. What must be in front of them
/// is the one sentence and the fact that they have to act.
class HealthConsentCheckbox extends StatelessWidget {
  const HealthConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 28,
          width: 28,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primaryColor,
            onChanged: (next) => onChanged(next ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Tapping the sentence ticks the box: the box alone is a small
                // target, and the sentence beside it looks like part of it.
                GestureDetector(
                  onTap: () => onChanged(!value),
                  child: Text(
                    AppConsent.healthDataSummary,
                    style: TextStyles.meduim12
                        .copyWith(color: Colors.grey.shade800, height: 1.6),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showDetails(context),
                  child: Text(
                    'اقرأ التفاصيل',
                    style: TextStyles.bold12.copyWith(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(AppConsent.healthDataTitle, style: TextStyles.bold18),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(Constants.padding),
                child: Text(
                  AppConsent.healthDataBody.trim(),
                  style: TextStyles.meduim14.copyWith(height: 1.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
