import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<HomePageChanged>(_onHomePageChanged);
  }

  FutureOr<void> _onHomePageChanged(
    HomePageChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }
}
