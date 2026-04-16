import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/auth/presentation/bloc/auth_bloc.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.logoutState == RequestState.loaded) {
          Navigator.pushReplacementNamed(context,AppRoutes.login);
        }
        if (state.logoutState == RequestState.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.logoutMessage)),
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context.read<AuthBloc>().add(LogoutEvent());
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "تسجيل الخروج",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
