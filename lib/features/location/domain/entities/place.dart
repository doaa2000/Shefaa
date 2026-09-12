import 'package:equatable/equatable.dart';

/// A governorate or a city. Both are a name with an id and nothing else, so
/// they share one type rather than two identical ones.
class PlaceEntity extends Equatable {
  final int id;
  final String name;

  const PlaceEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
