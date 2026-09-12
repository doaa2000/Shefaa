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
  UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileState()) {
    on<GetProfileEvent>(_getProfile);
    on<UpdateProfileEvent>(_updateProfile);
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

  FutureOr<void> _updateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state.user;
    if (current == null) {
      // Nothing was loaded, so there is no id to write against and no gender
      // or email to carry over. Saving here would blank the row.
      emit(
        state.copyWith(
          updateState: RequestState.error,
          updateMessage: 'تعذر تحميل البيانات، حاولي مرة أخرى',
        ),
      );
      return;
    }

    emit(state.copyWith(updateState: RequestState.loading, updateMessage: ''));

    final result = await updateProfileUseCase(
      UpdateProfileUseCaseParams(
        user: UserEntity(
          id: current.id,
          email: current.email,
          name: event.name,
          phone: event.phone,
          gender: current.gender,
          birthDate: event.birthDate,
        ),
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          updateState: RequestState.error,
          updateMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          updateState: RequestState.loaded,
          user: user,
          profileState: RequestState.loaded,
        ),
      ),
    );
  }
}
