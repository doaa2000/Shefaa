import 'package:flutter/material.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/widgets/time_card_widget.dart';

class TimeCardListWidget extends StatelessWidget {
  final List<dynamic> hours;
  final int selectedIndex;
  final Function(int)? onHourSelected;

  const TimeCardListWidget({
    super.key,
    required this.hours,
    this.selectedIndex = 0,
    this.onHourSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        hours.length,
        (index) => TimeCardWidget(
          hour: hours[index].toString(),
          isSelected: index == selectedIndex,
          onTap: () {
            if (onHourSelected != null) onHourSelected!(index);
          },
        ),
      ),
    );
  }
}
