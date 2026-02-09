import 'package:flutter/material.dart';
import 'date_card_widget.dart';

class DateCardListView extends StatelessWidget {
  final List<Map<String, String>> daysData; // [{'dayName':'Monday', 'dayNumber':'21', 'month':'Sep'}]
  final int selectedIndex;
  final Function(int)? onDaySelected;

  const DateCardListView({
    super.key,
    required this.daysData,
    this.selectedIndex = 0,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysData.length,
        itemBuilder: (context, index) {
          final day = daysData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DateCardWidget(
              dayName: day['dayName'] ?? '',
              dayNumber: day['dayNumber'] ?? '',
              month: day['month'] ?? '',
              isSelected: index == selectedIndex,
              onTap: () {
                if (onDaySelected != null) onDaySelected!(index);
              },
            ),
          );
        },
      ),
    );
  }
}
