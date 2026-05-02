import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final int id;
  final String name;
  final String specialaization;
  final int ? specialtyId;
  final int ? clinicId;
  final String? image;
  final String? title;
  final double? rating;
  final dynamic consultationFee;
  final int ? waitingTime;
  final String? location;

  const DoctorEntity({
    required this.id,
    required this.name,
     this.specialtyId,
     this.clinicId,
    this.image,
    this.title,
    this.rating, required this.specialaization, this.consultationFee, this.waitingTime,required this.location,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    specialtyId,
    clinicId,
    image,
    title,
    rating,
    specialaization,
    consultationFee,
    waitingTime,
    location,
  ];
}
