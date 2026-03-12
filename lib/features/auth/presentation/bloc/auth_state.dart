part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final RequestState loginState;
  final String loginMessage;
  final UserEntity? user;
  final RequestState registerState;
  final String registerMessage;

  const AuthState({
    this.loginState = RequestState.initial,
    this.loginMessage = '',
    this.user,
    this.registerState = RequestState.initial,
    this.registerMessage = '',
  });

  AuthState copyWith({
    RequestState? loginState,
    String? loginMessage,
    UserEntity? user,
    RequestState? registerState,
    String? registerMessage,
  }) {
    return AuthState(
      loginState: loginState ??this. loginState,
      loginMessage: loginMessage ?? this.loginMessage,
      user: user ?? this.user,
      registerState: registerState ?? this.registerState,
      registerMessage: registerMessage ?? this.registerMessage,
    );
  }

  @override
  List<Object?> get props => [
    loginState,
    loginMessage,
    user,
    registerState,
    registerMessage,
  ];
}
