import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:shefaa_app/features/profile/domain/usecases/profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  GetProfileUseCase getProfileUseCase;
  ProfileBloc({required this.getProfileUseCase}) : super(ProfileState()) {
    on<GetProfileEvent>(_getProfile);
  }

  FutureOr<void> _getProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(profileState: RequestState.loading));
    final result = await getProfileUseCase(
      GetProfileUseCaseParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          profileState: RequestState.error,
          profileMessage: failure.message,
        ),
      ),
      (user) =>
          emit(state.copyWith(profileState: RequestState.loaded, user: user)),
    );
  }

  void setUser(UserEntity user) {
    emit(state.copyWith(user: user));
  }

  void clearUser() {
    emit(const ProfileState());
  }
}
