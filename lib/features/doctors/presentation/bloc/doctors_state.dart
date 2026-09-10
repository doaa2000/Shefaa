part of 'doctors_bloc.dart';

 class DoctorsState extends Equatable {
  final List<DoctorEntity> doctors;
  final String? errorMessage;
  final RequestState getDoctorsState;

  /// The specialty the current list belongs to. Kept so a failed load can be
  /// retried without the widget having to carry the id itself.
  final int? specialtyId;

  const DoctorsState({
     this.doctors= const [],
     this.errorMessage='',
     this.getDoctorsState = RequestState.initial,
     this.specialtyId,
  });

  DoctorsState copyWith({
    List<DoctorEntity>? doctors,
    String? errorMessage,
    RequestState? getDoctorsState,
    int? specialtyId,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      errorMessage: errorMessage ?? this.errorMessage,
      getDoctorsState: getDoctorsState ?? this.getDoctorsState,
      specialtyId: specialtyId ?? this.specialtyId,
    );
  }
  @override
  List<Object?> get props =>
      [doctors, errorMessage, getDoctorsState, specialtyId];
}
