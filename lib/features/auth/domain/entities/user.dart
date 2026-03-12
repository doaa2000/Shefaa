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
}