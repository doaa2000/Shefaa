import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/features/consent/domain/usecases/consent_usecases.dart';

part 'consent_event.dart';
part 'consent_state.dart';

class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  final AcceptConsentUseCase acceptConsentUseCase;

  ConsentBloc({required this.acceptConsentUseCase})
      : super(const ConsentState()) {
    on<AcceptHealthConsentEvent>(_accept);
  }

  FutureOr<void> _accept(
    AcceptHealthConsentEvent event,
    Emitter<ConsentState> emit,
  ) async {
    emit(state.copyWith(acceptState: RequestState.loading, message: ''));

    final result = await acceptConsentUseCase(
      const ConsentParams(
        kind: 'health_data',
        version: AppConsent.healthDataVersion,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        acceptState: RequestState.error,
        message: failure.message,
      )),
      (_) => emit(state.copyWith(acceptState: RequestState.loaded)),
    );
  }
}
