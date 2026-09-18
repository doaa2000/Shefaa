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

  /// How many reviews the average is drawn from. 4.9 from two people and 4.4
  /// from three hundred are not the same claim, and a rating shown without its
  /// count invites the reader to assume the second.
  final int? ratingsCount;
  final dynamic consultationFee;
  final int ? waitingTime;
  final String? location;

  /// A short note the doctor writes about themselves. The column has existed
  /// since doctors got accounts; nothing read it until there was a page to put
  /// it on.
  final String? bio;

  const DoctorEntity({
    required this.id,
    required this.name,
     this.specialtyId,
     this.clinicId,
    this.image,
    this.title,
    this.rating, this.ratingsCount, required this.specialaization, this.consultationFee, this.waitingTime,required this.location,
    this.bio,
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
    ratingsCount,
    specialaization,
    consultationFee,
    waitingTime,
    location,
    bio,
  ];
}
