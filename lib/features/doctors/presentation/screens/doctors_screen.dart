import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_search_bar.dart';
import 'package:shefaa_app/features/doctors/presentation/widgets/home_doctors_list.dart';
import 'package:shefaa_app/generated/l10n.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  static const String routeName = "/doctors";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).doctors),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          spacing: 16,
          children: [CustomSearchBar(), Expanded(child: HomeDoctorsList())],
        ),
      ),
    );
  }
}
