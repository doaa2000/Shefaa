part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final RequestState profileState;
  final String profileMessage;
  final UserEntity? user;

  const ProfileState({
    this.profileState = RequestState.initial,
    this.profileMessage = '',
    this.user,
  });

  ProfileState copyWith({
    RequestState? profileState,
    String? profileMessage,
    UserEntity? user,
  }) {
    return ProfileState(
      profileState: profileState ?? this.profileState,
      profileMessage: profileMessage ?? this.profileMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [profileState, profileMessage, user];
}