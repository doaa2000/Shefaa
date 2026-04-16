import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/widgets/app_text_field.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/auth/presentation/widgets/birth_date_field.dart';
import 'package:shefaa_app/features/home/presentation/screens/home_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.registerState == RequestState.loaded) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("تم تسجيل الدخول")));

             Navigator.pushReplacementNamed(context, HomeScreen.routeName);
          }

          if (state.registerState == RequestState.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.loginMessage)));
          }
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  ),

                  AppTextField(
                    hint: S.of(context).email,
                    controller: emailController,
                  ),

                  AppTextField(
                    hint: S.of(context).phone_number,
                    controller: phoneController,
                  ),

                  BirthDateField(
                    onDateSelected: (date) {
                      birthDateController.text = date.toString();
                    },
                  ),

                  AppTextField(
                    hint: S.of(context).password,
                    controller: passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        title: S.of(context).create_account,
                        // isLoading:
                        //     state.registerState == RequestState.loading,
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            RegisterEvent(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text,
                              phone: phoneController.text,
                              birthDate: birthDateController.text,
                              gender: selectedGender,
                            ),
                          );
                        },
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
    );
  }
}
