import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/selected_city_service.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/location/presentation/screens/location_screen.dart';
import 'package:shefaa_app/features/profile/presentation/bloc/profile_bloc.dart';

/// Who is signed in, and where they are looking.
///
/// Both on two lines beside the avatar rather than a bare icon: the name is the
/// one thing that tells a patient the app knows them, and the city is the only
/// sign on a screen with no doctors on it that their lists are being narrowed.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  static const double _height = 74;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: _height,
      titleSpacing: 16,
      title: Row(
        children: [
          const _Avatar(),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Greeting(),
                SizedBox(height: 3),
                _CityLine(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_height);
}

/// The patient's own photograph, or their initial. Never somebody else's face.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          previous.user?.name != current.user?.name ||
          previous.user?.image != current.user?.image,
      builder: (context, state) {
        final url = state.user?.image;
        final hasPhoto = url != null && url.isNotEmpty;
        final name = state.user?.name;

        return Container(
          width: 44,
          height: 44,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
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
      },
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
          ? const Icon(Icons.person, color: Colors.white, size: 24)
          : Text(
              trimmed.substring(0, 1),
              style: TextStyles.bold18.copyWith(color: Colors.white),
            ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.user?.name != current.user?.name,
      builder: (context, state) {
        final first = _firstNameOf(state.user?.name);

        return Text(
          first == null ? 'أهلًا بك' : 'مرحبًا، $first',
          style: TextStyles.bold16.copyWith(color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  /// The first word only. A full name runs past the edge of the bar, and
  /// nobody is greeted by all three of their names.
  static String? _firstNameOf(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _CityLine extends StatelessWidget {
  const _CityLine();

  @override
  Widget build(BuildContext context) {
    final service = getIt<SelectedCityService>();

    return ValueListenableBuilder<SelectedCity?>(
      valueListenable: service.selection,
      builder: (context, selection, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.pushNamed(context, LocationScreen.routeName),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  selection?.cityName ?? 'كل المدن',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.meduim12.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        );
      },
    );
  }
}
