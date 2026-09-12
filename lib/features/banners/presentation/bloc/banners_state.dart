part of 'banners_bloc.dart';

class BannersState extends Equatable {
  final RequestState bannersState;
  final List<BannerEntity> banners;

  const BannersState({
    this.bannersState = RequestState.initial,
    this.banners = const [],
  });

  BannersState copyWith({
    RequestState? bannersState,
    List<BannerEntity>? banners,
  }) {
    return BannersState(
      bannersState: bannersState ?? this.bannersState,
      banners: banners ?? this.banners,
    );
  }

  @override
  List<Object?> get props => [bannersState, banners];
}
