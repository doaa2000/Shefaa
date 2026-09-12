import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';

/// The patient's photograph, and the way to change it.
///
/// The picture is uploaded the moment it is chosen rather than waiting for the
/// form's save button: half the screen is about a password, and an upload that
/// only happened on save would leave the patient looking at a picture that is
/// not stored yet with nothing saying so.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, required this.userId});

  final String userId;

  /// Long enough for a portrait to look sharp, small enough not to keep a
  /// patient on mobile data waiting. The picker does the resizing on device.
  static const _maxSide = 720.0;
  static const _quality = 82;

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<ProfileBloc>();
    final messenger = ScaffoldMessenger.of(context);

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
    } catch (_) {
      // A refused permission, or no gallery on the device. Neither is worth a
      // red screen, and neither is the patient's fault.
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('تعذر فتح معرض الصور.'),
        ));
      return;
    }

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    bloc.add(UpdateAvatarEvent(
      userId: userId,
      bytes: bytes,
      extension: _extensionOf(picked.name),
      contentType: picked.mimeType,
    ));
  }

  /// The name is the patient's file name, so it may have no extension at all,
  /// or one in capitals. jpg is the safe assumption for a photograph.
  static String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot <= 0 || dot == name.length - 1) return 'jpg';
    final ext = name.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'jpg';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.avatarState != current.avatarState,
      listener: (context, state) {
        if (state.avatarState == RequestState.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(
                state.avatarMessage.isEmpty
                    ? 'تعذر رفع الصورة.'
                    : state.avatarMessage,
              ),
              backgroundColor: Colors.red.shade700,
            ));
        }
      },
      builder: (context, state) {
        final uploading = state.avatarState == RequestState.loading;
        final user = state.user;

        return Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  _Circle(
                    imageUrl: user?.image,
                    name: user?.name,
                    uploading: uploading,
                  ),
                  Material(
                    color: AppColors.primaryColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: uploading ? null : () => _pick(context),
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: uploading ? null : () => _pick(context),
                child: Text(
                  uploading ? 'جارٍ الرفع…' : 'تغيير الصورة',
                  style: TextStyles.meduim14
                      .copyWith(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    required this.imageUrl,
    required this.name,
    required this.uploading,
  });

  final String? imageUrl;
  final String? name;
  final bool uploading;

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return Container(
      width: _size,
      height: _size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url.isNotEmpty)
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, _) => _Initial(name: name),
              // Their own initial, never a stock portrait: a photograph of a
              // stranger standing in for the patient is worse than none.
              errorWidget: (context, _, _) => _Initial(name: name),
            )
          else
            _Initial(name: name),
          if (uploading)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
              ),
              child: const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';

    return ColoredBox(
      color: AppColors.primaryColor,
      child: Center(
        child: trimmed.isEmpty
            ? const Icon(Icons.person, color: Colors.white, size: 40)
            : Text(
                trimmed.substring(0, 1),
                style: TextStyles.bold24.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
