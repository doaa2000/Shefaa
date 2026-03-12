import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.specialtyId,
    super.image,
    super.title,
    super.rating,
    required super.clinicId,
    required super.specialaization,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      specialaization: json['specialization'] as String,
      specialtyId: json['specialty_id'] as int,
      clinicId: json['clinic_id'] as int,
      image: json['image'] as String?,
      title: json['title'] as String?,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty_id': specialtyId,
      'image': image,
      'title': title,
      'rating': rating,
      'clinic_id': clinicId,
      'specialaization': specialaization,
    };
  }
}
