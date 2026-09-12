import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/auth/presentation/screens/register_screen.dart';
import 'package:shefaa_app/features/auth/presentation/widgets/auth_footer.dart';
import 'package:shefaa_app/features/consent/domain/usecases/consent_usecases.dart';
import 'package:shefaa_app/core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = AppRoutes.login;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      LoginEvent(
        emailController.text.trim(),
        passwordController.text,
      ),
    );
  }

  /// Home, unless this account still owes the health-data consent.
  ///
  /// The splash screen makes the same check for a session it restored; this is
  /// the other door into the app, and an account that signed in today has to
  /// pass through the same gate as one that was already signed in.
  Future<void> _goOn(BuildContext context) async {
    final result = await getIt<HasAcceptedConsentUseCase>()(
      const ConsentParams(
        kind: 'health_data',
        version: AppConsent.healthDataVersion,
      ),
    );

    // A failure counts as accepted, as it does on the splash: a round trip
    // that did not come back should not lock somebody out of their account.
    final accepted = result.fold((_) => true, (value) => value);

    if (!context.mounted) return;

    // Clear the stack: pressing back after signing in must not return to the
    // login screen.
    Navigator.pushNamedAndRemoveUntil(
      context,
      accepted ? AppRoutes.home : AppRoutes.healthConsent,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.loginState != current.loginState,
      listener: (context, state) {
        if (state.loginState == RequestState.loaded) {
          _goOn(context);
        } else if (state.loginState == RequestState.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.loginMessage.isEmpty
                    ? "تعذر تسجيل الدخول. حاول مرة أخرى."
                    : state.loginMessage),
                backgroundColor: Colors.red.shade700,
              ),
            );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
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
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return "اكتب البريد الإلكتروني";
                        }
                        if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$')
                            .hasMatch(email)) {
                          return "البريد الإلكتروني غير صحيح";
                        }
                        return null;
                      },
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "اكتب كلمة المرور";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.loginState != current.loginState,
                      builder: (context, state) {
                        return CustomButton(
                          title: "تسجيل الدخول",
                          isLoading: state.loginState == RequestState.loading,
                          onPressed: _submit,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    AuthFooter(
                      onRegisterTap: () {
                        Navigator.pushNamed(
                          context,
                          RegisterScreen.routeName,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
