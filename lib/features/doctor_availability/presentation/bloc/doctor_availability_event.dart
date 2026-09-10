part of 'doctor_availability_bloc.dart';

abstract class DoctorAvailabilityEvent extends Equatable {
  const DoctorAvailabilityEvent();
}

class GetDoctorAvailabilityEvent extends DoctorAvailabilityEvent {
  final int doctorId;
  final DateTime date; 

  const GetDoctorAvailabilityEvent({
    required this.doctorId,
    required this.date,
  });

  @override
  List<Object?> get props => [doctorId, date];
}

class SelectDateEvent extends DoctorAvailabilityEvent {
  final DateTime date;
  const SelectDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectMorningSlotEvent extends DoctorAvailabilityEvent {
  final int slotId;
  const SelectMorningSlotEvent(this.slotId);

  @override
  List<Object?> get props => [slotId];
}

class SelectEveningSlotEvent extends DoctorAvailabilityEvent {
  final int slotId;
  const SelectEveningSlotEvent(this.slotId);

  @override
  List<Object?> get props => [slotId];
}