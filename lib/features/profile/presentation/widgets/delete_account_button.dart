import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';

/// Deleting the account, which Apple and Google both require an app that
/// creates accounts to offer.
///
/// Quieter than logging out on purpose, and two taps away rather than one: this
/// is the only button on the screen that cannot be undone, so it should not be
/// the easiest one to hit by accident.
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  Future<void> _confirm(BuildContext context) async {
    // Read the bloc before the await: the dialog is a route of its own, and
    // this context may be gone by the time it closes.
    final bloc = context.read<AuthBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'سيتم حذف حسابك وبياناتك الشخصية نهائيًا، ولا يمكن التراجع عن ذلك.\n\n'
          'تبقى سجلات زياراتك لدى الأطباء دون اسمك، لأنها جزء من سجلاتهم '
          'الطبية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('حذف الحساب نهائيًا'),
          ),
        ],
      ),
    );

    if (confirmed == true) bloc.add(DeleteAccountEvent());
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener wrapping BlocBuilder rather than BlocConsumer: this version
    // of BlocConsumer reaches its listener through buildWhen, so a Navigator
    // call from there happens during a build and never arrives.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.deleteAccountState != current.deleteAccountState,
      listener: (context, state) {
        if (state.deleteAccountState == RequestState.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(
                state.deleteAccountMessage.isEmpty
                    ? 'تعذر حذف الحساب. يرجى المحاولة مرة أخرى.'
                    : state.deleteAccountMessage,
              ),
              backgroundColor: Colors.red.shade700,
            ));
          return;
        }

        if (state.deleteAccountState != RequestState.loaded) return;

        // Everything under this is a signed-in screen, and the account behind
        // it no longer exists, so the stack goes rather than its top card.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) =>
            previous.deleteAccountState != current.deleteAccountState,
        builder: (context, state) {
          final isDeleting = state.deleteAccountState == RequestState.loading;

          return Center(
            child: TextButton(
              onPressed: isDeleting ? null : () => _confirm(context),
              child: isDeleting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    )
                  : Text(
                      'حذف الحساب',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
