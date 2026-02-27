import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customer;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @seed.
  ///
  /// In en, this message translates to:
  /// **'Seed Database'**
  String get seed;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'Beta V1.0'**
  String get beta;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutTitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out from this account?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get indonesian;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @ships.
  ///
  /// In en, this message translates to:
  /// **'Ships'**
  String get ships;

  /// No description provided for @vacations.
  ///
  /// In en, this message translates to:
  /// **'Vacations'**
  String get vacations;

  /// No description provided for @moments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get moments;

  /// No description provided for @bus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @lakeToba.
  ///
  /// In en, this message translates to:
  /// **'Lake Toba'**
  String get lakeToba;

  /// No description provided for @traveler.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get traveler;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(Object name);

  /// No description provided for @exploreLakeTobaToday.
  ///
  /// In en, this message translates to:
  /// **'Explore Lake Toba\\nToday'**
  String get exploreLakeTobaToday;

  /// No description provided for @recommendedHotels.
  ///
  /// In en, this message translates to:
  /// **'Recommended Hotels'**
  String get recommendedHotels;

  /// No description provided for @topDestinations.
  ///
  /// In en, this message translates to:
  /// **'Top Destinations'**
  String get topDestinations;

  /// No description provided for @culinaryDelights.
  ///
  /// In en, this message translates to:
  /// **'Culinary Delights'**
  String get culinaryDelights;

  /// No description provided for @hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @culinary.
  ///
  /// In en, this message translates to:
  /// **'Culinary'**
  String get culinary;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data.'**
  String get failedToLoadData;

  /// No description provided for @noRecommendationsYet.
  ///
  /// In en, this message translates to:
  /// **'No recommendations yet.'**
  String get noRecommendationsYet;

  /// No description provided for @destinationRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Destination Recommendations'**
  String get destinationRecommendations;

  /// No description provided for @culinaryRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Culinary Recommendations'**
  String get culinaryRecommendations;

  /// No description provided for @hotelRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Hotel Recommendations'**
  String get hotelRecommendations;

  /// No description provided for @noRecommendationsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Recommendations Yet'**
  String get noRecommendationsYetTitle;

  /// No description provided for @exploreMoreDestinations.
  ///
  /// In en, this message translates to:
  /// **'Explore more destinations so we can recommend places that fit you better.'**
  String get exploreMoreDestinations;

  /// No description provided for @exploreMoreCulinary.
  ///
  /// In en, this message translates to:
  /// **'Explore more culinary spots so we can recommend dishes that match your taste.'**
  String get exploreMoreCulinary;

  /// No description provided for @searchHotelName.
  ///
  /// In en, this message translates to:
  /// **'Search hotel name...'**
  String get searchHotelName;

  /// No description provided for @hotelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Hotel Not Found'**
  String get hotelNotFound;

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try using a different search keyword.'**
  String get tryDifferentKeyword;

  /// No description provided for @travelDestinations.
  ///
  /// In en, this message translates to:
  /// **'Travel Destinations'**
  String get travelDestinations;

  /// No description provided for @searchDestinations.
  ///
  /// In en, this message translates to:
  /// **'Search destinations...'**
  String get searchDestinations;

  /// No description provided for @destinationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Destination Not Found'**
  String get destinationNotFound;

  /// No description provided for @tryDifferentKeywordOrCategory.
  ///
  /// In en, this message translates to:
  /// **'Try using a different keyword\\nor category filter.'**
  String get tryDifferentKeywordOrCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @lake.
  ///
  /// In en, this message translates to:
  /// **'Lake'**
  String get lake;

  /// No description provided for @waterfall.
  ///
  /// In en, this message translates to:
  /// **'Waterfall'**
  String get waterfall;

  /// No description provided for @hill.
  ///
  /// In en, this message translates to:
  /// **'Hill'**
  String get hill;

  /// No description provided for @culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get culture;

  /// No description provided for @beach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get beach;

  /// No description provided for @unableOpenMapLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the map link.'**
  String get unableOpenMapLink;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @aboutThisPlace.
  ///
  /// In en, this message translates to:
  /// **'About This Place'**
  String get aboutThisPlace;

  /// No description provided for @busTravelTickets.
  ///
  /// In en, this message translates to:
  /// **'Bus & Travel Tickets'**
  String get busTravelTickets;

  /// No description provided for @shipTickets.
  ///
  /// In en, this message translates to:
  /// **'Ship Tickets'**
  String get shipTickets;

  /// No description provided for @chooseYourRoute.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Route'**
  String get chooseYourRoute;

  /// No description provided for @chooseYourSailingRoute.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Sailing Route'**
  String get chooseYourSailingRoute;

  /// No description provided for @findBusSchedules.
  ///
  /// In en, this message translates to:
  /// **'Find bus or travel schedules for your trip'**
  String get findBusSchedules;

  /// No description provided for @findShipSchedules.
  ///
  /// In en, this message translates to:
  /// **'Find the best Lake Toba ferry schedules for your trip.'**
  String get findShipSchedules;

  /// No description provided for @departureCity.
  ///
  /// In en, this message translates to:
  /// **'Departure City'**
  String get departureCity;

  /// No description provided for @destinationCity.
  ///
  /// In en, this message translates to:
  /// **'Destination City'**
  String get destinationCity;

  /// No description provided for @departurePort.
  ///
  /// In en, this message translates to:
  /// **'Departure Port'**
  String get departurePort;

  /// No description provided for @destinationPort.
  ///
  /// In en, this message translates to:
  /// **'Destination Port'**
  String get destinationPort;

  /// No description provided for @availableSchedules.
  ///
  /// In en, this message translates to:
  /// **'Available Schedules'**
  String get availableSchedules;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route Not Found'**
  String get routeNotFound;

  /// No description provided for @noBusSchedulesFromToYet.
  ///
  /// In en, this message translates to:
  /// **'No bus schedules are available from {from} to {to} yet.'**
  String noBusSchedulesFromToYet(Object from, Object to);

  /// No description provided for @noShipSchedulesFromTo.
  ///
  /// In en, this message translates to:
  /// **'No ship schedules are currently available from {from} to {to}.'**
  String noShipSchedulesFromTo(Object from, Object to);

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @regularFerry.
  ///
  /// In en, this message translates to:
  /// **'Regular Ferry'**
  String get regularFerry;

  /// No description provided for @passengerTicket.
  ///
  /// In en, this message translates to:
  /// **'Passenger Ticket'**
  String get passengerTicket;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @departureSchedule.
  ///
  /// In en, this message translates to:
  /// **'Departure Schedule'**
  String get departureSchedule;

  /// No description provided for @bookTicket.
  ///
  /// In en, this message translates to:
  /// **'Book Ticket'**
  String get bookTicket;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @travelRoute.
  ///
  /// In en, this message translates to:
  /// **'Travel Route'**
  String get travelRoute;

  /// No description provided for @shipRoute.
  ///
  /// In en, this message translates to:
  /// **'Ship Route'**
  String get shipRoute;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @passengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @processingOrder.
  ///
  /// In en, this message translates to:
  /// **'Processing your order...'**
  String get processingOrder;

  /// No description provided for @orderSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Order Successful!'**
  String get orderSuccessful;

  /// No description provided for @pleaseCompletePayment.
  ///
  /// In en, this message translates to:
  /// **'Please complete your payment.'**
  String get pleaseCompletePayment;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continueToPayment;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @travelOperator.
  ///
  /// In en, this message translates to:
  /// **'Travel Operator'**
  String get travelOperator;

  /// No description provided for @schedulePassengers.
  ///
  /// In en, this message translates to:
  /// **'Schedule & Passengers'**
  String get schedulePassengers;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @numberOfPassengers.
  ///
  /// In en, this message translates to:
  /// **'Number of Passengers'**
  String get numberOfPassengers;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectType;

  /// No description provided for @selectBankProvider.
  ///
  /// In en, this message translates to:
  /// **'Select Bank/Provider'**
  String get selectBankProvider;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @pleaseCompleteAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all fields.'**
  String get pleaseCompleteAllFields;

  /// No description provided for @lakeTobaHotels.
  ///
  /// In en, this message translates to:
  /// **'Lake Toba Hotels'**
  String get lakeTobaHotels;

  /// No description provided for @allLocations.
  ///
  /// In en, this message translates to:
  /// **'All Locations'**
  String get allLocations;

  /// No description provided for @mainFacilities.
  ///
  /// In en, this message translates to:
  /// **'Main Facilities'**
  String get mainFacilities;

  /// No description provided for @latestReviews.
  ///
  /// In en, this message translates to:
  /// **'Latest Reviews'**
  String get latestReviews;

  /// No description provided for @noReviewsForHotelYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this hotel yet'**
  String get noReviewsForHotelYet;

  /// No description provided for @roomOptions.
  ///
  /// In en, this message translates to:
  /// **'Room Options'**
  String get roomOptions;

  /// No description provided for @noRoomsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rooms available'**
  String get noRoomsAvailable;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @continueBooking.
  ///
  /// In en, this message translates to:
  /// **'Continue booking?'**
  String get continueBooking;

  /// No description provided for @bookingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful!'**
  String get bookingSuccessful;

  /// No description provided for @thankYouBookingProcessed.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your order is being processed.'**
  String get thankYouBookingProcessed;

  /// No description provided for @completePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePayment;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @failedToAddHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to add history: {error}'**
  String failedToAddHistory(Object error);

  /// No description provided for @failedToProcessBooking.
  ///
  /// In en, this message translates to:
  /// **'The system failed to process your booking: {error}'**
  String failedToProcessBooking(Object error);

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get night;

  /// No description provided for @stayDates.
  ///
  /// In en, this message translates to:
  /// **'Stay Dates'**
  String get stayDates;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @selectBank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get selectBank;

  /// No description provided for @selectEWallet.
  ///
  /// In en, this message translates to:
  /// **'Select E-Wallet'**
  String get selectEWallet;

  /// No description provided for @creditCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Number'**
  String get creditCardNumber;

  /// No description provided for @allReviews.
  ///
  /// In en, this message translates to:
  /// **'All Reviews'**
  String get allReviews;

  /// No description provided for @filterReviews.
  ///
  /// In en, this message translates to:
  /// **'Filter Reviews'**
  String get filterReviews;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @errorLoadingReviews.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading reviews.'**
  String get errorLoadingReviews;

  /// No description provided for @noMatchingReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No matching reviews yet.'**
  String get noMatchingReviewsYet;

  /// No description provided for @showingFilter.
  ///
  /// In en, this message translates to:
  /// **'Showing filter:'**
  String get showingFilter;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @signatureCulinary.
  ///
  /// In en, this message translates to:
  /// **'Signature Culinary'**
  String get signatureCulinary;

  /// No description provided for @noCulinaryDataYet.
  ///
  /// In en, this message translates to:
  /// **'No culinary data available yet'**
  String get noCulinaryDataYet;

  /// No description provided for @failedToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedToLoadReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @deliveryAddressDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address Details'**
  String get deliveryAddressDetails;

  /// No description provided for @streetLandmark.
  ///
  /// In en, this message translates to:
  /// **'Street / Landmark'**
  String get streetLandmark;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @buildingDetails.
  ///
  /// In en, this message translates to:
  /// **'Building Details (House No., Color)'**
  String get buildingDetails;

  /// No description provided for @activePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Active Phone Number'**
  String get activePhoneNumber;

  /// No description provided for @streetAndPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Street address and phone number are required!'**
  String get streetAndPhoneRequired;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @completeDeliveryAddressFirst.
  ///
  /// In en, this message translates to:
  /// **'Please complete the delivery address first.'**
  String get completeDeliveryAddressFirst;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @orderNow.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNow;

  /// No description provided for @completePaymentFoodProcessed.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment so the food can be processed.'**
  String get completePaymentFoodProcessed;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @chooseDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose Delivery Address'**
  String get chooseDeliveryAddress;

  /// No description provided for @yourAddress.
  ///
  /// In en, this message translates to:
  /// **'Your Address'**
  String get yourAddress;

  /// No description provided for @notSetYet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get notSetYet;

  /// No description provided for @portionQuantity.
  ///
  /// In en, this message translates to:
  /// **'Portion Quantity'**
  String get portionQuantity;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (e.g., spicy, no celery)'**
  String get notesHint;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @portions.
  ///
  /// In en, this message translates to:
  /// **'portions'**
  String get portions;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @noStoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No stories yet. Be the first to share your moment.'**
  String get noStoriesYet;

  /// No description provided for @virtualAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'No. Virtual Account'**
  String get virtualAccountNumberLabel;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// No description provided for @highPrice.
  ///
  /// In en, this message translates to:
  /// **'High Price'**
  String get highPrice;

  /// No description provided for @lowPrice.
  ///
  /// In en, this message translates to:
  /// **'Low Price'**
  String get lowPrice;

  /// No description provided for @priceFilter.
  ///
  /// In en, this message translates to:
  /// **'Price Filter'**
  String get priceFilter;

  /// No description provided for @highRating.
  ///
  /// In en, this message translates to:
  /// **'High Rating'**
  String get highRating;

  /// No description provided for @lowRating.
  ///
  /// In en, this message translates to:
  /// **'Low Rating'**
  String get lowRating;

  /// No description provided for @ratingFilter.
  ///
  /// In en, this message translates to:
  /// **'Rating Filter'**
  String get ratingFilter;

  /// No description provided for @checkOutAfterCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-out date must be after Check-in'**
  String get checkOutAfterCheckIn;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @fillCaptionOrImage.
  ///
  /// In en, this message translates to:
  /// **'Please add a caption or image first.'**
  String get fillCaptionOrImage;

  /// No description provided for @tellVacationStory.
  ///
  /// In en, this message translates to:
  /// **'Tell us your vacation...'**
  String get tellVacationStory;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @shareStory.
  ///
  /// In en, this message translates to:
  /// **'Share Story'**
  String get shareStory;

  /// No description provided for @latestMoments.
  ///
  /// In en, this message translates to:
  /// **'Latest Moments'**
  String get latestMoments;

  /// No description provided for @secondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds ago'**
  String secondsAgo(Object count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @failedToDownloadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to download image: {url}'**
  String failedToDownloadImage(Object url);

  /// No description provided for @storyShareText.
  ///
  /// In en, this message translates to:
  /// **'Check out this story by {username}: {caption}'**
  String storyShareText(Object username, Object caption);

  /// No description provided for @failedToShareStory.
  ///
  /// In en, this message translates to:
  /// **'Failed to share story: {error}'**
  String failedToShareStory(Object error);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @likesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likesCount(Object count);

  /// No description provided for @deadlineMissedCancelled.
  ///
  /// In en, this message translates to:
  /// **'Deadline missed. Booking cancelled.'**
  String get deadlineMissedCancelled;

  /// No description provided for @waitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Payment'**
  String get waitingForPayment;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @firstBookingWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your first booking will appear here'**
  String get firstBookingWillAppear;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking?'**
  String get cancelBookingTitle;

  /// No description provided for @cancelBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get cancelBookingConfirm;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @paymentExpiredCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment time expired. Booking cancelled.'**
  String get paymentExpiredCancelled;

  /// No description provided for @reviewSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review saved successfully'**
  String get reviewSavedSuccessfully;

  /// No description provided for @failedToSaveReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to save review'**
  String get failedToSaveReview;

  /// No description provided for @transactionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful'**
  String get transactionSuccessful;

  /// No description provided for @completeIn.
  ///
  /// In en, this message translates to:
  /// **'Complete in'**
  String get completeIn;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction Date'**
  String get transactionDate;

  /// No description provided for @hotelName.
  ///
  /// In en, this message translates to:
  /// **'Hotel Name'**
  String get hotelName;

  /// No description provided for @roomType.
  ///
  /// In en, this message translates to:
  /// **'Room Type'**
  String get roomType;

  /// No description provided for @culinaryName.
  ///
  /// In en, this message translates to:
  /// **'Culinary Name'**
  String get culinaryName;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @totalPassengers.
  ///
  /// In en, this message translates to:
  /// **'Total Passengers'**
  String get totalPassengers;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get totalPayment;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review Submitted'**
  String get reviewSubmitted;

  /// No description provided for @giveReview.
  ///
  /// In en, this message translates to:
  /// **'Give Review'**
  String get giveReview;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @writeYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Write your experience...'**
  String get writeYourExperience;

  /// No description provided for @provideRatingAndReview.
  ///
  /// In en, this message translates to:
  /// **'Please provide your rating and review.'**
  String get provideRatingAndReview;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
