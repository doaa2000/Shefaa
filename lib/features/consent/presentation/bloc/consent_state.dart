part of 'consent_bloc.dart';

class ConsentState extends Equatable {
  final RequestState acceptState;
  final String message;

  const ConsentState({
    this.acceptState = RequestState.initial,
    this.message = '',
  });

  ConsentState copyWith({RequestState? acceptState, String? message}) {
    return ConsentState(
      acceptState: acceptState ?? this.acceptState,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [acceptState, message];
}
