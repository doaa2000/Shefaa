import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/auth/presentation/widgets/auth_footer.dart';
import 'package:shefaa_app/core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.loginState == RequestState.loading) {
          print("Logging in...");
        } else if (state.loginState == RequestState.loaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تسجيل الدخول بنجاح")),
          );
          Navigator.pushNamed(context, '/home-screen');
        } else if (state.loginState == RequestState.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.loginMessage ?? "حدث خطأ")),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
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
                  const Text("البريد الإلكتروني"),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint: "example@mail.com",
                    icon: Icons.email_outlined,
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
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
                  AppTextField(
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    title: "تسجيل الدخول",
                    onPressed: () {
                      // نرسل event للـ bloc
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        ),
                      );
                    },
                  ),
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
      ),
    );
  }
}
