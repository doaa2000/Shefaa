part of 'home_bloc.dart';

class HomeState extends Equatable {
  final int currentIndex;
  final List<SpecialtyEntity> specialties;
  final RequestState specialtiesState;
  const HomeState({
    this.currentIndex = 0,
    this.specialties = const [],
    this.specialtiesState = RequestState.initial,
  });

  HomeState copyWith({
    int? currentIndex,
    List<SpecialtyEntity>? specialties,
    RequestState? specialtiesState,
  }) {
    return HomeState(
      specialties: specialties ?? this.specialties,
      specialtiesState: specialtiesState ?? this.specialtiesState,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [currentIndex, specialties, specialtiesState];
}
