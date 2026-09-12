part of 'doctor_details_bloc.dart';

abstract class DoctorDetailsEvent extends Equatable {
  const DoctorDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetDoctorScheduleEvent extends DoctorDetailsEvent {
  final int doctorId;

  const GetDoctorScheduleEvent(this.doctorId);

  @override
  List<Object> get props => [doctorId];
}
