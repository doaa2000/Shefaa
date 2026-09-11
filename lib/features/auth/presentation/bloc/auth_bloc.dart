import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/secure_storage_service.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:shefaa_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shefaa_app/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SecureStorageService secureStorageService;
  final LogoutUseCase logoutUseCase;

  AuthBloc({required this.loginUseCase, required this.registerUseCase, required this.secureStorageService, required this.logoutUseCase}) : super(const AuthState()) {
    on<LoginEvent>(_login);
    on<RegisterEvent>(_register);
    on<LogoutEvent>(_logout);

  }
Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
  emit(state.copyWith(loginState: RequestState.loading));

  final result = await loginUseCase(
    LoginUseCaseParameters(
      email: event.email,
      password: event.password,
    ),
  );

  await result.fold(
    (failure) async {
      emit(
        state.copyWith(
          loginState: RequestState.error,
          loginMessage: failure.message,
        ),
      );
    },
    (user) async {
      await _persistTokens(user);

      emit(
        state.copyWith(
          loginState: RequestState.loaded,
          user: user,
        ),
      );
    },
  );
}

  Future<void> _register(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(registerState: RequestState.loading));

    final result = await registerUseCase(
      RegisterUseCaseParameters(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        birthDate: event.birthDate,
        gender: event.gender,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            registerState: RequestState.error,
            registerMessage: failure.message,
          ),
        );
      },
      (user) async {
        // Registering signs the patient in, so it has to leave the same trail
        // login does. It did not, so the token in storage stayed the previous
        // account's -- and the splash screen trusted it.
        await _persistTokens(user);

        emit(state.copyWith(registerState: RequestState.loaded, user: user));
      },
    );
    
  }



  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit)async {
    await logoutUseCase(NoParameters());

    // Signing out of Supabase is not enough on its own: the splash screen
    // reads these, and a token left behind here sent the next launch to the
    // home screen with no session behind it.
    await secureStorageService.clearTokens();

    emit(state.copyWith(logoutState: RequestState.loaded));
  }

  /// Stores the tokens of a session we just obtained. A user without them is
  /// not something to crash on -- it means there is no session to remember,
  /// and the splash screen will send them to the login screen.
  Future<void> _persistTokens(UserEntity user) async {
    final accessToken = user.accessToken;
    final refreshToken = user.refreshToken;
    if (accessToken == null || refreshToken == null) return;

    await secureStorageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
