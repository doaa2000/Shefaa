import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';

/// What the app is, and which build of it this is.
///
/// The version is read from the package rather than written here: a number
/// typed into a string is a number that stops being true at the next release,
/// and the first thing anybody asks about a bug is which version it happened
/// on.
Future<void> showAboutAppDialog(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('عن التطبيق'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'شفاء — لحجز موعد لدى طبيب.',
            style: TextStyles.meduim14.copyWith(height: 1.8),
          ),
          const SizedBox(height: 10),
          Text(
            'الإصدار ${info.version} (${info.buildNumber})',
            style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إغلاق'),
        ),
      ],
    ),
  );
}
