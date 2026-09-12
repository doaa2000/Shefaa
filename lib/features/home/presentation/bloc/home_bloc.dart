import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/home/domain/entities/specialty.dart';
import 'package:shefaa_app/features/home/domain/usecases/get_specialties_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetSpecialtiesUsecase getSpecialtiesUsecase;
  HomeBloc({required this.getSpecialtiesUsecase}) : super(HomeState()) {
    on<HomePageChanged>(_onHomePageChanged);
    on<GetSpecialtiesEvent>(_onGetSpecialtiesEvent);
    // on<GetDoctorsEvent>(_onGetDoctorsEvent);
    // on<GetBookingsEvent>(_onGetBookingsEvent);
  }

  FutureOr<void> _onHomePageChanged(
    HomePageChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }
FutureOr<void> _onGetSpecialtiesEvent(
  GetSpecialtiesEvent event,
  Emitter<HomeState> emit,
) async {
  emit(state.copyWith(specialtiesState: RequestState.loading));

  final result = await getSpecialtiesUsecase(const NoParameters());

  result.fold(
    (failure) {
      emit(state.copyWith(specialtiesState: RequestState.error));
    },
    (specialties) {
      emit(state.copyWith(
        specialties: specialties,
        specialtiesState: RequestState.loaded,
      ));
    },
  );
}
}
