import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_search_bar.dart';
import 'package:shefaa_app/features/doctors/data/models/doctors_args_model.dart';
import 'package:shefaa_app/features/doctors/presentation/bloc/doctors_bloc.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/widgets/home_doctors_list.dart';
import 'package:shefaa_app/features/location/presentation/widgets/city_filter_bar.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key, required this.args});

  final DoctorsArgsModel args;

  static const String routeName = AppRoutes.doctors;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DoctorsBloc>()
        ..add(GetDoctorsEvent(specialtyId: args.specialtyId)),
      child: Scaffold(
        appBar: CustomAppBar(title: 'أطباء ${args.specialtyName}'),
        body: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: Column(
            spacing: 16,
            children: [
              // A doorway, not a field: the bar here took keystrokes and did
              // nothing with them. Tapping it opens the search screen, which
              // owns the keyboard, the debounce and the results.
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  DoctorSearchScreen.routeName,
                ),
                child: const AbsorbPointer(
                  child: CustomSearchBar(
                    hintText: 'ابحث باسم الطبيب أو التخصص',
                  ),
                ),
              ),
              // The filter sits with the list it filters. On the home screen it
              // would be narrowing specialties, which it does not do, and the
              // patient would have no way to see whether it had worked.
              Builder(
                builder: (context) => CityFilterBar(
                  onChanged: () => context
                      .read<DoctorsBloc>()
                      .add(GetDoctorsEvent(specialtyId: args.specialtyId)),
                ),
              ),
              Expanded(
                child: HomeDoctorsList(specialtyName: args.specialtyName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
