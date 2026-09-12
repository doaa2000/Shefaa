import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/services/selected_city_service.dart';
import 'package:shefaa_app/features/location/domain/entities/place.dart';
import 'package:shefaa_app/features/location/domain/usecases/get_places_usecase.dart';

part 'location_event.dart';
part 'location_state.dart';

/// firstWhere throws when nothing matches, and the codebase's own firstOrNull
/// extensions live in files this one does not import.
PlaceEntity? _byId(List<PlaceEntity> places, int id) {
  for (final place in places) {
    if (place.id == id) return place;
  }
  return null;
}

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetGovernoratesUseCase getGovernoratesUseCase;
  final GetCitiesUseCase getCitiesUseCase;
  final SelectedCityService selectedCityService;

  LocationBloc({
    required this.getGovernoratesUseCase,
    required this.getCitiesUseCase,
    required this.selectedCityService,
  }) : super(const LocationState()) {
    on<LoadLocationEvent>(_load);
    on<ToggleGovernorateDropdownEvent>(_toggleGovernorateDropdown);
    on<SelectGovernorateEvent>(_selectGovernorate);
    on<ToggleCityDropdownEvent>(_toggleCityDropdown);
    on<SelectCityEvent>(_selectCity);
    on<SaveLocationEvent>(_save);
    on<ClearLocationEvent>(_clear);
  }

  FutureOr<void> _load(
    LoadLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(governoratesState: RequestState.loading));

    final result = await getGovernoratesUseCase(const NoParameters());

    await result.fold(
      (failure) async => emit(state.copyWith(
        governoratesState: RequestState.error,
        errorMessage: failure.message,
      )),
      (governorates) async {
        emit(state.copyWith(
          governoratesState: RequestState.loaded,
          governorates: governorates,
        ));

        // Reopen on what the patient chose last time, cities already filled in,
        // so the screen shows the current answer rather than two empty boxes.
        final saved = selectedCityService.value;
        if (saved == null) return;

        final governorate = _byId(governorates, saved.governorateId);
        if (governorate == null) return;

        emit(state.copyWith(selectedGovernorate: governorate));
        await _loadCities(governorate.id, emit, preselectCityId: saved.cityId);
      },
    );
  }

  FutureOr<void> _toggleGovernorateDropdown(
    ToggleGovernorateDropdownEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      isGovernorateOpen: !state.isGovernorateOpen,
      isCityOpen: false,
    ));
  }

  FutureOr<void> _selectGovernorate(
    SelectGovernorateEvent event,
    Emitter<LocationState> emit,
  ) async {
    // A city belongs to one governorate. Keeping the old city after the
    // governorate changes is how the screen used to claim that Aswan is in
    // Cairo, so it is cleared here.
    emit(state.copyWith(
      selectedGovernorate: event.governorate,
      isGovernorateOpen: false,
      clearSelectedCity: true,
    ));

    await _loadCities(event.governorate.id, emit);
  }

  Future<void> _loadCities(
    int governorateId,
    Emitter<LocationState> emit, {
    int? preselectCityId,
  }) async {
    emit(state.copyWith(citiesState: RequestState.loading, cities: const []));

    final result = await getCitiesUseCase(governorateId);

    result.fold(
      (failure) => emit(state.copyWith(
        citiesState: RequestState.error,
        errorMessage: failure.message,
      )),
      (cities) {
        emit(state.copyWith(
          citiesState: RequestState.loaded,
          cities: cities,
        ));

        if (preselectCityId == null) return;
        final city = _byId(cities, preselectCityId);
        if (city != null) emit(state.copyWith(selectedCity: city));
      },
    );
  }

  FutureOr<void> _toggleCityDropdown(
    ToggleCityDropdownEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      isCityOpen: !state.isCityOpen,
      isGovernorateOpen: false,
    ));
  }

  FutureOr<void> _selectCity(
    SelectCityEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(selectedCity: event.city, isCityOpen: false));
  }

  FutureOr<void> _save(
    SaveLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    final governorate = state.selectedGovernorate;
    final city = state.selectedCity;
    if (governorate == null || city == null) return;

    await selectedCityService.save(SelectedCity(
      governorateId: governorate.id,
      governorateName: governorate.name,
      cityId: city.id,
      cityName: city.name,
    ));

    emit(state.copyWith(saved: true));
  }

  FutureOr<void> _clear(
    ClearLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    await selectedCityService.clear();
    emit(state.copyWith(saved: true));
  }
}
