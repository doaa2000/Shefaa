part of 'doctor_availability_bloc.dart';

abstract class DoctorAvailabilityEvent extends Equatable {
  const DoctorAvailabilityEvent();

  @override
  List<Object?> get props => [];
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

/// Picks the morning or evening session. Replaces the per-slot selection: the
/// patient chooses a session and takes the next place in its queue, not a
/// specific minute.
class SelectSessionEvent extends DoctorAvailabilityEvent {
  final String session;
  const SelectSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}
