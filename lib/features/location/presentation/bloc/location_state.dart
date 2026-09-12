part of 'location_bloc.dart';

class LocationState extends Equatable {
  final RequestState governoratesState;
  final RequestState citiesState;
  final List<PlaceEntity> governorates;
  final List<PlaceEntity> cities;
  final PlaceEntity? selectedGovernorate;
  final PlaceEntity? selectedCity;
  final bool isGovernorateOpen;
  final bool isCityOpen;
  final String errorMessage;

  /// Set once the choice is written, so the screen knows to close itself.
  final bool saved;

  const LocationState({
    this.governoratesState = RequestState.initial,
    this.citiesState = RequestState.initial,
    this.governorates = const [],
    this.cities = const [],
    this.selectedGovernorate,
    this.selectedCity,
    this.isGovernorateOpen = false,
    this.isCityOpen = false,
    this.errorMessage = '',
    this.saved = false,
  });

  bool get canSave => selectedGovernorate != null && selectedCity != null;

  LocationState copyWith({
    RequestState? governoratesState,
    RequestState? citiesState,
    List<PlaceEntity>? governorates,
    List<PlaceEntity>? cities,
    PlaceEntity? selectedGovernorate,
    PlaceEntity? selectedCity,
    bool? isGovernorateOpen,
    bool? isCityOpen,
    String? errorMessage,
    bool? saved,
    // copyWith cannot pass null to mean "set this to null", so clearing the
    // city after the governorate changes needs a flag of its own.
    bool clearSelectedCity = false,
  }) {
    return LocationState(
      governoratesState: governoratesState ?? this.governoratesState,
      citiesState: citiesState ?? this.citiesState,
      governorates: governorates ?? this.governorates,
      cities: cities ?? this.cities,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedCity:
          clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      isGovernorateOpen: isGovernorateOpen ?? this.isGovernorateOpen,
      isCityOpen: isCityOpen ?? this.isCityOpen,
      errorMessage: errorMessage ?? this.errorMessage,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
        governoratesState,
        citiesState,
        governorates,
        cities,
        selectedGovernorate,
        selectedCity,
        isGovernorateOpen,
        isCityOpen,
        errorMessage,
        saved,
      ];
}
