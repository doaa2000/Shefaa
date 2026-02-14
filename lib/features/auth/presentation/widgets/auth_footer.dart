import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';

class AuthFooter extends StatelessWidget {
  final VoidCallback onRegisterTap;

  const AuthFooter({
    super.key,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "ليس لديك حساب؟ ",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: "إنشاء حساب",
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = onRegisterTap,
            ),
          ],
        ),
      ),
    );
  }
}
