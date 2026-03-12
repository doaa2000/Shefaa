import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/usecases/get_doctors_usecase.dart';

part 'doctors_event.dart';
part 'doctors_state.dart';

class DoctorsBloc extends Bloc<DoctorsEvent, DoctorsState> {
  final GetDoctorsUseCase getDoctorsUseCase;
  DoctorsBloc({required this.getDoctorsUseCase}) : super(DoctorsState()) {
    on<GetDoctorsEvent>(_onGetDoctors);
  }

  FutureOr<void> _onGetDoctors(
    GetDoctorsEvent event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(getDoctorsState: RequestState.loading));
    final result = await getDoctorsUseCase(
      GetDoctorsUsecaseParameters(specialtyId: event.specialtyId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          getDoctorsState: RequestState.error,
          errorMessage: failure.message,
        ),
      ),
      (doctors) => emit(
      
        state.copyWith(getDoctorsState: RequestState.loaded, doctors: doctors),
      ),
    );
  }
}
