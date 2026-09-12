import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/fields_label.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/profile_text_fields.dart';
import 'package:shefaa_app/features/profile/presentation/widgets/section_label.dart';
import 'package:shefaa_app/generated/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  static const String routeName = '/update-profile';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()
        ..add(
          GetProfileEvent(
            userId: Supabase.instance.client.auth.currentUser!.id,
          ),
        ),
      child: const _UpdateProfileView(),
    );
  }
}

class _UpdateProfileView extends StatefulWidget {
  const _UpdateProfileView();

  @override
  State<_UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<_UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();

  /// Read once. The screen is only reachable while signed in -- the bloc above
  /// it is created with this same id.
  final _userId = Supabase.instance.client.auth.currentUser!.id;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// The form is filled from the loaded profile exactly once. Without this
  /// guard every rebuild would wipe out whatever the patient has typed.
  bool _formFilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _fillForm(UserEntity user) {
    _nameController.text = user.name ?? '';
    _phoneController.text = user.phone ?? '';
    _emailController.text = user.email;
    _selectedBirthDate = _parseDate(user.birthDate);
    _formFilled = true;
  }

  /// `birth_date` comes back from Postgres as `yyyy-MM-dd`, sometimes with a
  /// time part. Anything else is treated as "not set" rather than crashing.
  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _isoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate =
        _selectedBirthDate ?? DateTime(now.year - 20, now.month, now.day);

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

    FocusScope.of(context).unfocus();

    context.read<ProfileBloc>().add(
          UpdateProfileEvent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            birthDate: _selectedBirthDate == null
                ? null
                : _isoDate(_selectedBirthDate!),
            // Passwords are never trimmed -- a space can be part of one.
            newPassword: _passwordController.text.isEmpty
                ? null
                : _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: S.of(context).update_profile,
      ),
      // BlocListener wrapping BlocBuilder, not BlocConsumer: BlocConsumer runs
      // its listener from inside buildWhen, i.e. during the build itself, and
      // setState / Navigator.pop are not allowed there.
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.profileState != current.profileState ||
              previous.updateState != current.updateState,
          listener: (context, state) {
            if (state.profileState == RequestState.loaded &&
                !_formFilled &&
                state.user != null) {
              setState(() => _fillForm(state.user!));
            }

            if (state.updateState == RequestState.loaded) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(S.of(context).profile_updated_success)),
                );
              Navigator.of(context).pop();
            }

            if (state.updateState == RequestState.error) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.updateMessage),
                    backgroundColor: Colors.redAccent,
                  ),
                );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.profileState == RequestState.loading && !_formFilled) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.profileState == RequestState.error && !_formFilled) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: Text(
                      state.profileMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              }

              final isSaving = state.updateState == RequestState.loading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(Constants.padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The camera badge here used to be a drawing: it had
                      // no tap handler at all, so the one obvious way to set a
                      // photograph did nothing.
                      AvatarPicker(userId: _userId),

                      const SizedBox(height: 24),

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
                        onTap: isSaving ? null : _pickBirthDate,
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

                      // Read only: the address lives in auth.users, and changing
                      // it is a confirm-by-email flow of its own, not part of
                      // saving a profile.
                      ProfileTextField(
                        controller: _emailController,
                        label: S.of(context).email_address,
                        hint: S.of(context).email_hint,
                        prefixIcon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        S.of(context).email_locked_note,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
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
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
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
                        isLoading: isSaving,
                        onPressed: _onSave,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
