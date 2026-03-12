part of 'doctor_availability_bloc.dart';

class DoctorAvailabilityState extends Equatable {
  final List<DoctorAvailabilityEntity> doctorAvailability;
  final String? errorMessage;
  final RequestState getDoctorAvailabilityState;
  final int selectedDayIndex;
  final int selectedHourIndex;

  const DoctorAvailabilityState({
    this.doctorAvailability = const [],
    this.errorMessage,
    this.getDoctorAvailabilityState = RequestState.initial,
    this.selectedDayIndex = 0,
    this.selectedHourIndex = 0,
  });

  DoctorAvailabilityState copyWith({
    List<DoctorAvailabilityEntity>? doctorAvailability,
    String? errorMessage,
    RequestState? getDoctorAvailabilityState,
    int? selectedDayIndex,
    int? selectedHourIndex,
  }) {
    return DoctorAvailabilityState(
      doctorAvailability: doctorAvailability ?? this.doctorAvailability,
      errorMessage: errorMessage ?? this.errorMessage,
      getDoctorAvailabilityState:
          getDoctorAvailabilityState ?? this.getDoctorAvailabilityState,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedHourIndex: selectedHourIndex ?? this.selectedHourIndex,
    );
  }

  @override
  List<Object?> get props => [
    doctorAvailability,
    errorMessage,
    getDoctorAvailabilityState,
    selectedDayIndex,
    selectedHourIndex,
  ];
}
