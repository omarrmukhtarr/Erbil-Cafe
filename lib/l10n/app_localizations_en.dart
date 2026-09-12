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
      'Café locations © OpenStreetMap contributors, ODbL.';

  @override
  String get preferences => 'Preferences';

  @override
  String get contactAndLinks => 'Contact & links';

  @override
  String get website => 'Website';

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
}
