part of 'doctor_availability_bloc.dart';

class DoctorAvailabilityState extends Equatable {
   static const _clear = Object();
  final DoctorDetailsEntity? doctorDetails;

  /// Kept independently of [doctorDetails] so that changing the date still
  /// knows which doctor to load when the first load failed and there are no
  /// details to read the id back from.
  final int? doctorId;

  final String? errorMessage;
  final RequestState getDoctorAvailabilityState;  
  final RequestState getSlotsState;               
  final DateTime selectedDate;
  final int? selectedMorningSlotId;
  final int? selectedEveningSlotId;

  DoctorAvailabilityState({
    this.doctorDetails,
    this.doctorId,
    this.errorMessage,
    this.getDoctorAvailabilityState = RequestState.initial,
    this.getSlotsState = RequestState.initial,             
    DateTime? selectedDate,
    this.selectedMorningSlotId,
    this.selectedEveningSlotId,
  }) : selectedDate = selectedDate ?? DateTime.now();

  List<DoctorAvailabilityEntity> get morningSlots =>
      doctorDetails?.morningSlots ?? [];

  List<DoctorAvailabilityEntity> get eveningSlots =>
      doctorDetails?.eveningSlots ?? [];

  DoctorAvailabilityEntity? get selectedMorningSlot =>
      morningSlots.where((s) => s.id == selectedMorningSlotId.toString()).firstOrNull;

  DoctorAvailabilityEntity? get selectedEveningSlot =>
      eveningSlots.where((s) => s.id == selectedEveningSlotId.toString()).firstOrNull;


DoctorAvailabilityState copyWith({
  DoctorDetailsEntity? doctorDetails,
  int? doctorId,
  String? errorMessage,
  RequestState? getDoctorAvailabilityState,
  RequestState? getSlotsState,
  DateTime? selectedDate,
  Object? selectedMorningSlotId = _clear, 
  Object? selectedEveningSlotId = _clear,   
}) {
  return DoctorAvailabilityState(
    doctorDetails: doctorDetails ?? this.doctorDetails,
    doctorId: doctorId ?? this.doctorId,
    errorMessage: errorMessage ?? this.errorMessage,
    getDoctorAvailabilityState:
        getDoctorAvailabilityState ?? this.getDoctorAvailabilityState,
    getSlotsState: getSlotsState ?? this.getSlotsState,
    selectedDate: selectedDate ?? this.selectedDate,

    selectedMorningSlotId: identical(selectedMorningSlotId, _clear)
        ? this.selectedMorningSlotId
        : selectedMorningSlotId as int?,

    selectedEveningSlotId: identical(selectedEveningSlotId, _clear)
        ? this.selectedEveningSlotId
        : selectedEveningSlotId as int?,
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
        selectedMorningSlotId,
        selectedEveningSlotId,
      ];
}