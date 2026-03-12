part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent(this.email, this.password);
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String? birthDate;
  final String? gender;
  const RegisterEvent(
 { required  this.email,
  required  this.password,
   required this.name,
   required this.phone,
    this.birthDate,
    this.gender,}
  );
}

class LogoutEvent extends AuthEvent {}
