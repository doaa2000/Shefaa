// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? gender;
  final String? birthDate;
  final String? accessToken;
  final String? refreshToken;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.gender,
    this.birthDate,
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        gender,
        birthDate,
        accessToken,
        refreshToken,
      ];

  /// Equatable stringifies every prop in debug builds, and CustomBlocObserver
  /// logs each AuthState transition — which would put the access and refresh
  /// tokens straight into the device log. Redact them here so no call site can
  /// leak them by accident.
  @override
  String toString() => 'UserEntity(id: $id, email: $email, name: $name, '
      'phone: $phone, gender: $gender, birthDate: $birthDate, '
      'accessToken: ${accessToken == null ? 'null' : '<redacted>'}, '
      'refreshToken: ${refreshToken == null ? 'null' : '<redacted>'})';
}
