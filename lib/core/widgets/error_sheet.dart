import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/generated/l10n.dart';

/// How a refusal is shown.
///
/// A snackbar was the wrong shape for these. It appears at the bottom for four
/// seconds and takes itself away, over a screen the patient is still looking
/// at -- so the one message that explains why the button did nothing is also
/// the one most likely to be missed, and cannot be read twice.
///
/// These are not incidental notices. Every one of them is the database
/// refusing something the patient asked for, and the patient has to decide
/// what to do next. A sheet waits to be dismissed.
Future<void> showErrorSheet(BuildContext context, String message) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: Constants.padding,
        right: Constants.padding,
        top: Constants.padding,
        // Clear of the home indicator, so the button is not half a gesture.
        bottom: MediaQuery.of(sheetContext).padding.bottom + Constants.padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  S.of(sheetContext).booking_error_title,
                  style: TextStyles.bold18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyles.meduim14.copyWith(
              color: Colors.grey.shade700,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: S.of(sheetContext).booking_error_close,
            onPressed: () => Navigator.pop(sheetContext),
          ),
        ],
      ),
    ),
  );
}
