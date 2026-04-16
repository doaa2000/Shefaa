part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final RequestState loginState;
  final String loginMessage;
  final UserEntity? user;
  final RequestState registerState;
  final String registerMessage;

   final RequestState logoutState;
  final String logoutMessage;

  const AuthState({
    this.loginState = RequestState.initial,
    this.loginMessage = '',
    this.user,
    this.registerState = RequestState.initial,
    this.registerMessage = '',
      this.logoutState = RequestState.initial,
      this.logoutMessage = '',
  });

  AuthState copyWith({
    RequestState? loginState,
    String? loginMessage,
    UserEntity? user,
    RequestState? registerState,
    String? registerMessage,
    RequestState? logoutState,
    String? logoutMessage,
  }) {
    return AuthState(
      loginState: loginState ??this. loginState,
      loginMessage: loginMessage ?? this.loginMessage,
      user: user ?? this.user,
      registerState: registerState ?? this.registerState,
      registerMessage: registerMessage ?? this.registerMessage,
      logoutState: logoutState ?? this.logoutState,
      logoutMessage: logoutMessage ?? this.logoutMessage,
    );
  }

  @override
  List<Object?> get props => [
    loginState,
    loginMessage,
    user,
    registerState,
    registerMessage,
    logoutState,
    logoutMessage,
  ];
}
