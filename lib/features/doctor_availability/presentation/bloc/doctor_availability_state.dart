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

  /// Which window is chosen, as 'session|start_time', or null when none is.
  ///
  /// Both halves, because a session can hold several windows and two sessions
  /// could in principle begin at the same clock time.
  final String? selectedWindow;

  DoctorAvailabilityState({
    this.doctorDetails,
    this.doctorId,
    this.errorMessage,
    this.getDoctorAvailabilityState = RequestState.initial,
    this.getSlotsState = RequestState.initial,
    DateTime? selectedDate,
    this.selectedWindow,
  }) : selectedDate = selectedDate ?? DateTime.now();

  List<DoctorSessionEntity> get sessions => doctorDetails?.sessions ?? const [];

  static String windowKey(DoctorSessionEntity window) =>
      '${window.session}|${window.startTime}';

  DoctorSessionEntity? get selected => selectedWindow == null
      ? null
      : sessions.where((s) => windowKey(s) == selectedWindow).firstOrNull;

  /// How many windows this session was split into. One means the doctor offers
  /// it whole, and the card then names both ends rather than just the start.
  int windowsInSession(String session) =>
      sessions.where((s) => s.session == session).length;

  /// Only a window with room left can be booked.
  bool get canConfirm => selected != null && !selected!.isFull;

  DoctorAvailabilityState copyWith({
    DoctorDetailsEntity? doctorDetails,
    int? doctorId,
    String? errorMessage,
    RequestState? getDoctorAvailabilityState,
    RequestState? getSlotsState,
    DateTime? selectedDate,
    Object? selectedWindow = _clear,
  }) {
    return DoctorAvailabilityState(
      doctorDetails: doctorDetails ?? this.doctorDetails,
      doctorId: doctorId ?? this.doctorId,
      errorMessage: errorMessage ?? this.errorMessage,
      getDoctorAvailabilityState:
          getDoctorAvailabilityState ?? this.getDoctorAvailabilityState,
      getSlotsState: getSlotsState ?? this.getSlotsState,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedWindow: identical(selectedWindow, _clear)
          ? this.selectedWindow
          : selectedWindow as String?,
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
        selectedWindow,
      ];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
