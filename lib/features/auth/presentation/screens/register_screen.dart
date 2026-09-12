import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/widgets/app_text_field.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/auth/presentation/widgets/birth_date_field.dart';
import 'package:shefaa_app/generated/l10n.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = AppRoutes.register;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      RegisterEvent(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        // The profiles.birth_date column is a DATE. Send an unambiguous
        // ISO day, not DateTime.toString(), which carries a time component.
        birthDate: _selectedBirthDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
        gender: selectedGender,
      ),
    );
  }

  /// A dialog rather than a snackbar: this is an instruction the patient has
  /// to act on, not a note that they can miss while it slides away.
  void _showConfirmEmail(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تم إنشاء الحساب'),
        content: const Text(
          'أرسلنا رسالة تأكيد إلى بريدك الإلكتروني.\n'
          'يرجى فتح الرسالة وتأكيد البريد، ثم تسجيل الدخول.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.registerState != current.registerState,
        listener: (context, state) {
          if (state.registerState == RequestState.loaded) {
            // Two different endings. With email confirmation on, the account
            // exists but nobody is signed in -- sending them to the home
            // screen would mean a screen with no session behind it, which row
            // level security answers with empty lists rather than an error.
            if (state.registerNeedsConfirmation) {
              _showConfirmEmail(context);
              return;
            }

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
              );

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }

          if (state.registerState == RequestState.error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.registerMessage.isEmpty
                      ? "تعذر إنشاء الحساب. حاول مرة أخرى."
                      : state.registerMessage),
                  backgroundColor: Colors.red.shade700,
                ),
              );
          }
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 70),

                    Center(
                      child: Text(
                        S.of(context).create_account,
                        style: TextStyles.bold24.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    AppTextField(
                      hint: S.of(context).full_name,
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return "اكتب الاسم بالكامل";
                        if (name.length < 3) return "الاسم قصير جداً، اكتب الاسم بالكامل";
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    AppTextField(
                      hint: S.of(context).email,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return "اكتب البريد الإلكتروني";
                        if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$')
                            .hasMatch(email)) {
                          return "البريد الإلكتروني غير صحيح";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    AppTextField(
                      hint: S.of(context).phone_number,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return "اكتب رقم الموبايل";
                        if (!RegExp(r'^01[0-2,5]\d{8}$').hasMatch(phone)) {
                          return "رقم الموبايل غير صحيح";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    BirthDateField(
                      controller: birthDateController,
                      onDateSelected: (date) {
                        setState(() => _selectedBirthDate = date);
                      },
                    ),

                    const SizedBox(height: 14),

                    AppTextField(
                      hint: S.of(context).password,
                      controller: passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return "اكتب كلمة المرور";
                        // Supabase Auth rejects anything shorter than 6, so
                        // catch it here instead of after a round trip.
                        if (password.length < 6) {
                          return "كلمة المرور ٦ أحرف على الأقل";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.registerState != current.registerState,
                      builder: (context, state) {
                        return CustomButton(
                          title: S.of(context).create_account,
                          isLoading:
                              state.registerState == RequestState.loading,
                          onPressed: _submit,
                        );
                      },
                    ),

                    const SizedBox(height: 20),
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
