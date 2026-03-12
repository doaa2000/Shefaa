part of 'doctors_bloc.dart';

abstract class DoctorsEvent extends Equatable {
  const DoctorsEvent();

  @override
  List<Object> get props => [];
}

class GetDoctorsEvent extends DoctorsEvent {
  final String specialtyId;

  const GetDoctorsEvent({required this.specialtyId});
}