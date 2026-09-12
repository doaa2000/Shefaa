import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor_schedule.dart';
import 'package:shefaa_app/features/doctors/domain/usecases/get_doctors_usecase.dart';

part 'doctor_details_event.dart';
part 'doctor_details_state.dart';

/// The doctor themselves arrives with the route -- the list already holds every
/// field the page shows. Only the weekly pattern has to be fetched, so that is
/// all this bloc does.
class DoctorDetailsBloc extends Bloc<DoctorDetailsEvent, DoctorDetailsState> {
  final GetDoctorScheduleUseCase getDoctorScheduleUseCase;

  DoctorDetailsBloc({required this.getDoctorScheduleUseCase})
      : super(const DoctorDetailsState()) {
    on<GetDoctorScheduleEvent>(_getSchedule);
  }

  FutureOr<void> _getSchedule(
    GetDoctorScheduleEvent event,
    Emitter<DoctorDetailsState> emit,
  ) async {
    emit(state.copyWith(scheduleState: RequestState.loading));

    final result = await getDoctorScheduleUseCase(event.doctorId);

    result.fold(
      (failure) => emit(state.copyWith(
        scheduleState: RequestState.error,
        errorMessage: failure.message,
      )),
      (schedule) => emit(state.copyWith(
        scheduleState: RequestState.loaded,
        schedule: schedule,
      )),
    );
  }
}
