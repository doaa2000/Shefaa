part of 'doctors_bloc.dart';

abstract class DoctorsEvent extends Equatable {
  const DoctorsEvent();

  @override
  List<Object> get props => [];
}

class GetDoctorsEvent extends DoctorsEvent {
  final int specialtyId;

  const GetDoctorsEvent({required this.specialtyId});

  @override
  List<Object> get props => [specialtyId];
}