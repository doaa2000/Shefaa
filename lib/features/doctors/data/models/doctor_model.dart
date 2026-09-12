import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
     super.specialtyId,
    super.image,
    super.title,
    super.rating,
     super.clinicId,
    required super.specialaization,
    super.consultationFee,
    super.waitingTime, required super.location,
    super.bio,
  });
factory DoctorModel.fromMap(Map<String, dynamic> json) {
    return DoctorModel(
    id:              (json['id'] as num).toInt(),
    name:            json['name'] as String,
    specialaization: json['specialization'] as String? ?? '',
    image:           json['image'] as String?,
    title:           json['title'] as String?,
    consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 0.0,
    rating:          (json['rating'] as num?)?.toDouble() ?? 0.0,
    specialtyId:     (json['specialty_id'] as num?)?.toInt(),   // ✅
    clinicId:        (json['clinic_id'] as num?)?.toInt(),      // ✅
    waitingTime:     (json['waiting_time'] as num?)?.toInt(),   // ✅  
    location:        json['location'] as String?,
    bio:             json['bio'] as String?,
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
      'consultation_fee': consultationFee,
      'waiting_time': waitingTime,
      'location': location,
      'bio': bio,
    };
  }
}
