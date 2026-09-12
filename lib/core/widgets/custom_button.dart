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
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 40,
    this.borderRadius = 10,
    this.backgroundColor = AppColors.primaryColor,
    this.textColor = AppColors.white,
    this.isLoading = false,
  });

  // Disabled when there is no handler, or while a request is in flight so the
  // same request cannot be fired twice by an impatient double tap.
  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _isDisabled
              ? AppColors.primaryColor.withValues(alpha: 0.4) // ✅ faded when disabled
              : backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: TextStyles.bold16,
        ),
        child: isLoading
            ? SizedBox(
                height: height * 0.5,
                width: height * 0.5,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(title),
      ),
    );
  }
}