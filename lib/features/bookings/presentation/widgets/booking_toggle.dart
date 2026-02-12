import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookingToggle extends StatefulWidget {
  const BookingToggle({super.key});

  @override
  State<BookingToggle> createState() => _BookingToggleState();
}

class _BookingToggleState extends State<BookingToggle> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: selectedIndex,
          thumbColor: Colors.white,

          backgroundColor: Colors.transparent,
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(
                'القادمة',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(
                'المكتملة',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            2: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(
                'الملغاة',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          },
          onValueChanged: (value) {
            setState(() {
              selectedIndex = value!;
            });
          },
        ),
      ),
    );
  }
}
