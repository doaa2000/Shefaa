import 'package:equatable/equatable.dart';

class SpecialtyEntity extends Equatable {
  final int id;
  final String name;
  final String? icon;

  const SpecialtyEntity({required this.id, required this.name, this.icon});

  @override
  List<Object?> get props => [id, name, icon];
}
