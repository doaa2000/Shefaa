part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final RequestState profileState;
  final String profileMessage;
  final UserEntity? user;

  /// Tracks the save on the update-profile screen, separately from the load
  /// above -- the screen has to keep showing the form while the save runs.
  final RequestState updateState;
  final String updateMessage;

  /// Tracks the photograph upload on its own: it runs while the rest of the
  /// form sits there being edited, and must not grey the whole screen out.
  final RequestState avatarState;
  final String avatarMessage;

  const ProfileState({
    this.profileState = RequestState.initial,
    this.profileMessage = '',
    this.user,
    this.updateState = RequestState.initial,
    this.updateMessage = '',
    this.avatarState = RequestState.initial,
    this.avatarMessage = '',
  });

  ProfileState copyWith({
    RequestState? profileState,
    String? profileMessage,
    UserEntity? user,
    RequestState? updateState,
    String? updateMessage,
    RequestState? avatarState,
    String? avatarMessage,
  }) {
    return ProfileState(
      profileState: profileState ?? this.profileState,
      profileMessage: profileMessage ?? this.profileMessage,
      user: user ?? this.user,
      updateState: updateState ?? this.updateState,
      updateMessage: updateMessage ?? this.updateMessage,
      avatarState: avatarState ?? this.avatarState,
      avatarMessage: avatarMessage ?? this.avatarMessage,
    );
  }

  @override
  List<Object?> get props => [
        profileState,
        profileMessage,
        user,
        updateState,
        updateMessage,
        avatarState,
        avatarMessage,
      ];
}
