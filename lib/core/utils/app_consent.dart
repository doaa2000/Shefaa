/// The wording a patient agrees to before the app stores anything about their
/// health, and the version of it.
///
/// The version lives here rather than in the database so that changing the
/// wording and changing what counts as agreed are one edit. Raise it whenever
/// the text below changes in substance, and every patient is asked again on
/// their next launch -- which is the point of recording a version at all.
///
/// The text is a plain description of what this app actually does with health
/// information. It is not a legal document and does not pretend to be one; a
/// lawyer should read it before the app is published.
class AppConsent {
  const AppConsent._();

  static const String healthDataVersion = '1.0';

  static const String healthDataTitle = 'معالجة البيانات الصحية';

  static const String healthDataSummary =
      'أوافق على جمع بياناتي الصحية ومعالجتها لتنفيذ الحجز.';

  static const String healthDataBody = '''
لكي يعمل التطبيق، يحفظ عنك البيانات التالية:

• بياناتك الشخصية: الاسم، رقم الهاتف، تاريخ الميلاد، والصورة إن أضفتها.
• حجوزاتك: الطبيب، والتخصص، والتاريخ، والموعد، وحالة الزيارة.
• مدفوعاتك: المبلغ وطريقة الدفع وحالتها.

التخصص الذي تحجز فيه وسجل زياراتك بيانات صحية، ولذلك تُطلب موافقتك عليها صراحةً.

من يرى ماذا:

• الطبيب الذي تحجز عنده يرى اسمك وبيانات حجزك عنده وحدها، ولا يرى حجوزاتك عند أي طبيب آخر.
• إدارة العيادة ترى الحجوزات لتشغيل الخدمة.
• لا تُباع بياناتك ولا تُشارك مع جهات إعلانية.

حقوقك:

• يمكنك تعديل بياناتك الشخصية من داخل التطبيق في أي وقت.
• يمكنك حذف حسابك من داخل التطبيق. عندها تُحذف بياناتك الشخصية نهائيًا، وتبقى سجلات الزيارات لدى الأطباء دون اسمك لأنها جزء من سجلاتهم الطبية.
• يمكنك سحب موافقتك بحذف حسابك، إذ لا يمكن تشغيل الحجز دون هذه البيانات.

تُحفظ البيانات على خوادم Supabase، وتُنقل مشفّرة.
''';
}
