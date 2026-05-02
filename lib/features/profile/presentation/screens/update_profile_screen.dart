import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/fields_label.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/profile_text_fields.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/section_label.dart';
import 'package:shefaa_app/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  static const String routeName = '/update-profile';

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ??
        DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} / '
        '${date.month.toString().padLeft(2, '0')} / '
        '${date.year}';
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    // Example:
    // context.read<ProfileBloc>().add(
    //   UpdateProfileEvent(
    //     userId: Supabase.instance.client.auth.currentUser!.id,
    //     name: _nameController.text.trim(),
    //     email: _emailController.text.trim(),
    //     phone: _phoneController.text.trim(),
    //     password: _passwordController.text.isEmpty
    //         ? null
    //         : _passwordController.text,
    //     birthDate: _selectedBirthDate,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()
        ..add(
          GetProfileEvent(
            userId: Supabase.instance.client.auth.currentUser!.id,
          ),
        ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: S.of(context).update_profile,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Constants.padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Avatar ─────────────────────────────
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor:
                              colorScheme.primary.withOpacity(0.12),
                          child: Icon(
                            CupertinoIcons.person_fill,
                            size: 52,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Personal Info ─────────────────────
                  SectionLabel(label: S.of(context).personal_info),
                  const SizedBox(height: 12),

                  ProfileTextField(
                    controller: _nameController,
                    label: S.of(context).full_name,
                    hint: S.of(context).full_name_hint,
                    prefixIcon: CupertinoIcons.person,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return S.of(context).name_required_error;
                      }
                      if (val.trim().length < 3) {
                        return S.of(context).name_min_error;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  ProfileTextField(
                    controller: _phoneController,
                    label: S.of(context).phone_number,
                    hint: S.of(context).phone_hint,
                    prefixIcon: CupertinoIcons.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return S.of(context).phone_required_error;
                      }
                      if (val.trim().length < 10) {
                        return S.of(context).phone_invalid_error;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // ─── Birth Date ─────────────────────────
                  FieldLabel(label: S.of(context).birth_date),
                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 20,
                            color: _selectedBirthDate != null
                                ? colorScheme.primary
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedBirthDate != null
                                  ? _formatDate(_selectedBirthDate!)
                                  : S.of(context).select_birth_date,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Account Info ───────────────────────
                  SectionLabel(label: S.of(context).account_info),
                  const SizedBox(height: 12),

                  ProfileTextField(
                    controller: _emailController,
                    label: S.of(context).email_address,
                    hint: S.of(context).email_hint,
                    prefixIcon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return S.of(context).email_required_error;
                      }
                      final emailRegex =
                          RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(val.trim())) {
                        return S.of(context).email_invalid_error;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // ─── Password ───────────────────────────
                  SectionLabel(label: S.of(context).change_password),
                  const SizedBox(height: 12),

                  ProfileTextField(
                    controller: _passwordController,
                    label: S.of(context).new_password,
                    hint: S.of(context).password_hint,
                    prefixIcon: CupertinoIcons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                      ),
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty && val.length < 8) {
                        return S.of(context).password_min_error;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  ProfileTextField(
                    controller: _confirmPasswordController,
                    label: S.of(context).confirm_new_password,
                    hint: S.of(context).password_hint,
                    prefixIcon: CupertinoIcons.lock_shield,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword),
                      icon: Icon(
                        _obscureConfirmPassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                      ),
                    ),
                    validator: (val) {
                      if (_passwordController.text.isNotEmpty &&
                          val != _passwordController.text) {
                        return S.of(context).passwords_not_match;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 36),

                  CustomButton(
                    title: S.of(context).save_changes,
                    onPressed: _onSave,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}