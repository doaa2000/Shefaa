import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/features/location/presentation/bloc/location_bloc.dart';
import 'package:shefaa_app/features/location/presentation/widgets/location_picker_body.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  static const String routeName = '/location';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocationBloc>()..add(const LoadLocationEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('تحديد الموقع')),
        // BlocListener + BlocBuilder rather than BlocConsumer: this version of
        // BlocConsumer reaches its listener through buildWhen, so a Navigator
        // call from there happens during a build and does nothing.
        body: BlocListener<LocationBloc, LocationState>(
          listenWhen: (previous, current) => current.saved && !previous.saved,
          listener: (context, state) => Navigator.pop(context, true),
          child: const LocationPickerBody(
            intro: 'اختيار المدينة يعرض الأطباء العاملين في عياداتها فقط.',
          ),
        ),
      ),
    );
  }
}
