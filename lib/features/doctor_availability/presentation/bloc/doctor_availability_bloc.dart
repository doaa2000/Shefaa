import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';
import 'package:shefaa_app/features/doctor_availability/domain/usecases/get_doctor_avaliability_usecase.dart';

part 'doctor_availability_event.dart';
part 'doctor_availability_state.dart';

class DoctorAvailabilityBloc
    extends Bloc<DoctorAvailabilityEvent, DoctorAvailabilityState> {
  final GetDoctorAvailabilityUsecase getDoctorAvailabilityUsecase;
  DoctorAvailabilityBloc({required this.getDoctorAvailabilityUsecase})
    : super(DoctorAvailabilityState()) {
    on<DoctorAvailabilityEvent>(_getDoctorAvailability);
        on<SelectDayEvent>(_onSelectDayEvent);
    on<SelectHourEvent>(_onSelectHourEvent);
  }

  FutureOr<void> _getDoctorAvailability(
    DoctorAvailabilityEvent event,
    Emitter<DoctorAvailabilityState> emit,
  ) async {
    emit(state.copyWith(getDoctorAvailabilityState: RequestState.loading));
    final result = await getDoctorAvailabilityUsecase(
      GetDoctorAvailabilityUsecaseParameters(
        doctorId: (event as GetDoctorAvailabilityEvent).doctorId,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          getDoctorAvailabilityState: RequestState.error,
          errorMessage: failure.message,
        ),
      ),
      (availability) => emit(
        state.copyWith(
          getDoctorAvailabilityState: RequestState.loaded,
          doctorAvailability: availability,
        ),
      ),
    );
  }
   void _onSelectDayEvent(
      SelectDayEvent event, Emitter<DoctorAvailabilityState> emit) {
    emit(state.copyWith(selectedDayIndex: event.selectedDay, selectedHourIndex: 0));
  }

  void _onSelectHourEvent(
      SelectHourEvent event, Emitter<DoctorAvailabilityState> emit) {
    emit(state.copyWith(selectedHourIndex: event.selectedHour));
  }
}
