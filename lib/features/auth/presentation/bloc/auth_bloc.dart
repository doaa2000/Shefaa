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
      await secureStorageService.saveTokens(
        accessToken: user.accessToken!,
        refreshToken: user.refreshToken!,
      );

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

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            registerState: RequestState.error,
            registerMessage: failure.message,
          ),
        );
      },
      (user) {
        emit(state.copyWith(registerState: RequestState.loaded, user: user));
      },
    );
    
  }



  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit)async {
    await logoutUseCase(NoParameters());
    emit(state.copyWith(logoutState: RequestState.loaded));
  }
}
