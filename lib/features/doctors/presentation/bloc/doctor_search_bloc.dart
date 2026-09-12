import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/usecases/get_doctors_usecase.dart';

part 'doctor_search_event.dart';
part 'doctor_search_state.dart';

class DoctorSearchBloc extends Bloc<DoctorSearchEvent, DoctorSearchState> {
  final SearchDoctorsUseCase searchDoctorsUseCase;

  DoctorSearchBloc({required this.searchDoctorsUseCase})
      : super(const DoctorSearchState()) {
    on<SearchDoctorsEvent>(_search);
  }

  FutureOr<void> _search(
    SearchDoctorsEvent event,
    Emitter<DoctorSearchState> emit,
  ) async {
    final query = event.query.trim();

    // Back to the resting state rather than showing the last search's results
    // under an empty box.
    if (query.isEmpty) {
      emit(const DoctorSearchState());
      return;
    }

    emit(state.copyWith(searchState: RequestState.loading, query: query));

    final result = await searchDoctorsUseCase(query);

    // Typing moved on while this was in flight, so its answer is about a
    // question nobody is asking any more.
    if (query != state.query) return;

    result.fold(
      (failure) => emit(state.copyWith(
        searchState: RequestState.error,
        errorMessage: failure.message,
      )),
      (doctors) => emit(state.copyWith(
        searchState: RequestState.loaded,
        doctors: doctors,
      )),
    );
  }
}
