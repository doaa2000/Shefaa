import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/consent_gate.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shefaa_app/features/consent/presentation/bloc/consent_bloc.dart';

/// Asks for the terms and the privacy notice when the account has not accepted
/// the current wording of both.
///
/// Reached by everyone who registered before the app asked for them, and by
/// anyone whose agreement is to an older version. Registering today records
/// both with the account itself and never lands here.
///
/// Like the health-data screen, it is a dead end on purpose: the only ways out
/// are accepting and signing out, and both are a decision.
class LegalAcceptanceScreen extends StatelessWidget {
  const LegalAcceptanceScreen({super.key});

  static const String routeName = AppRoutes.legalAcceptance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConsentBloc>(),
      child: const _AcceptanceView(),
    );
  }
}

class _AcceptanceView extends StatelessWidget {
  const _AcceptanceView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قبل المتابعة'),
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

            // Through the gate rather than straight to the home screen: this
            // account may still owe the health-data consent, and that is the
            // gate's question to answer, not this screen's.
            _goOn(context);
          },
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLegal.termsTitle, style: TextStyles.bold18),
                        const SizedBox(height: 8),
                        Text(
                          AppLegal.termsBody.trim(),
                          style: TextStyles.meduim14.copyWith(height: 1.9),
                        ),
                        const SizedBox(height: 24),
                        Text(AppLegal.privacyTitle, style: TextStyles.bold18),
                        const SizedBox(height: 8),
                        Text(
                          AppLegal.privacyBody.trim(),
                          style: TextStyles.meduim14.copyWith(height: 1.9),
                        ),
                      ],
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

  Future<void> _goOn(BuildContext context) async {
    final route = await ConsentGate.nextRoute();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
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
                          .add(const AcceptLegalConsentEvent()),
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
    context.read<AuthBloc>().add(LogoutEvent());
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
