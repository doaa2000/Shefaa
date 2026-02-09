
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';

class DoctorWidget extends StatelessWidget {
  const DoctorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: const Color(0xffE8F3FF),
          backgroundImage: NetworkImage(
            "https://i.pravatar.cc/150?img=4",
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dr. Mohamed Hassan", style: TextStyles.bold18),
            Text("Pediatrician", style: TextStyles.regular14),
          ],
        ),
      ],
    );
  }
}
