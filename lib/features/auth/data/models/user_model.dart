// lib/features/auth/data/models/user_model.dart
import 'package:shefaa_app/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.gender,
    super.birthDate,
    super.image,
    super.accessToken,
    super.refreshToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      gender: map['gender'] as String?,
      birthDate: map['birth_date'] as String?,
      image: map['image'] as String?,
      accessToken: map['accessToken'] as String?,
      refreshToken: map['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
