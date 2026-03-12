part of 'doctor_availability_bloc.dart';

abstract class DoctorAvailabilityEvent extends Equatable {
  const DoctorAvailabilityEvent();

  @override
  List<Object> get props => [];
}


class GetDoctorAvailabilityEvent extends DoctorAvailabilityEvent {
  final String doctorId;

  const GetDoctorAvailabilityEvent({required this.doctorId});
}
class SelectDayEvent extends DoctorAvailabilityEvent {
  final int selectedDay;

  const SelectDayEvent({required this.selectedDay});
}

class SelectHourEvent extends DoctorAvailabilityEvent {
  final int selectedHour;

  const SelectHourEvent({required this.selectedHour});
}