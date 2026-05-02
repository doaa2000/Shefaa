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
  });
factory DoctorModel.fromMap(Map<String, dynamic> json) {
    print('🔍 id: ${json['id']}');
  print('🔍 specialty_id: ${json['specialty_id']}');
  print('🔍 clinic_id: ${json['clinic_id']}');
  print('🔍 waiting_time: ${json['waiting_time']}');
  print('🔍 consultation_fee: ${json['consultation_fee']}');
  print('🔍 rating: ${json['rating']}');
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
    };
  }
}
