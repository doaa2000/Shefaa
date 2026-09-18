// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "review_thanks": MessageLookupByLibrary.simpleMessage(
      "شكراً لتقييمك",
    ),
    "booking_error_not_allowed": MessageLookupByLibrary.simpleMessage(
      "لا تملك صلاحية تنفيذ هذا الإجراء",
    ),
    "booking_error_title": MessageLookupByLibrary.simpleMessage(
      "تعذّر إتمام الطلب",
    ),
    "booking_error_close": MessageLookupByLibrary.simpleMessage(
      "حسناً",
    ),
    "booking_error_generic": MessageLookupByLibrary.simpleMessage(
      "تعذر إتمام الحجز. يرجى المحاولة مرة أخرى",
    ),
    "booking_error_invalid_stars": MessageLookupByLibrary.simpleMessage(
      "التقييم من نجمة إلى خمس نجوم",
    ),
    "booking_error_comment_too_long": MessageLookupByLibrary.simpleMessage(
      "الملاحظة طويلة. يرجى اختصارها",
    ),
    "booking_error_cancelled_not_rateable": MessageLookupByLibrary.simpleMessage(
      "لا يمكن تقييم موعد ملغى",
    ),
    "booking_error_absent_not_rateable": MessageLookupByLibrary.simpleMessage(
      "لا يمكن تقييم موعد لم يحضره المريض",
    ),
    "booking_error_appointment_not_yet": MessageLookupByLibrary.simpleMessage(
      "يمكن التقييم بعد بدء الموعد",
    ),
    "booking_error_session_full": MessageLookupByLibrary.simpleMessage(
      "اكتمل عدد هذه الفترة. يرجى اختيار فترة أخرى",
    ),
    "booking_error_session_not_offered": MessageLookupByLibrary.simpleMessage(
      "الطبيب لا يعمل في هذه الفترة في هذا اليوم",
    ),
    "booking_error_already_booked": MessageLookupByLibrary.simpleMessage(
      "لديك حجز بالفعل في هذه الفترة",
    ),
    "booking_error_not_signed_in": MessageLookupByLibrary.simpleMessage(
      "يرجى تسجيل الدخول أولاً",
    ),
    "booking_error_booking_immutable": MessageLookupByLibrary.simpleMessage(
      "لا يمكن نقل الحجز. يرجى إلغاؤه والحجز من جديد",
    ),
    "booking_error_cancel_only": MessageLookupByLibrary.simpleMessage(
      "إلغاء الحجز هو التغيير الوحيد المتاح",
    ),
    "booking_error_cancellation_closed": MessageLookupByLibrary.simpleMessage(
      "انتهى وقت إلغاء هذا الحجز",
    ),
    "booking_error_time_has_passed": MessageLookupByLibrary.simpleMessage(
      "انتهى وقت هذا الموعد. يرجى اختيار موعد آخر",
    ),
    "booking_error_date_in_past": MessageLookupByLibrary.simpleMessage(
      "لا يمكن الحجز في تاريخ مضى",
    ),
    "booking_error_beyond_horizon": MessageLookupByLibrary.simpleMessage(
      "هذا التاريخ أبعد من المدة المتاحة للحجز",
    ),
    "booking_error_booking_not_found": MessageLookupByLibrary.simpleMessage(
      "لم يعد هذا الحجز موجوداً",
    ),
    "booking_error_already_cancelled": MessageLookupByLibrary.simpleMessage(
      "هذا الحجز ملغى بالفعل",
    ),
    "booking_error_cancel_instead": MessageLookupByLibrary.simpleMessage(
      "ما زال بإمكانك إلغاء الحجز",
    ),
    "booking_error_appointment_passed": MessageLookupByLibrary.simpleMessage(
      "انتهى موعد هذا الحجز",
    ),
    "account_info": MessageLookupByLibrary.simpleMessage("معلومات الحساب"),
    "appointments": MessageLookupByLibrary.simpleMessage("المواعيد"),
    "available_days": MessageLookupByLibrary.simpleMessage("الأيام المتاحة"),
    "available_time": MessageLookupByLibrary.simpleMessage("الوقت المتاح"),
    "birth_date": MessageLookupByLibrary.simpleMessage("تاريخ الميلاد"),
    "book_now": MessageLookupByLibrary.simpleMessage("احجز الآن"),
    "booking_details": MessageLookupByLibrary.simpleMessage("تفاصيل الحجز"),
    "cancel_booking": MessageLookupByLibrary.simpleMessage("إلغاء الحجز"),
    "change_password": MessageLookupByLibrary.simpleMessage(
      "تغيير كلمة المرور",
    ),
    "city": MessageLookupByLibrary.simpleMessage("المدينة"),
    "confirm_booking": MessageLookupByLibrary.simpleMessage("تأكيد الحجز"),
    "confirm_booking_payment": MessageLookupByLibrary.simpleMessage(
      "تأكيد الحجز والدفع",
    ),
    "confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور الجديدة",
    ),
    "confirm_password": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور",
    ),
    "consultation_fee": MessageLookupByLibrary.simpleMessage("رسوم الكشف"),
    "create_account": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
    "currency": MessageLookupByLibrary.simpleMessage("جنيه"),
    "discount": MessageLookupByLibrary.simpleMessage("الخصم"),
    "doctors": MessageLookupByLibrary.simpleMessage("الأطباء"),
    "email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "email_address": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "email_hint": MessageLookupByLibrary.simpleMessage("example@mail.com"),
    "email_invalid_error": MessageLookupByLibrary.simpleMessage(
      "أدخل بريد إلكتروني صحيح",
    ),
    "email_locked_note": MessageLookupByLibrary.simpleMessage(
      "البريد الإلكتروني مرتبط بحسابك ولا يمكن تعديله من هنا",
    ),
    "email_required_error": MessageLookupByLibrary.simpleMessage(
      "البريد الإلكتروني مطلوب",
    ),
    "evening": MessageLookupByLibrary.simpleMessage("مساءً"),
    "full_name": MessageLookupByLibrary.simpleMessage("الاسم بالكامل"),
    "full_name_hint": MessageLookupByLibrary.simpleMessage("أدخل اسمك بالكامل"),
    "governorate": MessageLookupByLibrary.simpleMessage("المحافظة"),
    "home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
    "instapay": MessageLookupByLibrary.simpleMessage("انستا باي"),
    "minutes": MessageLookupByLibrary.simpleMessage("دقائق"),
    "morning": MessageLookupByLibrary.simpleMessage("صباحًا"),
    "name_min_error": MessageLookupByLibrary.simpleMessage(
      "يجب أن يكون الاسم 3 أحرف على الأقل",
    ),
    "name_required_error": MessageLookupByLibrary.simpleMessage("الاسم مطلوب"),
    "new_password": MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
    "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "password_hint": MessageLookupByLibrary.simpleMessage("••••••••"),
    "password_min_error": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور يجب ألا تقل عن 8 أحرف",
    ),
    "passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "كلمتا المرور غير متطابقتين",
    ),
    "pay_cash": MessageLookupByLibrary.simpleMessage("الدفع نقدًا"),
    "payment": MessageLookupByLibrary.simpleMessage("الدفع"),
    "payment_summary": MessageLookupByLibrary.simpleMessage("ملخص الدفع"),
    "personal_info": MessageLookupByLibrary.simpleMessage("المعلومات الشخصية"),
    "phone_hint": MessageLookupByLibrary.simpleMessage("+20 01X XXXX XXXX"),
    "phone_invalid_error": MessageLookupByLibrary.simpleMessage(
      "أدخل رقم هاتف صحيح",
    ),
    "phone_number": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
    "phone_required_error": MessageLookupByLibrary.simpleMessage(
      "رقم الهاتف مطلوب",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
    "profile_updated_success": MessageLookupByLibrary.simpleMessage(
      "تم حفظ التعديلات بنجاح",
    ),
    "save_changes": MessageLookupByLibrary.simpleMessage("حفظ التغييرات"),
    "search": MessageLookupByLibrary.simpleMessage("ابحث"),
    "select_appointment": MessageLookupByLibrary.simpleMessage("اختر الموعد"),
    "select_birth_date": MessageLookupByLibrary.simpleMessage(
      "اختر تاريخ الميلاد",
    ),
    "select_city": MessageLookupByLibrary.simpleMessage("اختر المدينة"),
    "select_governorate": MessageLookupByLibrary.simpleMessage("اختر المحافظة"),
    "select_location": MessageLookupByLibrary.simpleMessage("اختر موقعك"),
    "select_payment_method": MessageLookupByLibrary.simpleMessage(
      "اختر طريقة الدفع",
    ),
    "specialties": MessageLookupByLibrary.simpleMessage("التخصصات"),
    "total_amount": MessageLookupByLibrary.simpleMessage("المبلغ الإجمالي"),
    "update_profile": MessageLookupByLibrary.simpleMessage(
      "تحديث الملف الشخصي",
    ),
    "vodafone_cash": MessageLookupByLibrary.simpleMessage("فودافون كاش"),
    "waiting_time": MessageLookupByLibrary.simpleMessage("وقت الانتظار"),
    "your_appointment": MessageLookupByLibrary.simpleMessage("موعدك"),
    "your_next_appointment": MessageLookupByLibrary.simpleMessage(
      "موعدك القادم",
    ),
  };
}
