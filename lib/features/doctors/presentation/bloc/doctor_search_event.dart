part of 'doctor_search_bloc.dart';

abstract class DoctorSearchEvent extends Equatable {
  const DoctorSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchDoctorsEvent extends DoctorSearchEvent {
  final String query;

  const SearchDoctorsEvent(this.query);

  @override
  List<Object> get props => [query];
}
