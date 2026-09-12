import 'package:shefaa_app/features/location/domain/entities/place.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({required super.id, required super.name});

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String? ?? '',
    );
  }
}
