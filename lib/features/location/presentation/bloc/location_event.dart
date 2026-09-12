part of 'location_bloc.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocationEvent extends LocationEvent {
  const LoadLocationEvent();
}

class ToggleGovernorateDropdownEvent extends LocationEvent {
  const ToggleGovernorateDropdownEvent();
}

class ToggleCityDropdownEvent extends LocationEvent {
  const ToggleCityDropdownEvent();
}

class SelectGovernorateEvent extends LocationEvent {
  final PlaceEntity governorate;

  const SelectGovernorateEvent(this.governorate);

  @override
  List<Object?> get props => [governorate];
}

class SelectCityEvent extends LocationEvent {
  final PlaceEntity city;

  const SelectCityEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class SaveLocationEvent extends LocationEvent {
  const SaveLocationEvent();
}

/// Back to every city.
class ClearLocationEvent extends LocationEvent {
  const ClearLocationEvent();
}
