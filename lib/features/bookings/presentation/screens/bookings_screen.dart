import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/booking_card.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/booking_toggle.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Constants.padding),
      child: Column(
        children: [
          BookingToggle(),
          const SizedBox(height: 16),
          Expanded(child: buildBookings()),
        ],
      ),
    );
  }

  Widget buildBookings() {
    // دلوقتي Mock Data – بعدين API
    if (selectedIndex == 0) {
      return ListView(
        children: const [
          BookingCard(
            doctorName: 'د. سليمان القاضي',
            specialty: 'أخصائي طب وجراحة العيون',
            date: 'الأربعاء، 28 أغسطس 2024',
            time: '11:00 صباحاً',
            location: 'مركز النور للعيون - فرع الرياض',
            confirmed: true,
          ),
          BookingCard(
            doctorName: 'د. فاطمة الزهراء',
            specialty: 'استشارية أمراض جلدية وتجميل',
            date: 'السبت، 7 سبتمبر 2024',
            time: '03:30 مساءً',
            location: 'عيادات ديرما - فرع جدة',
            confirmed: true,
          ),
        ],
      );
    } else if (selectedIndex == 1) {
      return const Center(child: Text('لا توجد حجوزات مكتملة'));
    } else {
      return const Center(child: Text('لا توجد حجوزات ملغاة'));
    }
  }
}
