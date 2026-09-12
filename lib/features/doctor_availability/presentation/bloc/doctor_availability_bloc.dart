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
    on<SelectDateEvent>(_onSelectDate);
    on<SelectWindowEvent>(_onSelectWindow);
  }

  Future<void> _getDoctorAvailability(
    GetDoctorAvailabilityEvent event,
    Emitter<DoctorAvailabilityState> emit,
  ) async {
    emit(state.copyWith(
      getDoctorAvailabilityState: RequestState.loading,
      doctorId: event.doctorId,
      selectedDate: event.date,
      selectedWindow: null,
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
      (details) => emit(state.copyWith(
        getDoctorAvailabilityState: RequestState.loaded,
        getSlotsState: RequestState.loaded,
        doctorDetails: details,
        selectedWindow: _onlyOpenWindow(details),
      )),
    );
  }

  Future<void> _onSelectDate(
    SelectDateEvent event,
    Emitter<DoctorAvailabilityState> emit,
  ) async {
    emit(state.copyWith(
      selectedDate: event.date,
      getSlotsState: RequestState.loading,
      selectedWindow: null,
    ));

    // Not doctorDetails!.doctor.id: when the first load failed there are no
    // details, and force-unwrapping crashed the screen on a date tap.
    final doctorId = state.doctorId;
    if (doctorId == null) {
      emit(state.copyWith(
        getSlotsState: RequestState.error,
        errorMessage: 'لم يتم تحديد الطبيب',
      ));
      return;
    }

    final result = await getDoctorAvailabilityUsecase(
      GetDoctorAvailabilityUsecaseParameters(
        doctorId: doctorId,
        date: event.date,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        getSlotsState: RequestState.error,
        errorMessage: failure.message,
      )),
      (details) => emit(state.copyWith(
        getSlotsState: RequestState.loaded,
        doctorDetails: details,
        selectedWindow: _onlyOpenWindow(details),
      )),
    );
  }

  void _onSelectWindow(
    SelectWindowEvent event,
    Emitter<DoctorAvailabilityState> emit,
  ) {
    emit(state.copyWith(
      selectedWindow: '${event.session}|${event.startTime}',
    ));
  }

  /// With one window open there is nothing to choose, so choose it. Picking it
  /// for the patient saves a tap that has only one possible outcome.
  static String? _onlyOpenWindow(DoctorDetailsEntity details) {
    final open = details.sessions.where((s) => !s.isFull).toList();
    return open.length == 1
        ? DoctorAvailabilityState.windowKey(open.first)
        : null;
  }
}
