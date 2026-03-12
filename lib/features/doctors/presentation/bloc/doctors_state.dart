part of 'doctors_bloc.dart';

 class DoctorsState extends Equatable {
  final List<DoctorEntity> doctors;
  final String? errorMessage;
  final RequestState getDoctorsState;
  const DoctorsState({
     this.doctors= const [],
     this.errorMessage='',
     this.getDoctorsState = RequestState.initial,
  });

  DoctorsState copyWith({
    List<DoctorEntity>? doctors,
    String? errorMessage,
    RequestState? getDoctorsState,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      errorMessage: errorMessage ?? this.errorMessage,
      getDoctorsState: getDoctorsState ?? this.getDoctorsState,
    );
  }
  @override
  List<Object?> get props => [doctors, errorMessage, getDoctorsState];
}
