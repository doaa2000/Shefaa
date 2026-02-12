import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';

class BookingActionToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const BookingActionToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selectedIndex,
        backgroundColor: Colors.transparent,
        thumbColor: Colors.white,

        padding: const EdgeInsets.all(4),
        children: {
          0: _segmentItem(
            title: 'تعديل الموعد',
            isCancel: false,
            isActive: selectedIndex == 0,
          ),
          1: _segmentItem(
            title: 'إلغاء الحجز',
            isCancel: true,
            isActive: selectedIndex == 1,
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  Widget _segmentItem({
    required String title,
    required bool isCancel,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color:
              isActive
                  ? (isCancel ? Colors.red : AppColors.primaryColor)
                  : Colors.grey.shade600,
        ),
      ),
    );
  }
}
