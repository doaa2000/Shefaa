import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed; // ✅ nullable → allows disabled state
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 40,
    this.borderRadius = 10,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = AppColors.white,
  });

  // ✅ Button is disabled when onPressed is null
  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed, // ✅ null = automatically disabled by Flutter
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _isDisabled
              ? AppColors.primaryColor.withOpacity(0.4) // ✅ faded when disabled
              : backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: TextStyles.bold16,
        ),
        child: Text(title),
      ),
    );
  }
}