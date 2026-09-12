/// Arabic day and month names for everything that shows a booking date.
///
/// Not intl's DateFormat: the app never initialises Arabic locale data, so
/// DateFormat would fall back to English month names. These two lists are all
/// the app needs.
library;

const List<String> _dayNames = [
  'الأحد',
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
];

const List<String> _monthNames = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// The day name for a weekday index as Postgres stores it: 0 = Sunday .. 6 =
/// Saturday, which is what `doctor_schedule.weekday` holds.
String arabicWeekdayName(int weekday) => _dayNames[weekday % 7];

/// DateTime.weekday is Monday = 1 .. Sunday = 7, so `% 7` lands Sunday on 0.
String arabicDayName(DateTime date) => _dayNames[date.weekday % 7];

String arabicMonthName(DateTime date) => _monthNames[date.month - 1];

/// `الأحد 28 يوليو`
String shortArabicDate(DateTime date) =>
    '${arabicDayName(date)} ${date.day} ${arabicMonthName(date)}';

/// `الأحد 28 يوليو 2024`
String fullArabicDate(DateTime date) =>
    '${shortArabicDate(date)} ${date.year}';
