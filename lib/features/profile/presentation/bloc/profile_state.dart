part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final RequestState profileState;
  final String profileMessage;
  final UserEntity? user;

  /// Tracks the save on the update-profile screen, separately from the load
  /// above -- the screen has to keep showing the form while the save runs.
  final RequestState updateState;
  final String updateMessage;

  const ProfileState({
    this.profileState = RequestState.initial,
    this.profileMessage = '',
    this.user,
    this.updateState = RequestState.initial,
    this.updateMessage = '',
  });

  ProfileState copyWith({
    RequestState? profileState,
    String? profileMessage,
    UserEntity? user,
    RequestState? updateState,
    String? updateMessage,
  }) {
    return ProfileState(
      profileState: profileState ?? this.profileState,
      profileMessage: profileMessage ?? this.profileMessage,
      user: user ?? this.user,
      updateState: updateState ?? this.updateState,
      updateMessage: updateMessage ?? this.updateMessage,
    );
  }

  @override
  List<Object?> get props => [
        profileState,
        profileMessage,
        user,
        updateState,
        updateMessage,
      ];
}
