part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  final String userId;

  const GetProfileEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// A newly chosen photograph, already read into memory by the picker.
class UpdateAvatarEvent extends ProfileEvent {
  final String userId;
  final List<int> bytes;
  final String extension;
  final String? contentType;

  const UpdateAvatarEvent({
    required this.userId,
    required this.bytes,
    required this.extension,
    this.contentType,
  });

  // The bytes are left out of props: the observer logs every event, and a
  // photograph in the device log helps nobody. The length tells two apart.
  @override
  List<Object> get props => [userId, bytes.length, extension];
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String phone;

  /// Already formatted as `yyyy-MM-dd`, or null when the patient never picked
  /// one -- `birth_date` is a nullable date column.
  final String? birthDate;

  /// Null or empty means "leave my password alone".
  final String? newPassword;

  const UpdateProfileEvent({
    required this.name,
    required this.phone,
    this.birthDate,
    this.newPassword,
  });

  // newPassword is deliberately left out of props so it never reaches the bloc
  // observer's log. name/phone/birthDate are enough to tell two events apart.
  @override
  List<Object> get props => [name, phone, birthDate ?? ''];
}
