part of 'doctor_availability_bloc.dart';

class DoctorAvailabilityState extends Equatable {
  static const _clear = Object();

  final DoctorDetailsEntity? doctorDetails;

  /// Kept independently of [doctorDetails] so changing the date still knows
  /// which doctor to load when the first load failed.
  final int? doctorId;

  final String? errorMessage;
  final RequestState getDoctorAvailabilityState;
  final RequestState getSlotsState;
  final DateTime selectedDate;

  /// 'morning' or 'evening', or null when nothing is chosen yet.
  final String? selectedSession;

  DoctorAvailabilityState({
    this.doctorDetails,
    this.doctorId,
    this.errorMessage,
    this.getDoctorAvailabilityState = RequestState.initial,
    this.getSlotsState = RequestState.initial,
    DateTime? selectedDate,
    this.selectedSession,
  }) : selectedDate = selectedDate ?? DateTime.now();

  List<DoctorSessionEntity> get sessions => doctorDetails?.sessions ?? const [];

  DoctorSessionEntity? get selected => selectedSession == null
      ? null
      : sessions.where((s) => s.session == selectedSession).firstOrNull;

  /// Only a session with room left can be booked.
  bool get canConfirm => selected != null && !selected!.isFull;

  DoctorAvailabilityState copyWith({
    DoctorDetailsEntity? doctorDetails,
    int? doctorId,
    String? errorMessage,
    RequestState? getDoctorAvailabilityState,
    RequestState? getSlotsState,
    DateTime? selectedDate,
    Object? selectedSession = _clear,
  }) {
    return DoctorAvailabilityState(
      doctorDetails: doctorDetails ?? this.doctorDetails,
      doctorId: doctorId ?? this.doctorId,
      errorMessage: errorMessage ?? this.errorMessage,
      getDoctorAvailabilityState:
          getDoctorAvailabilityState ?? this.getDoctorAvailabilityState,
      getSlotsState: getSlotsState ?? this.getSlotsState,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSession: identical(selectedSession, _clear)
          ? this.selectedSession
          : selectedSession as String?,
    );
  }

  @override
  List<Object?> get props => [
        doctorDetails,
        doctorId,
        errorMessage,
        getDoctorAvailabilityState,
        getSlotsState,
        selectedDate,
        selectedSession,
      ];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
