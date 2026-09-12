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

/// Picks one bookable window.
///
/// Carries the start time, not just 'morning' or 'evening': a doctor who works
/// to a clock has several windows inside one session, and keying the selection
/// on the session name alone would light all of them up at once.
class SelectWindowEvent extends DoctorAvailabilityEvent {
  final String session;
  final String startTime;

  const SelectWindowEvent({required this.session, required this.startTime});

  @override
  List<Object?> get props => [session, startTime];
}
