import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Table'**
  String get appTitle;

  /// No description provided for @wellcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get wellcome;

  /// No description provided for @loginDesc.
  ///
  /// In en, this message translates to:
  /// **'Log in to the Smart Schedule app for teachers,'**
  String get loginDesc;

  /// No description provided for @teacherLogin.
  ///
  /// In en, this message translates to:
  /// **'Teacher Login'**
  String get teacherLogin;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @passwordCode.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get passwordCode;

  /// No description provided for @termsConditionsText.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to the terms and conditions of the Smart Schedule app'**
  String get termsConditionsText;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFirstTime.
  ///
  /// In en, this message translates to:
  /// **'First-time login with ID code'**
  String get loginFirstTime;

  /// No description provided for @loginFirstTimePhone.
  ///
  /// In en, this message translates to:
  /// **'First-time login with phone number'**
  String get loginFirstTimePhone;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgetPassword;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Username and password do not exist for the ID code'**
  String get signUpTitle;

  /// No description provided for @signUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Please add a username and password for your account'**
  String get signUpDesc;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @passwordValidationMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be more than 8 characters'**
  String get passwordValidationMin;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordConfirmationValidation.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation does not match with password'**
  String get passwordConfirmationValidation;

  /// No description provided for @passwordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Password Confirmation'**
  String get passwordConfirmation;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @idCode.
  ///
  /// In en, this message translates to:
  /// **'ID Code'**
  String get idCode;

  /// No description provided for @resetPasswordSucess.
  ///
  /// In en, this message translates to:
  /// **'Password has been successfully sent to your email'**
  String get resetPasswordSucess;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @requiredFieldValidation.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredFieldValidation;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Invalid email, please enter a valid email address'**
  String get emailValidation;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @slowInternet.
  ///
  /// In en, this message translates to:
  /// **'Your internet connection seems weak'**
  String get slowInternet;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email related to your account.'**
  String get resetPasswordDesc;

  /// No description provided for @sucessMessage.
  ///
  /// In en, this message translates to:
  /// **'Operation has been completed successfully'**
  String get sucessMessage;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong. Please try again'**
  String get errorMessage;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @schoolSchedule.
  ///
  /// In en, this message translates to:
  /// **'School Schedule'**
  String get schoolSchedule;

  /// No description provided for @showFullSchedule.
  ///
  /// In en, this message translates to:
  /// **'Show Full Schedule'**
  String get showFullSchedule;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @showFullScheduleAppBar.
  ///
  /// In en, this message translates to:
  /// **'Full Table'**
  String get showFullScheduleAppBar;

  /// No description provided for @showFullScheduleVertical.
  ///
  /// In en, this message translates to:
  /// **'Full Table Vertically'**
  String get showFullScheduleVertical;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @infoData.
  ///
  /// In en, this message translates to:
  /// **'Informational Data'**
  String get infoData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions of Use'**
  String get termsConditions;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @shareWithFrieds.
  ///
  /// In en, this message translates to:
  /// **'Share the app with friends'**
  String get shareWithFrieds;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @visitor.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get visitor;

  /// No description provided for @class_.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get class_;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @case_.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get case_;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatus;

  /// No description provided for @howToTreat.
  ///
  /// In en, this message translates to:
  /// **'How to Treat'**
  String get howToTreat;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the notification?'**
  String get deleteNotification;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @currentFilter.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentFilter;

  /// No description provided for @expiredFilter.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredFilter;

  /// No description provided for @upcomingFilter.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingFilter;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @motherIsAlive.
  ///
  /// In en, this message translates to:
  /// **'Mother is alive'**
  String get motherIsAlive;

  /// No description provided for @fatherIsAlive.
  ///
  /// In en, this message translates to:
  /// **'Father is alive'**
  String get fatherIsAlive;

  /// No description provided for @kinshipWithStudent.
  ///
  /// In en, this message translates to:
  /// **'Kinship with student'**
  String get kinshipWithStudent;

  /// No description provided for @liveWithWho.
  ///
  /// In en, this message translates to:
  /// **'Live with who'**
  String get liveWithWho;

  /// No description provided for @studentGuardian.
  ///
  /// In en, this message translates to:
  /// **'Student guardian'**
  String get studentGuardian;

  /// No description provided for @noWaitingClasses.
  ///
  /// In en, this message translates to:
  /// **'No waiting classes'**
  String get noWaitingClasses;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'download'**
  String get downloading;

  /// No description provided for @downloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'downloaded successfuly'**
  String get downloadSuccess;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'download failed !'**
  String get downloadFailed;

  /// No description provided for @downloadExisted.
  ///
  /// In en, this message translates to:
  /// **'file is existed'**
  String get downloadExisted;

  /// No description provided for @downloadNoFile.
  ///
  /// In en, this message translates to:
  /// **'There\'s no file to download'**
  String get downloadNoFile;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'upload file'**
  String get uploadFile;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @deleteFileConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the file?'**
  String get deleteFileConfirmation;

  /// No description provided for @waitingClass.
  ///
  /// In en, this message translates to:
  /// **'Waiting Class'**
  String get waitingClass;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @selectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select Week'**
  String get selectWeek;

  /// No description provided for @writeHere.
  ///
  /// In en, this message translates to:
  /// **'Write Here'**
  String get writeHere;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @messageType.
  ///
  /// In en, this message translates to:
  /// **'Message Type'**
  String get messageType;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @serviceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Service is not available'**
  String get serviceNotAvailable;

  /// No description provided for @classTiming.
  ///
  /// In en, this message translates to:
  /// **'Class Timing'**
  String get classTiming;

  /// No description provided for @classTimingToggleEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Class Notifications'**
  String get classTimingToggleEnable;

  /// No description provided for @classTimingToggleDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable Class Notifications'**
  String get classTimingToggleDisable;

  /// No description provided for @classTimingNoTimings.
  ///
  /// In en, this message translates to:
  /// **'No class timings set yet.'**
  String get classTimingNoTimings;

  /// No description provided for @riminders.
  ///
  /// In en, this message translates to:
  /// **'Riminders'**
  String get riminders;

  /// No description provided for @classTimingNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notify before class ({minutes} minutes)'**
  String classTimingNotificationTime(Object minutes);

  /// No description provided for @enableClassTimingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to enable class Riminders?'**
  String get enableClassTimingConfirmation;

  /// No description provided for @editClassTiming.
  ///
  /// In en, this message translates to:
  /// **'Edit Riminde Time Before Class'**
  String get editClassTiming;

  /// No description provided for @invalidNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get invalidNumberValidation;

  /// No description provided for @notificationTimeRangeValidation.
  ///
  /// In en, this message translates to:
  /// **'Notification time must be between 0 and 720 minutes.'**
  String get notificationTimeRangeValidation;

  /// No description provided for @disableClassTimingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable class Riminders?'**
  String get disableClassTimingConfirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @enterPhoneConnectedWithAccounr.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone number connected with your account'**
  String get enterPhoneConnectedWithAccounr;

  /// No description provided for @phoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number starting with + followed by digits'**
  String get phoneValidation;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone.'**
  String get confirmDeleteAccount;

  /// No description provided for @signUpTitlePhone.
  ///
  /// In en, this message translates to:
  /// **'No username and password found for the phone number'**
  String get signUpTitlePhone;

  /// No description provided for @signUpTitleId.
  ///
  /// In en, this message translates to:
  /// **'No username and password found for the ID code'**
  String get signUpTitleId;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
