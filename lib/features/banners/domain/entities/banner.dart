import 'package:equatable/equatable.dart';

/// A home screen banner. Content, not code: the rows come from the admin panel,
/// so changing what the app shows does not mean shipping a new build.
class BannerEntity extends Equatable {
  final int id;
  final String imageUrl;
  final String? title;
  final String? subtitle;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
  });

  bool get hasText =>
      (title ?? '').trim().isNotEmpty || (subtitle ?? '').trim().isNotEmpty;

  @override
  List<Object?> get props => [id, imageUrl, title, subtitle];
}
