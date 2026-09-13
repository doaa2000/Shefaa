import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/features/consent/domain/usecases/consent_usecases.dart';

part 'consent_event.dart';
part 'consent_state.dart';

class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  final AcceptConsentUseCase acceptConsentUseCase;

  ConsentBloc({required this.acceptConsentUseCase})
      : super(const ConsentState()) {
    on<AcceptHealthConsentEvent>(_accept);
    on<AcceptLegalConsentEvent>(_acceptLegal);
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

  /// Two rows, one after the other. The second is only attempted if the first
  /// was written: recording an agreement to the privacy notice while the terms
  /// went missing would leave a record that says something untrue.
  FutureOr<void> _acceptLegal(
    AcceptLegalConsentEvent event,
    Emitter<ConsentState> emit,
  ) async {
    emit(state.copyWith(acceptState: RequestState.loading, message: ''));

    for (final params in const [
      ConsentParams(kind: 'terms', version: AppLegal.termsVersion),
      ConsentParams(kind: 'privacy', version: AppLegal.privacyVersion),
    ]) {
      final result = await acceptConsentUseCase(params);

      final failure = result.fold<String?>(
        (failure) => failure.message,
        (_) => null,
      );

      if (failure != null) {
        emit(state.copyWith(
          acceptState: RequestState.error,
          message: failure,
        ));
        return;
      }
    }

    emit(state.copyWith(acceptState: RequestState.loaded));
  }
}
