part of 'consent_bloc.dart';

sealed class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

class AcceptHealthConsentEvent extends ConsentEvent {
  const AcceptHealthConsentEvent();
}

/// The terms and the privacy notice together. One event because they are one
/// tick on one screen; two rows underneath because they are two documents with
/// versions of their own.
class AcceptLegalConsentEvent extends ConsentEvent {
  const AcceptLegalConsentEvent();
}
