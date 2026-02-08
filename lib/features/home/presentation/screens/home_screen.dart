import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_search_bar.dart';
import 'package:shefaa_app/features/home/presentation/widgets/home_app_bar.dart';
import 'package:shefaa_app/features/home/presentation/widgets/specialties_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          spacing: 30,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBar(),
            Text("Specialties", style: TextStyles.bold18),
            SpecialtiesGrid(),
          ],
        ),
      ),
    );
  }
}
