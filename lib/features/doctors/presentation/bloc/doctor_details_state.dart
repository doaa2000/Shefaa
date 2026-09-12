part of 'doctor_details_bloc.dart';

class DoctorDetailsState extends Equatable {
  final RequestState scheduleState;
  final List<DoctorScheduleEntity> schedule;
  final String? errorMessage;

  const DoctorDetailsState({
    this.scheduleState = RequestState.initial,
    this.schedule = const [],
    this.errorMessage,
  });

  /// The pattern grouped by day, in week order, so the page can print one line
  /// per working day rather than one per session.
  Map<int, List<DoctorScheduleEntity>> get byWeekday {
    final grouped = <int, List<DoctorScheduleEntity>>{};
    for (final row in schedule) {
      grouped.putIfAbsent(row.weekday, () => []).add(row);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  DoctorDetailsState copyWith({
    RequestState? scheduleState,
    List<DoctorScheduleEntity>? schedule,
    String? errorMessage,
  }) {
    return DoctorDetailsState(
      scheduleState: scheduleState ?? this.scheduleState,
      schedule: schedule ?? this.schedule,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [scheduleState, schedule, errorMessage];
}
