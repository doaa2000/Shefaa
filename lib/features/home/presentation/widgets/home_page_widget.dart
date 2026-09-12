import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/banners/presentation/widgets/home_banner_carousel.dart';
import 'package:shefaa_app/features/home/presentation/widgets/specialties_grid.dart';
import 'package:shefaa_app/features/home/presentation/widgets/upcoming_appointment_section.dart';
import 'package:shefaa_app/generated/l10n.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search lives on the doctors list, where a patient already has a
            // set of doctors in front of her to narrow down. The home screen
            // opens with the banners instead.
            const HomeBannerCarousel(),
            const SizedBox(height: 20),
            Text(S.of(context).specialties, style: TextStyles.bold18),
            SpecialtiesGrid(),
            const UpcomingAppointmentSection(),
          ],
        ),
      ),
    );
  }
}
