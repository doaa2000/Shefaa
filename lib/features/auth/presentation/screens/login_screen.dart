import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/auth/presentation/widgets/auth_footer.dart';
import 'package:shefaa_app/core/widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static const routeName = '/login-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                /// Title
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "مرحباً بعودتك",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "سجل الدخول للمتابعة إلى شفاء",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// Email
                const Text("البريد الإلكتروني"),
                const SizedBox(height: 8),
                const AppTextField(
                  hint: "example@mail.com",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 20),

                /// Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("كلمة المرور"),
                    Text(
                      "هل نسيتها؟",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const AppTextField(
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 32),

                /// Login Button
                CustomButton(title: "تسجيل الدخول", onPressed: () {}),

                const SizedBox(height: 24),

                AuthFooter(
                  onRegisterTap: () {
                    Navigator.pushNamed(context, '/register-screen');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
