import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    // Read the bloc before the await: the dialog is a route of its own, and
    // this context may be gone by the time it closes.
    final bloc = context.read<AuthBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'هتخرجي من حسابك؟\n'
          'هتحتاجي تسجّلي الدخول تاني علشان تشوفي حجوزاتك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener wrapping BlocBuilder, not BlocConsumer. BlocConsumer calls
    // its listener from inside buildWhen -- during the build -- and a
    // Navigator call there does not go through. That is why logging out used
    // to empty the screen (the session really was gone) and leave the patient
    // sitting on the very profile it had just emptied.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.logoutState != current.logoutState,
      listener: (context, state) {
        if (state.logoutState != RequestState.loaded) return;

        if (state.logoutMessage.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.logoutMessage)));
        }

        // Everything under this is a signed-in screen, so clear the stack
        // instead of replacing the top of it -- otherwise the back button
        // walks straight back into an account nobody is signed in to.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) =>
            previous.logoutState != current.logoutState,
        builder: (context, state) {
          final isLoggingOut = state.logoutState == RequestState.loading;

          return GestureDetector(
            onTap: isLoggingOut ? null : () => _confirmLogout(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: isLoggingOut
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Text(
                        "تسجيل الخروج",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
