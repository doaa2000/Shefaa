import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/banners/domain/entities/banner.dart';
import 'package:shefaa_app/features/banners/domain/usecases/get_banners_usecase.dart';

part 'banners_event.dart';
part 'banners_state.dart';

class BannersBloc extends Bloc<BannersEvent, BannersState> {
  final GetBannersUseCase getBannersUseCase;

  BannersBloc({required this.getBannersUseCase}) : super(const BannersState()) {
    on<GetBannersEvent>(_getBanners);
  }

  FutureOr<void> _getBanners(
    GetBannersEvent event,
    Emitter<BannersState> emit,
  ) async {
    emit(state.copyWith(bannersState: RequestState.loading));

    final result = await getBannersUseCase(const NoParameters());

    result.fold(
      // A banner is decoration. Failing to load one is not worth telling the
      // patient about, and not worth a red box on the home screen -- the
      // carousel simply does not appear.
      (_) => emit(state.copyWith(bannersState: RequestState.error)),
      (banners) => emit(state.copyWith(
        bannersState: RequestState.loaded,
        banners: banners,
      )),
    );
  }
}
