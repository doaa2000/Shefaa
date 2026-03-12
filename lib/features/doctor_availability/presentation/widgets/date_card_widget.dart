import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';

class DateCardWidget extends StatelessWidget {
  final String dayName;
  final String dayNumber;
  final String month;
  final VoidCallback? onTap;
  final bool isSelected;

  const DateCardWidget({
    super.key,
    required this.dayName,
    required this.dayNumber,
    required this.month,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        width: 90,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyles.regular14.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayNumber,
              style: TextStyles.bold14.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              month,
              style: TextStyles.regular14.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
