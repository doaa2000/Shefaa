import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_details_entity.dart';
import 'package:shefaa_app/features/doctor_availability/domain/usecases/get_doctor_avaliability_usecase.dart';

part 'doctor_availability_event.dart';
part 'doctor_availability_state.dart';

class DoctorAvailabilityBloc
    extends Bloc<DoctorAvailabilityEvent, DoctorAvailabilityState> {
  final GetDoctorAvailabilityUsecase getDoctorAvailabilityUsecase;

  DoctorAvailabilityBloc({required this.getDoctorAvailabilityUsecase})
      : super(DoctorAvailabilityState(selectedDate: DateTime.now())) {
    on<GetDoctorAvailabilityEvent>(_getDoctorAvailability);
    on<SelectDateEvent>(_onSelectDateEvent);
    on<SelectMorningSlotEvent>(_onSelectMorningSlot);
    on<SelectEveningSlotEvent>(_onSelectEveningSlot);
  }

FutureOr<void> _getDoctorAvailability(
  GetDoctorAvailabilityEvent event,
  Emitter<DoctorAvailabilityState> emit,
) async {
  emit(state.copyWith(
    getDoctorAvailabilityState: RequestState.loading,
  ));

  final result = await getDoctorAvailabilityUsecase(
    GetDoctorAvailabilityUsecaseParameters(
      doctorId: event.doctorId,
      date: event.date,
    ),
  );

  result.fold(
    (failure) => emit(state.copyWith(
      getDoctorAvailabilityState: RequestState.error,
      errorMessage: failure.message,
    )),
    (doctor) => emit(state.copyWith(
      getDoctorAvailabilityState: RequestState.loaded,
      doctorDetails: doctor,
      selectedMorningSlotId: null,
      selectedEveningSlotId: null,
    )),
  );
}
void _onSelectMorningSlot(
  SelectMorningSlotEvent event,
  Emitter<DoctorAvailabilityState> emit,
) {
  emit(state.copyWith(
    selectedMorningSlotId: event.slotId,
    selectedEveningSlotId: null,
  ));
}

void _onSelectEveningSlot(
  SelectEveningSlotEvent event,
  Emitter<DoctorAvailabilityState> emit,
) {
  emit(state.copyWith(
    selectedEveningSlotId: event.slotId,
    selectedMorningSlotId: null,
  ));
}

FutureOr<void> _onSelectDateEvent(
  SelectDateEvent event,
  Emitter<DoctorAvailabilityState> emit,
) async {
  emit(state.copyWith(
    selectedDate: event.date,
    getSlotsState: RequestState.loading,
    selectedMorningSlotId: null,
    selectedEveningSlotId: null,
  ));

  final result = await getDoctorAvailabilityUsecase(
    GetDoctorAvailabilityUsecaseParameters(
      doctorId: state.doctorDetails!.doctor.id.toString(),
      date: event.date,
    ),
  );

  result.fold(
    (failure) => emit(state.copyWith(
      getSlotsState: RequestState.error,
      errorMessage: failure.message,
    )),
    (doctor) => emit(state.copyWith(
      getSlotsState: RequestState.loaded,
      doctorDetails: doctor,
    )),
  );
}
}