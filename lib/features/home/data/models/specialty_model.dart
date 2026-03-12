import 'package:shefaa_app/features/home/domain/entities/specialty.dart';

class SpecialtyModel extends SpecialtyEntity {
  const SpecialtyModel({
    required super.id,
    required super.name,
    super.icon,
  });

  factory SpecialtyModel.fromMap(Map<String, dynamic> map) {
    return SpecialtyModel(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}