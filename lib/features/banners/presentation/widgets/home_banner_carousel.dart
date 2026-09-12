import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/banners/domain/entities/banner.dart';
import 'package:shefaa_app/features/banners/presentation/bloc/banners_bloc.dart';

/// The rotating banner at the top of the home screen.
///
/// Built on PageView rather than a carousel package: this needs three pictures
/// that advance on a timer, and everything it does is core Flutter, with no
/// third-party API to keep up with.
class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BannersBloc>()..add(const GetBannersEvent()),
      child: BlocBuilder<BannersBloc, BannersState>(
        builder: (context, state) {
          // Decoration, so it takes up no room until it has something to show
          // and leaves none behind if it never does.
          if (state.bannersState != RequestState.loaded ||
              state.banners.isEmpty) {
            return const SizedBox.shrink();
          }
          return _Carousel(banners: state.banners);
        },
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({required this.banners});

  final List<BannerEntity> banners;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  static const _height = 170.0;
  static const _interval = Duration(seconds: 4);

  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    // One banner does not rotate; it just sits there.
    if (widget.banners.length < 2) return;

    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: NotificationListener<ScrollNotification>(
            // A swipe restarts the clock, so a banner the patient just moved to
            // does not slide away a moment later.
            onNotification: (notification) {
              if (notification is ScrollEndNotification) _start();
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) =>
                  _Slide(banner: widget.banners[index]),
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: i == _index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.banner});

  final BannerEntity banner;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: banner.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
            ),
            // A banner that will not load is not an error the patient can act
            // on, so it shows the same quiet block rather than a broken icon.
            errorWidget: (context, _, _) => Container(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
          ),

          // Only where there is text to read: a scrim over a picture with
          // nothing written on it just makes the picture darker.
          if (banner.hasText)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          if (banner.hasText)
            Positioned(
              right: 16,
              left: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((banner.title ?? '').trim().isNotEmpty)
                    Text(
                      banner.title!.trim(),
                      style: TextStyles.bold18.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if ((banner.subtitle ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      banner.subtitle!.trim(),
                      style: TextStyles.meduim14.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
