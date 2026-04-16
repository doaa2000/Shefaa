part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool isGovernorateOpen;
    final bool isCityOpen;

  final String? selectedGovernorate;
  final String? selectedCity;

  const LocationState({
    this.isGovernorateOpen = false,
    this.isCityOpen = false,
    this.selectedGovernorate,
    this.selectedCity,
  });

  LocationState copyWith({
    bool? isGovernorateOpen,
    bool? isCityOpen,
    String? selectedGovernorate,
    String? selectedCity,

  }) {
    return LocationState(
      isGovernorateOpen: isGovernorateOpen ?? this.isGovernorateOpen,
      isCityOpen: isCityOpen ?? this.isCityOpen,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }

  @override
  List<Object?> get props => [isGovernorateOpen, isCityOpen, selectedGovernorate, selectedCity];
} 