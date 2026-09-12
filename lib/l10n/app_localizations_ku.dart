// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appName => 'کافێی هەولێر';

  @override
  String get appTagline => 'کافێکانی هەولێر بدۆزەرەوە';

  @override
  String get onboardingTitle1 => 'کافێی خۆت بدۆزەرەوە';

  @override
  String get onboardingBody1 =>
      'هەموو کافێکانی هەولێر لە یەک شوێندا، لەگەڵ وێنە و مێنیو و نرخی ڕاستەقینە.';

  @override
  String get onboardingTitle2 => 'سەرەتا مێنیو ببینە';

  @override
  String get onboardingBody2 =>
      'پێش ڕۆیشتن خواردن و خواردنەوەکان لەگەڵ نرخی نوێ ببینە.';

  @override
  String get onboardingTitle3 => 'مێز حیجز بکە';

  @override
  String get onboardingBody3 =>
      'بە چەند چرکەیەک حیجز بکە و وەڵام لە کافێکەوە وەربگرە.';

  @override
  String get getStarted => 'دەست پێبکە';

  @override
  String get skip => 'تێپەڕاندن';

  @override
  String get next => 'دواتر';

  @override
  String get signIn => 'چوونەژوورەوە';

  @override
  String get signUp => 'دروستکردنی هەژمار';

  @override
  String get signOut => 'دەرچوون';

  @override
  String get email => 'ئیمەیل';

  @override
  String get password => 'وشەی نهێنی';

  @override
  String get confirmPassword => 'دووبارەکردنەوەی وشەی نهێنی';

  @override
  String get fullName => 'ناوی تەواو';

  @override
  String get phoneNumber => 'ژمارەی مۆبایل';

  @override
  String get forgotPassword => 'وشەی نهێنیت لەبیرچووە؟';

  @override
  String get noAccount => 'هەژمارت نییە؟';

  @override
  String get haveAccount => 'پێشتر هەژمارت هەیە؟';

  @override
  String get continueAsGuest => 'وەک میوان بەردەوامبە';

  @override
  String get verifyPhone => 'ژمارەکەت پشتڕاست بکەرەوە';

  @override
  String otpSentTo(String target) {
    return 'کۆدێکمان نارد بۆ $target';
  }

  @override
  String get resendCode => 'دووبارە ناردنەوەی کۆد';

  @override
  String resendIn(int seconds) {
    return 'ناردنەوە لە $seconds چرکەدا';
  }

  @override
  String get verify => 'پشتڕاستکردنەوە';

  @override
  String get emailRequired => 'تکایە ئیمەیلەکەت بنووسە';

  @override
  String get emailInvalid => 'تکایە ئیمەیلێکی دروست بنووسە';

  @override
  String get passwordRequired => 'تکایە وشەی نهێنی بنووسە';

  @override
  String get passwordTooShort => 'وشەی نهێنی دەبێت لانیکەم ٨ پیت بێت';

  @override
  String get passwordNeedsLetterAndNumber =>
      'وشەی نهێنی پێویستی بە پیت و ژمارەیە';

  @override
  String get passwordsDoNotMatch => 'وشە نهێنییەکان وەک یەک نین';

  @override
  String get nameRequired => 'تکایە ناوت بنووسە';

  @override
  String get phoneRequired => 'تکایە ژمارەی مۆبایلت بنووسە';

  @override
  String get phoneInvalid => 'ژمارەیەکی دروست بنووسە، وەک +9647501234567';

  @override
  String get home => 'سەرەکی';

  @override
  String get explore => 'گەڕان';

  @override
  String get map => 'نەخشە';

  @override
  String get favorites => 'پاشەکەوتکراو';

  @override
  String get profile => 'پرۆفایل';

  @override
  String get popular => 'بەناوبانگ';

  @override
  String get featured => 'تایبەت';

  @override
  String get nearby => 'نزیک';

  @override
  String get allCafes => 'هەموو کافێکان';

  @override
  String get searchHint => 'گەڕان بۆ کافێ…';

  @override
  String get noResults => 'هیچ کافێیەک نەدۆزرایەوە';

  @override
  String get noResultsBody => 'گەڕانێکی تر تاقی بکەرەوە یان فلتەرەکان بسڕەوە.';

  @override
  String get filters => 'فلتەرەکان';

  @override
  String get clearFilters => 'سڕینەوەی هەموو';

  @override
  String get apply => 'جێبەجێکردن';

  @override
  String get area => 'ناوچە';

  @override
  String get allAreas => 'هەموو ناوچەکان';

  @override
  String get priceRange => 'نرخ';

  @override
  String get amenities => 'خزمەتگوزارییەکان';

  @override
  String get minimumRating => 'کەمترین هەڵسەنگاندن';

  @override
  String get openNow => 'ئێستا کراوەیە';

  @override
  String get closed => 'داخراوە';

  @override
  String get sortBy => 'ڕیزکردن بەپێی';

  @override
  String get sortRating => 'باشترین هەڵسەنگاندن';

  @override
  String get sortDistance => 'نزیکترین';

  @override
  String get sortReviews => 'زۆرترین بۆچوون';

  @override
  String get sortNewest => 'نوێترین';

  @override
  String get menu => 'مێنیو';

  @override
  String get reviews => 'بۆچوونەکان';

  @override
  String get about => 'دەربارە';

  @override
  String get gallery => 'وێنەکان';

  @override
  String get openingHours => 'کاتی کارکردن';

  @override
  String get call => 'پەیوەندی';

  @override
  String get directions => 'ڕێنمایی';

  @override
  String get share => 'هاوبەشکردن';

  @override
  String get bookTable => 'حیجزکردنی مێز';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بۆچوون',
      one: '١ بۆچوون',
      zero: 'هیچ بۆچوونێک نییە',
    );
    return '$_temp0';
  }

  @override
  String distanceAway(String km) {
    return '$km کم دوورە';
  }

  @override
  String get noMenuYet => 'ئەم کافێیە هێشتا مێنیوی زیاد نەکردووە';

  @override
  String get unavailable => 'بەردەست نییە';

  @override
  String get writeReview => 'نووسینی بۆچوون';

  @override
  String get editReview => 'دەستکاری بۆچوونەکەت';

  @override
  String get yourRating => 'هەڵسەنگاندنی تۆ';

  @override
  String get reviewHint => 'ئەزموونەکەت چۆن بوو؟';

  @override
  String get submitReview => 'ناردن';

  @override
  String get reviewPending => 'سوپاس! بۆچوونەکەت دوای پەسەندکردن دەردەکەوێت.';

  @override
  String get noReviewsYet => 'هێشتا هیچ بۆچوونێک نییە';

  @override
  String get beFirstToReview => 'یەکەم کەس بە کە بۆچوون دەنووسێت.';

  @override
  String get replyFromCafe => 'وەڵام لە کافێکەوە';

  @override
  String get savedCafes => 'کافێە پاشەکەوتکراوەکان';

  @override
  String get noFavorites => 'هێشتا هیچت پاشەکەوت نەکردووە';

  @override
  String get noFavoritesBody => 'دڵەکە دابگرە بۆ پاشەکەوتکردنی کافێیەک.';

  @override
  String get reservations => 'حیجزەکان';

  @override
  String get myBookings => 'حیجزەکانی من';

  @override
  String get selectDate => 'بەروار';

  @override
  String get selectTime => 'کات';

  @override
  String get partySize => 'ژمارەی کەسان';

  @override
  String get contactName => 'ناو';

  @override
  String get contactPhone => 'ژمارە';

  @override
  String get specialRequest => 'داواکاری تایبەت (ئارەزوومەندانە)';

  @override
  String get specialRequestHint => 'گۆشەیەکی ئارام، کورسی منداڵ…';

  @override
  String get confirmBooking => 'پشتڕاستکردنی حیجز';

  @override
  String get bookingReference => 'ژمارەی حیجز';

  @override
  String get bookingPending => 'چاوەڕێی پەسەندکردن';

  @override
  String get bookingConfirmed => 'پەسەندکرا';

  @override
  String get bookingDeclined => 'ڕەتکرایەوە';

  @override
  String get bookingCancelled => 'هەڵوەشێنرایەوە';

  @override
  String get bookingCompleted => 'تەواوبوو';

  @override
  String get cancelBooking => 'هەڵوەشاندنەوەی حیجز';

  @override
  String get cancelBookingConfirm => 'ئەم حیجزە هەڵبوەشێنرێتەوە؟';

  @override
  String get noBookings => 'هێشتا هیچ حیجزێک نییە';

  @override
  String get noBookingsBody => 'مێزێک حیجز بکە و لێرە دەردەکەوێت.';

  @override
  String get fullyBooked => 'تەواو حیجزکراوە';

  @override
  String seatsLeft(int count) {
    return '$count کورسی ماوە';
  }

  @override
  String get closedOnDay => 'کافێکە لەو ڕۆژەدا داخراوە';

  @override
  String get notifications => 'ئاگادارکردنەوەکان';

  @override
  String get noNotifications => 'هیچ ئاگادارکردنەوەیەک نییە';

  @override
  String get markAllRead => 'هەمووی وەک خوێندراوە';

  @override
  String get settings => 'ڕێکخستنەکان';

  @override
  String get language => 'زمان';

  @override
  String get theme => 'ڕووکار';

  @override
  String get themeDark => 'تاریک';

  @override
  String get themeLight => 'ڕووناک';

  @override
  String get themeSystem => 'سیستەم';

  @override
  String get editProfile => 'دەستکاری پرۆفایل';

  @override
  String get changePassword => 'گۆڕینی وشەی نهێنی';

  @override
  String get currentPassword => 'وشەی نهێنی ئێستا';

  @override
  String get newPassword => 'وشەی نهێنی نوێ';

  @override
  String get aboutApp => 'دەربارە';

  @override
  String get deleteAccount => 'سڕینەوەی هەژمار';

  @override
  String get deleteAccountConfirm => 'ئەمە ناگەڕێتەوە. هەژمارەکەت بسڕدرێتەوە؟';

  @override
  String get retry => 'دووبارە هەوڵدانەوە';

  @override
  String get cancel => 'هەڵوەشاندنەوە';

  @override
  String get save => 'پاشەکەوتکردن';

  @override
  String get delete => 'سڕینەوە';

  @override
  String get done => 'تەواو';

  @override
  String get close => 'داخستن';

  @override
  String get seeAll => 'بینینی هەموو';

  @override
  String get loading => 'بارکردن…';

  @override
  String get errorGeneric => 'هەڵەیەک ڕوویدا';

  @override
  String get errorNetwork => 'پەیوەندی ئینتەرنێت نییە';

  @override
  String get errorNetworkBody => 'پەیوەندییەکەت بپشکنە و دووبارە هەوڵبدەرەوە.';

  @override
  String get errorServer => 'ڕاژەکار وەڵام نادات';

  @override
  String get errorTimeout => 'کاتی زۆری خایاند — تکایە دووبارە هەوڵبدەرەوە';

  @override
  String get errorUnauthorized => 'تکایە بچۆ ژوورەوە بۆ بەردەوامبوون';

  @override
  String get offlineBanner => 'ئۆفڵاینیت — داتای پاشەکەوتکراو پیشان دەدرێت';

  @override
  String get signInRequired => 'پێویستە بچیتە ژوورەوە';

  @override
  String get signInToFavorite => 'بچۆ ژوورەوە بۆ پاشەکەوتکردنی کافێ.';

  @override
  String get signInToReview => 'بچۆ ژوورەوە بۆ نووسینی بۆچوون.';

  @override
  String get signInToBook => 'بچۆ ژوورەوە بۆ حیجزکردنی مێز.';

  @override
  String get currencyIqd => 'د.ع';

  @override
  String get priceBudget => 'هەرزان';

  @override
  String get priceModerate => 'مامناوەند';

  @override
  String get priceUpscale => 'گران';

  @override
  String get sunday => 'یەکشەممە';

  @override
  String get monday => 'دووشەممە';

  @override
  String get tuesday => 'سێشەممە';

  @override
  String get wednesday => 'چوارشەممە';

  @override
  String get thursday => 'پێنجشەممە';

  @override
  String get friday => 'هەینی';

  @override
  String get saturday => 'شەممە';

  @override
  String get noPhotoYet => 'هێشتا وێنە نییە';

  @override
  String get photoUnavailable => 'وێنە بەردەست نییە';

  @override
  String get featuredSubtitle => 'شوێنە هەڵبژێردراوەکان کە شایەنی سەردانن';

  @override
  String get openRightNow => 'ئێستا کراوەیە';

  @override
  String get openRightNowSubtitle => 'لەم کاتەدا خزمەت دەکەن';

  @override
  String get popularSubtitle => 'ئەوەی هەولێر داوای دەکات';

  @override
  String get browseByArea => 'بەپێی ناوچە';

  @override
  String get browseByAreaSubtitle => 'بەشێکی شار هەڵبژێرە';

  @override
  String get newCafe => 'نوێ';

  @override
  String cafeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کافێ',
      one: '١ کافێ',
      zero: 'هیچ کافێیەک',
    );
    return '$_temp0';
  }

  @override
  String get rateThisCafe => 'نمرە بەم کافێیە بدە';

  @override
  String get tapToRate => 'ئەستێرەیەک دابگرە بۆ نمرەدان';

  @override
  String get yourReview => 'پێداچوونەوەکەت';

  @override
  String get reviewPublished => 'سوپاس! نمرەکەت بڵاوکرایەوە.';

  @override
  String basedOnReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لەسەر بنەمای $count نمرە',
      one: 'لەسەر بنەمای ١ نمرە',
      zero: 'هێشتا نمرەی نییە',
    );
    return '$_temp0';
  }

  @override
  String get reviewVisibleToEveryone =>
      'نمرەکەت دەستبەجێ بڵاو دەبێتەوە و هەموو کەس دەیبینێت.';

  @override
  String get dataAttribution =>
      'شوێنی کافێکان © بەشداربووانی OpenStreetMap، ODbL.';

  @override
  String get preferences => 'هەڵبژاردەکان';

  @override
  String get contactAndLinks => 'پەیوەندی و بەستەرەکان';

  @override
  String get website => 'ماڵپەڕ';

  @override
  String get whatsapp => 'واتساپ';

  @override
  String get instagram => 'ئینستاگرام';

  @override
  String get address => 'ناونیشان';

  @override
  String seats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کورسی',
      one: '١ کورسی',
    );
    return '$_temp0';
  }

  @override
  String get viewAllPhotos => 'بینینی هەموو وێنەکان';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وێنە',
      one: '١ وێنە',
      zero: 'هیچ وێنەیەک',
    );
    return '$_temp0';
  }

  @override
  String get mapStyle => 'شێوازی نەخشە';
}
