// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ErbilCafe';

  @override
  String get appTagline => 'Discover the cafés of Erbil';

  @override
  String get onboardingTitle1 => 'Find your café';

  @override
  String get onboardingBody1 =>
      'Every café in Erbil in one place, with photos, menus and real prices.';

  @override
  String get onboardingTitle2 => 'See the menu first';

  @override
  String get onboardingBody2 =>
      'Browse drinks and food with up-to-date prices before you go.';

  @override
  String get onboardingTitle3 => 'Book a table';

  @override
  String get onboardingBody3 =>
      'Reserve in seconds and get an answer from the café.';

  @override
  String get getStarted => 'Get started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get verifyPhone => 'Verify your number';

  @override
  String otpSentTo(String target) {
    return 'We sent a code to $target';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verify => 'Verify';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsLetterAndNumber =>
      'Password needs a letter and a number';

  @override
  String get passwordsDoNotMatch => 'Passwords don\'t match';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get phoneRequired => 'Please enter your phone number';

  @override
  String get phoneInvalid => 'Enter a valid number, e.g. +9647501234567';

  @override
  String get home => 'Home';

  @override
  String get explore => 'Explore';

  @override
  String get map => 'Map';

  @override
  String get favorites => 'Saved';

  @override
  String get profile => 'Profile';

  @override
  String get popular => 'Popular';

  @override
  String get featured => 'Featured';

  @override
  String get nearby => 'Nearby';

  @override
  String get allCafes => 'All cafés';

  @override
  String get searchHint => 'Search cafés…';

  @override
  String get noResults => 'No cafés match';

  @override
  String get noResultsBody => 'Try a different search or clear your filters.';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear all';

  @override
  String get apply => 'Apply';

  @override
  String get area => 'Area';

  @override
  String get allAreas => 'All areas';

  @override
  String get priceRange => 'Price';

  @override
  String get amenities => 'Amenities';

  @override
  String get minimumRating => 'Minimum rating';

  @override
  String get openNow => 'Open now';

  @override
  String get closed => 'Closed';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortDistance => 'Nearest';

  @override
  String get sortReviews => 'Most reviewed';

  @override
  String get sortNewest => 'Newest';

  @override
  String get menu => 'Menu';

  @override
  String get reviews => 'Reviews';

  @override
  String get about => 'About';

  @override
  String get gallery => 'Photos';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get call => 'Call';

  @override
  String get directions => 'Directions';

  @override
  String get share => 'Share';

  @override
  String get bookTable => 'Book a table';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String distanceAway(String km) {
    return '$km km away';
  }

  @override
  String get noMenuYet => 'This café hasn\'t added a menu yet';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get writeReview => 'Write a review';

  @override
  String get editReview => 'Edit your review';

  @override
  String get yourRating => 'Your rating';

  @override
  String get reviewHint => 'What was your experience?';

  @override
  String get submitReview => 'Submit';

  @override
  String get reviewPending => 'Thanks! Your review will appear once approved.';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get beFirstToReview => 'Be the first to review this café.';

  @override
  String get replyFromCafe => 'Reply from the café';

  @override
  String get savedCafes => 'Saved cafés';

  @override
  String get noFavorites => 'Nothing saved yet';

  @override
  String get noFavoritesBody => 'Tap the heart on a café to save it here.';

  @override
  String get reservations => 'Bookings';

  @override
  String get myBookings => 'My bookings';

  @override
  String get selectDate => 'Date';

  @override
  String get selectTime => 'Time';

  @override
  String get partySize => 'Guests';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Phone';

  @override
  String get specialRequest => 'Special request (optional)';

  @override
  String get specialRequestHint => 'A quiet corner, a highchair…';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get bookingReference => 'Reference';

  @override
  String get bookingPending => 'Awaiting confirmation';

  @override
  String get bookingConfirmed => 'Confirmed';

  @override
  String get bookingDeclined => 'Declined';

  @override
  String get bookingCancelled => 'Cancelled';

  @override
  String get bookingCompleted => 'Completed';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelBookingConfirm => 'Cancel this booking?';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String get noBookingsBody => 'Book a table and it will appear here.';

  @override
  String get fullyBooked => 'Fully booked';

  @override
  String seatsLeft(int count) {
    return '$count seats left';
  }

  @override
  String get closedOnDay => 'The café is closed that day';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Appearance';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get aboutApp => 'About';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'This cannot be undone. Delete your account?';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get seeAll => 'See all';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorNetworkBody => 'Check your connection and try again.';

  @override
  String get errorServer => 'The server is not responding';

  @override
  String get errorTimeout => 'That took too long — please try again';

  @override
  String get errorUnauthorized => 'Please sign in to continue';

  @override
  String get offlineBanner => 'You\'re offline — showing saved data';

  @override
  String get signInRequired => 'Sign in required';

  @override
  String get signInToFavorite => 'Sign in to save cafés.';

  @override
  String get signInToReview => 'Sign in to write a review.';

  @override
  String get signInToBook => 'Sign in to book a table.';

  @override
  String get currencyIqd => 'IQD';

  @override
  String get priceBudget => 'Budget';

  @override
  String get priceModerate => 'Moderate';

  @override
  String get priceUpscale => 'Upscale';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get noPhotoYet => 'No photo yet';

  @override
  String get photoUnavailable => 'Photo unavailable';

  @override
  String get featuredSubtitle => 'Hand-picked places worth the trip';

  @override
  String get openRightNow => 'Open right now';

  @override
  String get openRightNowSubtitle => 'Serving at this hour';

  @override
  String get popularSubtitle => 'What Erbil is ordering';

  @override
  String get browseByArea => 'Browse by area';

  @override
  String get browseByAreaSubtitle => 'Pick a part of the city';

  @override
  String get newCafe => 'New';

  @override
  String cafeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cafés',
      one: '1 café',
      zero: 'No cafés',
    );
    return '$_temp0';
  }

  @override
  String get rateThisCafe => 'Rate this café';

  @override
  String get tapToRate => 'Tap a star to rate';

  @override
  String get yourReview => 'Your review';

  @override
  String get reviewPublished => 'Thanks! Your rating is live.';

  @override
  String basedOnReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count ratings',
      one: 'Based on 1 rating',
      zero: 'No ratings yet',
    );
    return '$_temp0';
  }

  @override
  String get reviewVisibleToEveryone =>
      'Your rating goes live straight away and everyone will see it.';

  @override
  String get dataAttribution =>
      'Café data © OpenStreetMap contributors (ODbL) and Overture Maps Foundation (CDLA Permissive 2.0, Apache 2.0).';

  @override
  String get preferences => 'Preferences';

  @override
  String get contactAndLinks => 'Contact & links';

  @override
  String get website => 'Website';

  @override
  String get facebook => 'Facebook';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get instagram => 'Instagram';

  @override
  String get address => 'Address';

  @override
  String seats(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get viewAllPhotos => 'View all photos';

  @override
  String photoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String get mapStyle => 'Map style';

  @override
  String get deleteAccountExplain =>
      'Your name, email and phone number are erased. Your bookings are cancelled and your saved cafés are removed. Reviews you have written stay on the café, shown as “Deleted user”.';

  @override
  String get deleteAccountDone => 'Your account has been deleted.';

  @override
  String get deleteAccountAction => 'Delete my account';

  @override
  String get account => 'Account';

  @override
  String get optional => 'optional';

  @override
  String get profileSaved => 'Your profile has been saved.';

  @override
  String get emailCannotChange =>
      'Your email is how you sign in, so it cannot be changed here. Contact support if you need to change it.';

  @override
  String get phoneChangeNote =>
      'Changing your number means it will need to be verified again.';

  @override
  String get passwordChanged =>
      'Password changed. Other devices have been signed out.';

  @override
  String get passwordChangeExplain =>
      'After changing it, every other phone signed in to your account will need the new password.';

  @override
  String get newPasswordSameAsOld =>
      'Choose a password different from your current one.';

  @override
  String get helpAndSupport => 'Help & support';

  @override
  String get helpCenter => 'Help & FAQ';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportProblemSubject => 'Problem report';

  @override
  String noEmailApp(String address) {
    return 'No email app is set up. Write to us at $address — it has been copied.';
  }

  @override
  String get legal => 'Legal';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get openSourceLicenses => 'Open-source licences';

  @override
  String get couldNotOpenPage => 'That page could not be opened.';

  @override
  String get storage => 'Storage';

  @override
  String get clearCache => 'Clear cached photos and data';

  @override
  String get clearCacheSubtitle =>
      'Frees space on your phone. Photos download again as you browse.';

  @override
  String get cacheCleared => 'Cached photos and data cleared.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get faqTitle => 'Frequently asked questions';

  @override
  String get faqFindQ => 'How do I find a café?';

  @override
  String get faqFindA =>
      'Use Explore to search by name in Kurdish, Arabic or English, and narrow the list with the chips — open now, price, what the café offers, or its area. The Map tab shows every café; tap a number to zoom into that part of town.';

  @override
  String get faqOpenNowQ => 'Why does a café show as closed when it is open?';

  @override
  String get faqOpenNowA =>
      '“Open now” is worked out from the café\'s opening hours. Many cafés have not listed their hours yet, and a café with no hours cannot be shown as open. If you know a café\'s hours, report them and we will add them.';

  @override
  String get faqSaveQ => 'How do I save a café?';

  @override
  String get faqSaveA =>
      'Tap the heart on its card or at the top of its page. Saved cafés are in the Saved tab. Saving needs an account, so your list follows you to a new phone.';

  @override
  String get faqBookQ => 'How does booking a table work?';

  @override
  String get faqBookA =>
      'Choose a date, a time and how many people on the café\'s page and send the request. The café confirms or declines it, and you are notified either way. Your requests and their status are in My bookings.';

  @override
  String get faqCancelQ => 'How do I cancel a booking?';

  @override
  String get faqCancelA =>
      'Open My bookings from your profile and tap Cancel booking on a request that is still pending or confirmed. It shows as cancelled on the café\'s side at once.';

  @override
  String get faqRateQ => 'How do ratings and reviews work?';

  @override
  String get faqRateA =>
      'Tap the stars on a café\'s page to rate it, and add a written review if you like. You have one review per café; rating again replaces it. Reviews appear straight away, and ones that break the rules are removed.';

  @override
  String get faqWrongInfoQ =>
      'A café\'s details are wrong or missing. What can I do?';

  @override
  String get faqWrongInfoA =>
      'Use Report a problem and tell us the café\'s name and what should change — hours, phone number, location or photos. Café owners can also manage their own page.';

  @override
  String get faqLanguageQ => 'How do I change the language?';

  @override
  String get faqLanguageA =>
      'Choose it under Preferences in your profile. Café names and descriptions switch too, wherever the café has a translation.';

  @override
  String get faqDeleteQ => 'How do I delete my account?';

  @override
  String get faqDeleteA =>
      'Scroll to the bottom of your profile and tap Delete my account. Your personal details are erased and your bookings cancelled; your reviews stay on the café as “Deleted user”.';

  @override
  String get stillNeedHelp => 'Still need help?';

  @override
  String get stillNeedHelpBody =>
      'Write to us and a person will answer, usually within a day.';

  @override
  String get nearMe => 'Near me';

  @override
  String get nearYou => 'Near you';

  @override
  String get nearYouSubtitle => 'The closest cafés, nearest first';

  @override
  String get locationPromptTitle => 'Find cafés near you';

  @override
  String get locationPromptBody =>
      'Allow location to see the closest cafés and how far away each one is.';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get locationDeniedBody =>
      'Location access is turned off for ErbilCafe. Turn it on in Settings to see cafés near you.';

  @override
  String get locationServiceOffBody =>
      'Location services are off on this phone. Turn them on to see cafés near you.';

  @override
  String get locationUnavailable =>
      'Your location could not be found. Try again in a moment.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locating => 'Finding your location…';

  @override
  String noCafesNearby(int km) {
    return 'No cafés within $km km of you yet.';
  }

  @override
  String get sortName => 'Name A–Z';

  @override
  String get myLocation => 'My location';

  @override
  String get noNotificationsBody =>
      'Booking updates, replies to your reviews and news from cafés will appear here.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'Yesterday',
    );
    return '$_temp0';
  }

  @override
  String shareCafeMessage(String name, String url) {
    return '$name on ErbilCafe\n$url';
  }

  @override
  String get reportWrongInfo =>
      'Something wrong with this café\'s details? Tell us';

  @override
  String wrongInfoSubject(String name) {
    return 'Wrong details: $name';
  }

  @override
  String get myReviews => 'My reviews';

  @override
  String get noMyReviews => 'No reviews yet';

  @override
  String get noMyReviewsBody =>
      'Rate a café from its page and your reviews will be collected here.';

  @override
  String get deleteReviewConfirm => 'Delete this review?';

  @override
  String get deleteReviewExplain =>
      'It is removed from the café\'s page and no longer counts towards its rating.';

  @override
  String get reviewDeleted => 'Review deleted.';

  @override
  String get edit => 'Edit';

  @override
  String get updateReview => 'Update review';

  @override
  String get forgotPasswordBody =>
      'Enter your email and we will send you a code to choose a new password.';

  @override
  String get sendCode => 'Send code';

  @override
  String get resetPasswordTitle => 'Choose a new password';

  @override
  String get verificationCode => '6-digit code';

  @override
  String get codeIncomplete => 'Enter all 6 digits of the code.';

  @override
  String get passwordResetDone =>
      'Your password has been changed. You are signed in.';

  @override
  String devCodeHint(String code) {
    return 'Development build — code: $code';
  }

  @override
  String get verifyEmail => 'Verify your email';

  @override
  String get verifyEmailBody =>
      'Confirming your email makes sure booking updates and password resets reach you.';

  @override
  String get emailVerifiedDone => 'Your email is verified.';

  @override
  String get emailNotVerified => 'Email not verified';
}
