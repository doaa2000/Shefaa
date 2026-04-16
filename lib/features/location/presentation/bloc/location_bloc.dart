import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationState()) {
    on<ToggleGovernorateDropdownEvent>(_toggleGovernorateDropdown);
    on<SelectGovernorateEvent>(_selectGovernorate);
    on<ToggleCityDropdown>(_selectCityDropdown);
        on<SelectCityEvent>(_selectCity);
  }

  FutureOr<void> _toggleGovernorateDropdown(ToggleGovernorateDropdownEvent event, Emitter<LocationState> emit) {
    emit(state.copyWith(isGovernorateOpen: !state.isGovernorateOpen));
  }
  FutureOr<void> _selectGovernorate(SelectGovernorateEvent event, Emitter<LocationState> emit) {
    emit(state.copyWith(selectedGovernorate: event.value, isGovernorateOpen: false));
  }

  FutureOr<void> _selectCityDropdown(ToggleCityDropdown event, Emitter<LocationState> emit) {
    emit(state.copyWith(isCityOpen: !state.isCityOpen));
  }

  FutureOr<void> _selectCity(SelectCityEvent event, Emitter<LocationState> emit) {
    emit(state.copyWith(selectedCity: event.value, isCityOpen: false));
  }
}
