import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/consent/presentation/bloc/consent_bloc.dart';

/// Asks for the consent the app could not record at signup.
///
/// Reached by patients who registered before this was asked for, and by anyone
/// whose agreement is to an older version of the wording. Registering today
/// records it with the account itself and never lands here.
///
/// It is deliberately a dead end: there is no back button and no way past it
/// but accepting or signing out. A screen that can be skipped is not consent.
class HealthConsentScreen extends StatelessWidget {
  const HealthConsentScreen({super.key});

  static const String routeName = '/health-consent';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConsentBloc>(),
      child: const _ConsentView(),
    );
  }
}

class _ConsentView extends StatelessWidget {
  const _ConsentView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Not dismissible by the back gesture: the only ways out are the two
      // buttons, and both of them are a decision.
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConsent.healthDataTitle),
          automaticallyImplyLeading: false,
        ),
        body: BlocListener<ConsentBloc, ConsentState>(
          listenWhen: (previous, current) =>
              previous.acceptState != current.acceptState,
          listener: (context, state) {
            if (state.acceptState == RequestState.error) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(
                    state.message.isEmpty
                        ? 'تعذر حفظ الموافقة. يرجى المحاولة مرة أخرى.'
                        : state.message,
                  ),
                  backgroundColor: Colors.red.shade700,
                ));
              return;
            }

            if (state.acceptState != RequestState.loaded) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: Text(
                      AppConsent.healthDataBody.trim(),
                      style: TextStyles.meduim14.copyWith(height: 1.9),
                    ),
                  ),
                ),
                const _Actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsentBloc, ConsentState>(
      builder: (context, state) {
        final saving = state.acceptState == RequestState.loading;

        return Container(
          padding: const EdgeInsets.all(Constants.padding),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: saving
                      ? null
                      : () => context
                          .read<ConsentBloc>()
                          .add(const AcceptHealthConsentEvent()),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('أوافق'),
                ),
              ),
              const SizedBox(height: 6),
              // Refusing has to lead somewhere. Without this the only way out
              // of the screen would be to uninstall the app.
              TextButton(
                onPressed: saving ? null : () => _declineAndSignOut(context),
                child: Text(
                  'لا أوافق · تسجيل الخروج',
                  style: TextStyles.meduim14.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _declineAndSignOut(BuildContext context) {
    // Through AuthBloc rather than Supabase directly, so the stored tokens go
    // with the session -- otherwise the next launch restores it and lands
    // straight back on this screen.
    context.read<AuthBloc>().add(LogoutEvent());
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
