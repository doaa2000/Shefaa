part of 'location_bloc.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class ToggleGovernorateDropdownEvent extends LocationEvent {}

class ToggleCityDropdown extends LocationEvent {}

class SelectGovernorateEvent extends LocationEvent {
  final String value;

  const SelectGovernorateEvent(this.value);

  @override
  List<Object> get props => [value];
}
class SelectCityEvent extends LocationEvent {
  final String value;

  const SelectCityEvent(this.value);

  @override
  List<Object> get props => [value];
}