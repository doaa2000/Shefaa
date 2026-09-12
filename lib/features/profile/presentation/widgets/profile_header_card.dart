import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.profileState == RequestState.loading) {
          return _loadingCard();
        }

        if (state.profileState == RequestState.error) {
          return _errorCard(state.profileMessage);
        }

        if (state.user == null) {
          return const SizedBox.shrink();
        }

        final user = state.user!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: .05),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  _Avatar(imageUrl: user.image, name: user.name),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? '—',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔄 Loading
  Widget _loadingCard() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// ❌ Error
  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

/// The patient's own photograph, falling back to their initial.
///
/// Never a stock portrait: a stranger's face standing in for the patient is
/// worse than no picture, and this card used to show a generic figure even for
/// someone who had one.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasPhoto = url != null && url.isNotEmpty;

    return Container(
      width: 70,
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, _) => _Initial(name: name),
              errorWidget: (context, _, _) => _Initial(name: name),
            )
          : _Initial(name: name),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';

    return Center(
      child: trimmed.isEmpty
          ? const Icon(Icons.person, size: 34, color: AppColors.primaryColor)
          : Text(
              trimmed.substring(0, 1),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
    );
  }
}
