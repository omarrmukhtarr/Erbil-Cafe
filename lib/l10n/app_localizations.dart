import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ErbilCafe'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover the cafés of Erbil'**
  String get appTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Find your café'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Every café in Erbil in one place, with photos, menus and real prices.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'See the menu first'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Browse drinks and food with up-to-date prices before you go.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Book a table'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Reserve in seconds and get an answer from the café.'**
  String get onboardingBody3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyPhone;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {target}'**
  String otpSentTo(String target);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedsLetterAndNumber.
  ///
  /// In en, this message translates to:
  /// **'Password needs a letter and a number'**
  String get passwordNeedsLetterAndNumber;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number, e.g. +9647501234567'**
  String get phoneInvalid;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @allCafes.
  ///
  /// In en, this message translates to:
  /// **'All cafés'**
  String get allCafes;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cafés…'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No cafés match'**
  String get noResults;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear your filters.'**
  String get noResultsBody;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearFilters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @allAreas.
  ///
  /// In en, this message translates to:
  /// **'All areas'**
  String get allAreas;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceRange;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @minimumRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get minimumRating;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortRating;

  /// No description provided for @sortDistance.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortDistance;

  /// No description provided for @sortReviews.
  ///
  /// In en, this message translates to:
  /// **'Most reviewed'**
  String get sortReviews;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get gallery;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get openingHours;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @bookTable.
  ///
  /// In en, this message translates to:
  /// **'Book a table'**
  String get bookTable;

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}'**
  String reviewCount(int count);

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String distanceAway(String km);

  /// No description provided for @noMenuYet.
  ///
  /// In en, this message translates to:
  /// **'This café hasn\'t added a menu yet'**
  String get noMenuYet;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit your review'**
  String get editReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'What was your experience?'**
  String get reviewHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitReview;

  /// No description provided for @reviewPending.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your review will appear once approved.'**
  String get reviewPending;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to review this café.'**
  String get beFirstToReview;

  /// No description provided for @replyFromCafe.
  ///
  /// In en, this message translates to:
  /// **'Reply from the café'**
  String get replyFromCafe;

  /// No description provided for @savedCafes.
  ///
  /// In en, this message translates to:
  /// **'Saved cafés'**
  String get savedCafes;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get noFavorites;

  /// No description provided for @noFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a café to save it here.'**
  String get noFavoritesBody;

  /// No description provided for @reservations.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get reservations;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookings;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get selectTime;

  /// No description provided for @partySize.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get partySize;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// No description provided for @specialRequest.
  ///
  /// In en, this message translates to:
  /// **'Special request (optional)'**
  String get specialRequest;

  /// No description provided for @specialRequestHint.
  ///
  /// In en, this message translates to:
  /// **'A quiet corner, a highchair…'**
  String get specialRequestHint;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get bookingReference;

  /// No description provided for @bookingPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get bookingPending;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get bookingDeclined;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingCancelled;

  /// No description provided for @bookingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingCompleted;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get cancelBookingConfirm;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @noBookingsBody.
  ///
  /// In en, this message translates to:
  /// **'Book a table and it will appear here.'**
  String get noBookingsBody;

  /// No description provided for @fullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Fully booked'**
  String get fullyBooked;

  /// No description provided for @seatsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seatsLeft(int count);

  /// No description provided for @closedOnDay.
  ///
  /// In en, this message translates to:
  /// **'The café is closed that day'**
  String get closedOnDay;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Delete your account?'**
  String get deleteAccountConfirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorNetworkBody;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server is not responding'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'That took too long — please try again'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get errorUnauthorized;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing saved data'**
  String get offlineBanner;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequired;

  /// No description provided for @signInToFavorite.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save cafés.'**
  String get signInToFavorite;

  /// No description provided for @signInToReview.
  ///
  /// In en, this message translates to:
  /// **'Sign in to write a review.'**
  String get signInToReview;

  /// No description provided for @signInToBook.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book a table.'**
  String get signInToBook;

  /// No description provided for @currencyIqd.
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get currencyIqd;

  /// No description provided for @priceBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get priceBudget;

  /// No description provided for @priceModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get priceModerate;

  /// No description provided for @priceUpscale.
  ///
  /// In en, this message translates to:
  /// **'Upscale'**
  String get priceUpscale;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @noPhotoYet.
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get noPhotoYet;

  /// No description provided for @photoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable'**
  String get photoUnavailable;

  /// No description provided for @featuredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hand-picked places worth the trip'**
  String get featuredSubtitle;

  /// No description provided for @openRightNow.
  ///
  /// In en, this message translates to:
  /// **'Open right now'**
  String get openRightNow;

  /// No description provided for @openRightNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Serving at this hour'**
  String get openRightNowSubtitle;

  /// No description provided for @popularSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What Erbil is ordering'**
  String get popularSubtitle;

  /// No description provided for @browseByArea.
  ///
  /// In en, this message translates to:
  /// **'Browse by area'**
  String get browseByArea;

  /// No description provided for @browseByAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a part of the city'**
  String get browseByAreaSubtitle;

  /// No description provided for @newCafe.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCafe;

  /// No description provided for @cafeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No cafés} =1{1 café} other{{count} cafés}}'**
  String cafeCount(int count);

  /// No description provided for @rateThisCafe.
  ///
  /// In en, this message translates to:
  /// **'Rate this café'**
  String get rateThisCafe;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate'**
  String get tapToRate;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @reviewPublished.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your rating is live.'**
  String get reviewPublished;

  /// No description provided for @basedOnReviews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No ratings yet} =1{Based on 1 rating} other{Based on {count} ratings}}'**
  String basedOnReviews(int count);

  /// No description provided for @reviewVisibleToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Your rating goes live straight away and everyone will see it.'**
  String get reviewVisibleToEveryone;

  /// No description provided for @dataAttribution.
  ///
  /// In en, this message translates to:
  /// **'Café data © OpenStreetMap contributors (ODbL) and Overture Maps Foundation (CDLA Permissive 2.0, Apache 2.0).'**
  String get dataAttribution;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @contactAndLinks.
  ///
  /// In en, this message translates to:
  /// **'Contact & links'**
  String get contactAndLinks;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seat} other{{count} seats}}'**
  String seats(int count);

  /// No description provided for @viewAllPhotos.
  ///
  /// In en, this message translates to:
  /// **'View all photos'**
  String get viewAllPhotos;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos} =1{1 photo} other{{count} photos}}'**
  String photoCount(int count);

  /// No description provided for @mapStyle.
  ///
  /// In en, this message translates to:
  /// **'Map style'**
  String get mapStyle;

  /// No description provided for @deleteAccountExplain.
  ///
  /// In en, this message translates to:
  /// **'Your name, email and phone number are erased. Your bookings are cancelled and your saved cafés are removed. Reviews you have written stay on the café, shown as “Deleted user”.'**
  String get deleteAccountExplain;

  /// No description provided for @deleteAccountDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get deleteAccountDone;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountAction;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Your profile has been saved.'**
  String get profileSaved;

  /// No description provided for @emailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Your email is how you sign in, so it cannot be changed here. Contact support if you need to change it.'**
  String get emailCannotChange;

  /// No description provided for @phoneChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Changing your number means it will need to be verified again.'**
  String get phoneChangeNote;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices have been signed out.'**
  String get passwordChanged;

  /// No description provided for @passwordChangeExplain.
  ///
  /// In en, this message translates to:
  /// **'After changing it, every other phone signed in to your account will need the new password.'**
  String get passwordChangeExplain;

  /// No description provided for @newPasswordSameAsOld.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from your current one.'**
  String get newPasswordSameAsOld;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpAndSupport;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpCenter;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @reportProblemSubject.
  ///
  /// In en, this message translates to:
  /// **'Problem report'**
  String get reportProblemSubject;

  /// No description provided for @noEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app is set up. Write to us at {address} — it has been copied.'**
  String noEmailApp(String address);

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get openSourceLicenses;

  /// No description provided for @couldNotOpenPage.
  ///
  /// In en, this message translates to:
  /// **'That page could not be opened.'**
  String get couldNotOpenPage;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cached photos and data'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frees space on your phone. Photos download again as you browse.'**
  String get clearCacheSubtitle;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cached photos and data cleared.'**
  String get cacheCleared;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// No description provided for @faqFindQ.
  ///
  /// In en, this message translates to:
  /// **'How do I find a café?'**
  String get faqFindQ;

  /// No description provided for @faqFindA.
  ///
  /// In en, this message translates to:
  /// **'Use Explore to search by name in Kurdish, Arabic or English, and narrow the list with the chips — open now, price, what the café offers, or its area. The Map tab shows every café; tap a number to zoom into that part of town.'**
  String get faqFindA;

  /// No description provided for @faqOpenNowQ.
  ///
  /// In en, this message translates to:
  /// **'Why does a café show as closed when it is open?'**
  String get faqOpenNowQ;

  /// No description provided for @faqOpenNowA.
  ///
  /// In en, this message translates to:
  /// **'“Open now” is worked out from the café\'s opening hours. Many cafés have not listed their hours yet, and a café with no hours cannot be shown as open. If you know a café\'s hours, report them and we will add them.'**
  String get faqOpenNowA;

  /// No description provided for @faqSaveQ.
  ///
  /// In en, this message translates to:
  /// **'How do I save a café?'**
  String get faqSaveQ;

  /// No description provided for @faqSaveA.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on its card or at the top of its page. Saved cafés are in the Saved tab. Saving needs an account, so your list follows you to a new phone.'**
  String get faqSaveA;

  /// No description provided for @faqBookQ.
  ///
  /// In en, this message translates to:
  /// **'How does booking a table work?'**
  String get faqBookQ;

  /// No description provided for @faqBookA.
  ///
  /// In en, this message translates to:
  /// **'Choose a date, a time and how many people on the café\'s page and send the request. The café confirms or declines it, and you are notified either way. Your requests and their status are in My bookings.'**
  String get faqBookA;

  /// No description provided for @faqCancelQ.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel a booking?'**
  String get faqCancelQ;

  /// No description provided for @faqCancelA.
  ///
  /// In en, this message translates to:
  /// **'Open My bookings from your profile and tap Cancel booking on a request that is still pending or confirmed. It shows as cancelled on the café\'s side at once.'**
  String get faqCancelA;

  /// No description provided for @faqRateQ.
  ///
  /// In en, this message translates to:
  /// **'How do ratings and reviews work?'**
  String get faqRateQ;

  /// No description provided for @faqRateA.
  ///
  /// In en, this message translates to:
  /// **'Tap the stars on a café\'s page to rate it, and add a written review if you like. You have one review per café; rating again replaces it. Reviews appear straight away, and ones that break the rules are removed.'**
  String get faqRateA;

  /// No description provided for @faqWrongInfoQ.
  ///
  /// In en, this message translates to:
  /// **'A café\'s details are wrong or missing. What can I do?'**
  String get faqWrongInfoQ;

  /// No description provided for @faqWrongInfoA.
  ///
  /// In en, this message translates to:
  /// **'Use Report a problem and tell us the café\'s name and what should change — hours, phone number, location or photos. Café owners can also manage their own page.'**
  String get faqWrongInfoA;

  /// No description provided for @faqLanguageQ.
  ///
  /// In en, this message translates to:
  /// **'How do I change the language?'**
  String get faqLanguageQ;

  /// No description provided for @faqLanguageA.
  ///
  /// In en, this message translates to:
  /// **'Choose it under Preferences in your profile. Café names and descriptions switch too, wherever the café has a translation.'**
  String get faqLanguageA;

  /// No description provided for @faqDeleteQ.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faqDeleteQ;

  /// No description provided for @faqDeleteA.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the bottom of your profile and tap Delete my account. Your personal details are erased and your bookings cancelled; your reviews stay on the café as “Deleted user”.'**
  String get faqDeleteA;

  /// No description provided for @stillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get stillNeedHelp;

  /// No description provided for @stillNeedHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Write to us and a person will answer, usually within a day.'**
  String get stillNeedHelpBody;

  /// No description provided for @nearMe.
  ///
  /// In en, this message translates to:
  /// **'Near me'**
  String get nearMe;

  /// No description provided for @nearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get nearYou;

  /// No description provided for @nearYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The closest cafés, nearest first'**
  String get nearYouSubtitle;

  /// No description provided for @locationPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Find cafés near you'**
  String get locationPromptTitle;

  /// No description provided for @locationPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location to see the closest cafés and how far away each one is.'**
  String get locationPromptBody;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @locationDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off for ErbilCafe. Turn it on in Settings to see cafés near you.'**
  String get locationDeniedBody;

  /// No description provided for @locationServiceOffBody.
  ///
  /// In en, this message translates to:
  /// **'Location services are off on this phone. Turn them on to see cafés near you.'**
  String get locationServiceOffBody;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your location could not be found. Try again in a moment.'**
  String get locationUnavailable;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locating;

  /// No description provided for @noCafesNearby.
  ///
  /// In en, this message translates to:
  /// **'No cafés within {km} km of you yet.'**
  String noCafesNearby(int km);

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get sortName;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Booking updates, replies to your reviews and news from cafés will appear here.'**
  String get noNotificationsBody;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Yesterday} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// No description provided for @shareCafeMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} on ErbilCafe\n{url}'**
  String shareCafeMessage(String name, String url);

  /// No description provided for @reportWrongInfo.
  ///
  /// In en, this message translates to:
  /// **'Something wrong with this café\'s details? Tell us'**
  String get reportWrongInfo;

  /// No description provided for @wrongInfoSubject.
  ///
  /// In en, this message translates to:
  /// **'Wrong details: {name}'**
  String wrongInfoSubject(String name);

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My reviews'**
  String get myReviews;

  /// No description provided for @noMyReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noMyReviews;

  /// No description provided for @noMyReviewsBody.
  ///
  /// In en, this message translates to:
  /// **'Rate a café from its page and your reviews will be collected here.'**
  String get noMyReviewsBody;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this review?'**
  String get deleteReviewConfirm;

  /// No description provided for @deleteReviewExplain.
  ///
  /// In en, this message translates to:
  /// **'It is removed from the café\'s page and no longer counts towards its rating.'**
  String get deleteReviewExplain;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted.'**
  String get reviewDeleted;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @updateReview.
  ///
  /// In en, this message translates to:
  /// **'Update review'**
  String get updateReview;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a code to choose a new password.'**
  String get forgotPasswordBody;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetPasswordTitle;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get verificationCode;

  /// No description provided for @codeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits of the code.'**
  String get codeIncomplete;

  /// No description provided for @passwordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed. You are signed in.'**
  String get passwordResetDone;

  /// No description provided for @devCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Development build — code: {code}'**
  String devCodeHint(String code);

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmail;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Confirming your email makes sure booking updates and password resets reach you.'**
  String get verifyEmailBody;

  /// No description provided for @emailVerifiedDone.
  ///
  /// In en, this message translates to:
  /// **'Your email is verified.'**
  String get emailVerifiedDone;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
