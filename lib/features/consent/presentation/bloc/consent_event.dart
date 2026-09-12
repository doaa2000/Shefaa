part of 'consent_bloc.dart';

sealed class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

class AcceptHealthConsentEvent extends ConsentEvent {
  const AcceptHealthConsentEvent();
}
