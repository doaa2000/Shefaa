import 'package:shefaa_app/features/banners/domain/entities/banner.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.subtitle,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: (map['id'] as num).toInt(),
      imageUrl: map['image_url'] as String? ?? '',
      title: map['title'] as String?,
      subtitle: map['subtitle'] as String?,
    );
  }
}
