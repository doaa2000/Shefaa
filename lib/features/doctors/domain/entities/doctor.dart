import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final int id;
  final String name;
  final String specialaization;
  final int specialtyId;
  final int clinicId;
  final String? image;
  final String? title;
  final double? rating;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.clinicId,
    this.image,
    this.title,
    this.rating, required this.specialaization,
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
  ];
}
