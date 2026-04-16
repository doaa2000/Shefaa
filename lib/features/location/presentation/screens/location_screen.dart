import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/features/location/presentation/bloc/location_bloc.dart';
import 'package:shefaa_app/features/location/presentation/widgets/drop_down_field.dart';
import 'package:shefaa_app/generated/l10n.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});
  static const String routeName = "/location";

  final List<String> governorates = const [
    "القاهرة",
    "الجيزة",
    "الإسكندرية",
    "أسوان",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocationBloc>(),
      child:  Scaffold(
            appBar: AppBar(title: Text(S.of(context).select_location)),
            body:  BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownField(
                        title: "المحافظة",
                        hint: "اختر المحافظة",
                        items: governorates,
                        value: state.selectedGovernorate,
                        isOpen: state.isGovernorateOpen,

                        onToggle: () {
                          context.read<LocationBloc>().add(
                            ToggleGovernorateDropdownEvent(),
                          );
                        },

                        onSelect: (value) {
                          context.read<LocationBloc>().add(
                            SelectGovernorateEvent(value),
                          );
                        },
                      ),
              SizedBox(height: 20),
                         DropdownField(
                        title: "المدينة",
                        hint: "اختر المدينة",
                        items: governorates,
                        value: state.selectedCity,
                        isOpen: state.isCityOpen,

                        onToggle: () {
                          context.read<LocationBloc>().add(
                            ToggleCityDropdown(),
                          );
                        },

                        onSelect: (value) {
                          context.read<LocationBloc>().add(
                            SelectCityEvent(value),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          )
    );
  }
}
