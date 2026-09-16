// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مقاهي أربيل';

  @override
  String get appTagline => 'اكتشف مقاهي أربيل';

  @override
  String get onboardingTitle1 => 'اعثر على مقهاك';

  @override
  String get onboardingBody1 =>
      'كل مقاهي أربيل في مكان واحد، مع الصور والقوائم والأسعار الحقيقية.';

  @override
  String get onboardingTitle2 => 'شاهد القائمة أولاً';

  @override
  String get onboardingBody2 =>
      'تصفّح المشروبات والمأكولات بأسعار محدّثة قبل الذهاب.';

  @override
  String get onboardingTitle3 => 'احجز طاولة';

  @override
  String get onboardingBody3 => 'احجز خلال ثوانٍ واحصل على رد من المقهى.';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get skip => 'تخطٍّ';

  @override
  String get next => 'التالي';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get verifyPhone => 'تأكيد رقمك';

  @override
  String otpSentTo(String target) {
    return 'أرسلنا رمزاً إلى $target';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get verify => 'تأكيد';

  @override
  String get emailRequired => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get emailInvalid => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get passwordRequired => 'الرجاء إدخال كلمة المرور';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون ٨ أحرف على الأقل';

  @override
  String get passwordNeedsLetterAndNumber => 'كلمة المرور تحتاج حرفاً ورقماً';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get nameRequired => 'الرجاء إدخال اسمك';

  @override
  String get phoneRequired => 'الرجاء إدخال رقم هاتفك';

  @override
  String get phoneInvalid => 'أدخل رقماً صحيحاً، مثل +9647501234567';

  @override
  String get home => 'الرئيسية';

  @override
  String get explore => 'استكشاف';

  @override
  String get map => 'الخريطة';

  @override
  String get favorites => 'المحفوظة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get popular => 'الأكثر شهرة';

  @override
  String get featured => 'مميّز';

  @override
  String get nearby => 'قريب منك';

  @override
  String get allCafes => 'كل المقاهي';

  @override
  String get searchHint => 'ابحث عن مقهى…';

  @override
  String get noResults => 'لا توجد مقاهٍ مطابقة';

  @override
  String get noResultsBody => 'جرّب بحثاً آخر أو امسح عوامل التصفية.';

  @override
  String get filters => 'التصفية';

  @override
  String get clearFilters => 'مسح الكل';

  @override
  String get apply => 'تطبيق';

  @override
  String get area => 'المنطقة';

  @override
  String get allAreas => 'كل المناطق';

  @override
  String get priceRange => 'السعر';

  @override
  String get amenities => 'الخدمات';

  @override
  String get minimumRating => 'أقل تقييم';

  @override
  String get openNow => 'مفتوح الآن';

  @override
  String get closed => 'مغلق';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortRating => 'الأعلى تقييماً';

  @override
  String get sortDistance => 'الأقرب';

  @override
  String get sortReviews => 'الأكثر تقييماً';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get menu => 'القائمة';

  @override
  String get reviews => 'التقييمات';

  @override
  String get about => 'نبذة';

  @override
  String get gallery => 'الصور';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get call => 'اتصال';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get share => 'مشاركة';

  @override
  String get bookTable => 'احجز طاولة';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييماً',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
      zero: 'لا تقييمات',
    );
    return '$_temp0';
  }

  @override
  String distanceAway(String km) {
    return 'يبعد $km كم';
  }

  @override
  String get noMenuYet => 'لم يضف هذا المقهى قائمة بعد';

  @override
  String get unavailable => 'غير متوفر';

  @override
  String get writeReview => 'اكتب تقييماً';

  @override
  String get editReview => 'تعديل تقييمك';

  @override
  String get yourRating => 'تقييمك';

  @override
  String get reviewHint => 'كيف كانت تجربتك؟';

  @override
  String get submitReview => 'إرسال';

  @override
  String get reviewPending => 'شكراً! سيظهر تقييمك بعد الموافقة عليه.';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get beFirstToReview => 'كن أول من يقيّم هذا المقهى.';

  @override
  String get replyFromCafe => 'رد من المقهى';

  @override
  String get savedCafes => 'المقاهي المحفوظة';

  @override
  String get noFavorites => 'لم تحفظ شيئاً بعد';

  @override
  String get noFavoritesBody => 'اضغط على القلب لحفظ مقهى هنا.';

  @override
  String get reservations => 'الحجوزات';

  @override
  String get myBookings => 'حجوزاتي';

  @override
  String get selectDate => 'التاريخ';

  @override
  String get selectTime => 'الوقت';

  @override
  String get partySize => 'عدد الأشخاص';

  @override
  String get contactName => 'الاسم';

  @override
  String get contactPhone => 'الهاتف';

  @override
  String get specialRequest => 'طلب خاص (اختياري)';

  @override
  String get specialRequestHint => 'ركن هادئ، كرسي أطفال…';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get bookingReference => 'رقم الحجز';

  @override
  String get bookingPending => 'بانتظار التأكيد';

  @override
  String get bookingConfirmed => 'مؤكّد';

  @override
  String get bookingDeclined => 'مرفوض';

  @override
  String get bookingCancelled => 'ملغى';

  @override
  String get bookingCompleted => 'مكتمل';

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get cancelBookingConfirm => 'هل تريد إلغاء هذا الحجز؟';

  @override
  String get noBookings => 'لا حجوزات بعد';

  @override
  String get noBookingsBody => 'احجز طاولة وستظهر هنا.';

  @override
  String get fullyBooked => 'محجوز بالكامل';

  @override
  String seatsLeft(int count) {
    return '$count مقعد متبقٍ';
  }

  @override
  String get closedOnDay => 'المقهى مغلق في ذلك اليوم';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا إشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'النظام';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get aboutApp => 'نبذة';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'لا يمكن التراجع عن هذا. هل تريد حذف حسابك؟';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get done => 'تم';

  @override
  String get close => 'إغلاق';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorNetworkBody => 'تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get errorServer => 'الخادم لا يستجيب';

  @override
  String get errorTimeout => 'استغرق ذلك وقتاً طويلاً — حاول مرة أخرى';

  @override
  String get errorUnauthorized => 'الرجاء تسجيل الدخول للمتابعة';

  @override
  String get offlineBanner => 'أنت غير متصل — يتم عرض بيانات محفوظة';

  @override
  String get signInRequired => 'تسجيل الدخول مطلوب';

  @override
  String get signInToFavorite => 'سجّل الدخول لحفظ المقاهي.';

  @override
  String get signInToReview => 'سجّل الدخول لكتابة تقييم.';

  @override
  String get signInToBook => 'سجّل الدخول لحجز طاولة.';

  @override
  String get currencyIqd => 'د.ع';

  @override
  String get priceBudget => 'اقتصادي';

  @override
  String get priceModerate => 'متوسط';

  @override
  String get priceUpscale => 'راقٍ';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get noPhotoYet => 'لا توجد صورة بعد';

  @override
  String get photoUnavailable => 'الصورة غير متاحة';

  @override
  String get featuredSubtitle => 'أماكن مختارة تستحق الزيارة';

  @override
  String get openRightNow => 'مفتوح الآن';

  @override
  String get openRightNowSubtitle => 'يقدّم الخدمة في هذه الساعة';

  @override
  String get popularSubtitle => 'ما تطلبه أربيل';

  @override
  String get browseByArea => 'تصفّح حسب المنطقة';

  @override
  String get browseByAreaSubtitle => 'اختر جزءًا من المدينة';

  @override
  String get newCafe => 'جديد';

  @override
  String cafeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقهى',
      one: 'مقهى واحد',
      zero: 'لا مقاهي',
    );
    return '$_temp0';
  }

  @override
  String get rateThisCafe => 'قيّم هذا المقهى';

  @override
  String get tapToRate => 'اضغط على نجمة للتقييم';

  @override
  String get yourReview => 'تقييمك';

  @override
  String get reviewPublished => 'شكرًا! تقييمك ظاهر الآن.';

  @override
  String basedOnReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بناءً على $count تقييم',
      one: 'بناءً على تقييم واحد',
      zero: 'لا تقييمات بعد',
    );
    return '$_temp0';
  }

  @override
  String get reviewVisibleToEveryone => 'سيظهر تقييمك فورًا وسيراه الجميع.';

  @override
  String get dataAttribution =>
      'بيانات المقاهي © مساهمو OpenStreetMap (ODbL) ومؤسسة Overture Maps (CDLA Permissive 2.0، Apache 2.0).';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get contactAndLinks => 'التواصل والروابط';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get instagram => 'إنستغرام';

  @override
  String get address => 'العنوان';

  @override
  String seats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقعد',
      one: 'مقعد واحد',
    );
    return '$_temp0';
  }

  @override
  String get viewAllPhotos => 'عرض كل الصور';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صور',
      one: 'صورة واحدة',
      zero: 'لا توجد صور',
    );
    return '$_temp0';
  }

  @override
  String get mapStyle => 'نمط الخريطة';

  @override
  String get deleteAccountExplain =>
      'سيتم محو اسمك وبريدك الإلكتروني ورقم هاتفك. تُلغى حجوزاتك وتُزال المقاهي المحفوظة. أما تقييماتك فتبقى على صفحة المقهى باسم «مستخدم محذوف».';

  @override
  String get deleteAccountDone => 'تم حذف حسابك.';

  @override
  String get deleteAccountAction => 'احذف حسابي';

  @override
  String get account => 'الحساب';

  @override
  String get optional => 'اختياري';

  @override
  String get profileSaved => 'تم حفظ ملفك الشخصي.';

  @override
  String get emailCannotChange =>
      'بريدك الإلكتروني هو وسيلة تسجيل دخولك، لذلك لا يمكن تغييره هنا. تواصل مع الدعم إذا احتجت إلى تغييره.';

  @override
  String get phoneChangeNote =>
      'تغيير رقمك يعني أنه سيحتاج إلى التحقق منه مرة أخرى.';

  @override
  String get passwordChanged =>
      'تم تغيير كلمة المرور. تم تسجيل الخروج من الأجهزة الأخرى.';

  @override
  String get passwordChangeExplain =>
      'بعد تغييرها، ستحتاج كل الهواتف الأخرى المسجلة في حسابك إلى كلمة المرور الجديدة.';

  @override
  String get newPasswordSameAsOld => 'اختر كلمة مرور مختلفة عن كلمتك الحالية.';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get helpCenter => 'المساعدة والأسئلة الشائعة';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get reportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get reportProblemSubject => 'بلاغ عن مشكلة';

  @override
  String noEmailApp(String address) {
    return 'لا يوجد تطبيق بريد مُعدّ. راسلنا على $address — تم نسخ العنوان.';
  }

  @override
  String get legal => 'قانوني';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get openSourceLicenses => 'تراخيص البرمجيات مفتوحة المصدر';

  @override
  String get couldNotOpenPage => 'تعذّر فتح تلك الصفحة.';

  @override
  String get storage => 'التخزين';

  @override
  String get clearCache => 'مسح الصور والبيانات المخزنة مؤقتًا';

  @override
  String get clearCacheSubtitle =>
      'يحرّر مساحة على هاتفك. ستُحمَّل الصور من جديد أثناء التصفح.';

  @override
  String get cacheCleared => 'تم مسح الصور والبيانات المخزنة مؤقتًا.';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get faqTitle => 'الأسئلة الشائعة';

  @override
  String get faqFindQ => 'كيف أجد مقهى؟';

  @override
  String get faqFindA =>
      'استخدم «استكشاف» للبحث بالاسم بالكردية أو العربية أو الإنجليزية، وضيّق القائمة بالأزرار — مفتوح الآن، السعر، ما يقدمه المقهى، أو منطقته. يعرض تبويب الخريطة كل المقاهي؛ اضغط على رقم لتكبير ذلك الجزء من المدينة.';

  @override
  String get faqOpenNowQ => 'لماذا يظهر مقهى مغلقًا وهو مفتوح؟';

  @override
  String get faqOpenNowA =>
      'تُحسب حالة «مفتوح الآن» من ساعات عمل المقهى. كثير من المقاهي لم تُدرج ساعاتها بعد، والمقهى الذي لا ساعات له لا يمكن إظهاره مفتوحًا. إذا كنت تعرف ساعات مقهى، أبلغنا بها وسنضيفها.';

  @override
  String get faqSaveQ => 'كيف أحفظ مقهى؟';

  @override
  String get faqSaveA =>
      'اضغط على القلب في بطاقته أو أعلى صفحته. المقاهي المحفوظة في تبويب «المحفوظة». الحفظ يحتاج إلى حساب، لذلك تنتقل قائمتك معك إلى هاتف جديد.';

  @override
  String get faqBookQ => 'كيف يعمل حجز طاولة؟';

  @override
  String get faqBookA =>
      'اختر التاريخ والوقت وعدد الأشخاص في صفحة المقهى وأرسل الطلب. يؤكد المقهى الطلب أو يرفضه، وستصلك إشعارات في الحالتين. طلباتك وحالتها في «حجوزاتي».';

  @override
  String get faqCancelQ => 'كيف ألغي حجزًا؟';

  @override
  String get faqCancelA =>
      'افتح «حجوزاتي» من ملفك الشخصي واضغط «إلغاء الحجز» على طلب ما زال قيد الانتظار أو مؤكدًا. يظهر ملغى لدى المقهى فورًا.';

  @override
  String get faqRateQ => 'كيف تعمل التقييمات والمراجعات؟';

  @override
  String get faqRateA =>
      'اضغط على النجوم في صفحة المقهى لتقييمه، وأضف مراجعة مكتوبة إن شئت. لك مراجعة واحدة لكل مقهى؛ التقييم مرة أخرى يستبدلها. تظهر المراجعات فورًا، وتُحذف المخالفة للقواعد.';

  @override
  String get faqWrongInfoQ => 'بيانات مقهى خاطئة أو ناقصة. ماذا أفعل؟';

  @override
  String get faqWrongInfoA =>
      'استخدم «الإبلاغ عن مشكلة» وأخبرنا باسم المقهى وما يجب تغييره — الساعات أو رقم الهاتف أو الموقع أو الصور. يمكن لأصحاب المقاهي أيضًا إدارة صفحاتهم.';

  @override
  String get faqLanguageQ => 'كيف أغيّر اللغة؟';

  @override
  String get faqLanguageA =>
      'اخترها من «التفضيلات» في ملفك الشخصي. تتغير أسماء المقاهي وأوصافها أيضًا حيثما توفرت ترجمة.';

  @override
  String get faqDeleteQ => 'كيف أحذف حسابي؟';

  @override
  String get faqDeleteA =>
      'مرّر إلى أسفل ملفك الشخصي واضغط «احذف حسابي». تُمحى بياناتك الشخصية وتُلغى حجوزاتك؛ وتبقى مراجعاتك على المقهى باسم «مستخدم محذوف».';

  @override
  String get stillNeedHelp => 'ما زلت بحاجة إلى مساعدة؟';

  @override
  String get stillNeedHelpBody => 'راسلنا وسيرد عليك شخص، عادةً خلال يوم.';
}
