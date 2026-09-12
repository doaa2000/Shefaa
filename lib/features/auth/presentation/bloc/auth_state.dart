part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final RequestState loginState;
  final String loginMessage;
  final UserEntity? user;
  final RequestState registerState;
  final String registerMessage;

  /// The account was created but nobody is signed in: the address still has
  /// to be confirmed. Registering is finished either way -- what differs is
  /// where the patient goes next.
  final bool registerNeedsConfirmation;

   final RequestState logoutState;
  final String logoutMessage;

  const AuthState({
    this.loginState = RequestState.initial,
    this.loginMessage = '',
    this.user,
    this.registerState = RequestState.initial,
    this.registerMessage = '',
    this.registerNeedsConfirmation = false,
      this.logoutState = RequestState.initial,
      this.logoutMessage = '',
  });

  AuthState copyWith({
    RequestState? loginState,
    String? loginMessage,
    UserEntity? user,
    RequestState? registerState,
    String? registerMessage,
    bool? registerNeedsConfirmation,
    RequestState? logoutState,
    String? logoutMessage,
  }) {
    return AuthState(
      loginState: loginState ??this. loginState,
      loginMessage: loginMessage ?? this.loginMessage,
      user: user ?? this.user,
      registerState: registerState ?? this.registerState,
      registerMessage: registerMessage ?? this.registerMessage,
      registerNeedsConfirmation:
          registerNeedsConfirmation ?? this.registerNeedsConfirmation,
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
    registerNeedsConfirmation,
    logoutState,
    logoutMessage,
  ];
}
