part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}
class HomePageChanged extends HomeEvent {
  final int index;

  const HomePageChanged(this.index);

  @override
  List<Object> get props => [index];
}