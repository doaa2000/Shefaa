part of 'doctor_search_bloc.dart';

class DoctorSearchState extends Equatable {
  final RequestState searchState;
  final List<DoctorEntity> doctors;

  /// What the results on screen are an answer to. Kept so a reply that arrives
  /// after the patient has typed something else can be discarded.
  final String query;

  final String? errorMessage;

  const DoctorSearchState({
    this.searchState = RequestState.initial,
    this.doctors = const [],
    this.query = '',
    this.errorMessage,
  });

  bool get hasSearched => query.isNotEmpty;

  DoctorSearchState copyWith({
    RequestState? searchState,
    List<DoctorEntity>? doctors,
    String? query,
    String? errorMessage,
  }) {
    return DoctorSearchState(
      searchState: searchState ?? this.searchState,
      doctors: doctors ?? this.doctors,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [searchState, doctors, query, errorMessage];
}
