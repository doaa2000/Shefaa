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

  /// The version of the health-data wording the patient ticked. It travels
  /// with the signup because there is no session immediately after one -- the
  /// app cannot write the consent row itself, so the trigger does.
  final String healthConsentVersion;

  /// The terms and the privacy notice, each with its own version, for the same
  /// reason and by the same route. Separate fields rather than one: they are
  /// two documents and either can change without the other.
  final String termsVersion;
  final String privacyVersion;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.healthConsentVersion,
    required this.termsVersion,
    required this.privacyVersion,
    this.birthDate,
    this.gender,
  });
}

class LogoutEvent extends AuthEvent {}

/// Deletes the account for good. Separate from logging out because it is not
/// the same decision and must not be reachable by the same tap.
class DeleteAccountEvent extends AuthEvent {}
