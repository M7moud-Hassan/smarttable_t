// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Table';

  @override
  String get wellcome => 'Welcome';

  @override
  String get loginDesc => 'Log in to the Smart Schedule app for teachers,';

  @override
  String get teacherLogin => 'Teacher Login';

  @override
  String get username => 'Username';

  @override
  String get passwordCode => 'Passcode';

  @override
  String get termsConditionsText =>
      'By logging in, you agree to the terms and conditions of the Smart Schedule app';

  @override
  String get login => 'Login';

  @override
  String get loginFirstTime => 'First-time login with ID code';

  @override
  String get loginFirstTimePhone => 'First-time login with phone number';

  @override
  String get forgetPassword => 'Forgot Password';

  @override
  String get signUpTitle =>
      'Username and password do not exist for the ID code';

  @override
  String get signUpDesc =>
      'Please add a username and password for your account';

  @override
  String get signUp => 'Sign Up';

  @override
  String get passwordValidationMin => 'Password must be more than 8 characters';

  @override
  String get back => 'Back';

  @override
  String get password => 'Password';

  @override
  String get passwordConfirmationValidation =>
      'Password confirmation does not match with password';

  @override
  String get passwordConfirmation => 'Password Confirmation';

  @override
  String get send => 'Send';

  @override
  String get idCode => 'ID Code';

  @override
  String get resetPasswordSucess =>
      'Password has been successfully sent to your email';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get requiredFieldValidation => 'This field is required';

  @override
  String get emailValidation =>
      'Invalid email, please enter a valid email address';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get slowInternet => 'Your internet connection seems weak';

  @override
  String get resetPasswordDesc => 'Enter your email related to your account.';

  @override
  String get sucessMessage => 'Operation has been completed successfully';

  @override
  String get errorMessage => 'Oops! Something went wrong. Please try again';

  @override
  String get email => 'Email';

  @override
  String get home => 'Home';

  @override
  String get myProfile => 'My Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get tryAgain => 'Try again';

  @override
  String get schoolSchedule => 'School Schedule';

  @override
  String get showFullSchedule => 'Show Full Schedule';

  @override
  String get today => 'Today';

  @override
  String get showFullScheduleAppBar => 'Full Table';

  @override
  String get showFullScheduleVertical => 'Full Table Vertically';

  @override
  String get settings => 'Settings';

  @override
  String get infoData => 'Informational Data';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsConditions => 'Terms and Conditions of Use';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get aboutUs => 'About Us';

  @override
  String get shareWithFrieds => 'Share the app with friends';

  @override
  String get date => 'Date';

  @override
  String get visitor => 'Visitor';

  @override
  String get class_ => 'Class';

  @override
  String get session => 'Session';

  @override
  String get case_ => 'Case';

  @override
  String get cases => 'Cases';

  @override
  String get healthStatus => 'Health Status';

  @override
  String get howToTreat => 'How to Treat';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get deleteNotification =>
      'Are you sure you want to delete the notification?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get currentFilter => 'Current';

  @override
  String get expiredFilter => 'Expired';

  @override
  String get upcomingFilter => 'Upcoming';

  @override
  String get noTasks => 'No tasks';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get motherIsAlive => 'Mother is alive';

  @override
  String get fatherIsAlive => 'Father is alive';

  @override
  String get kinshipWithStudent => 'Kinship with student';

  @override
  String get liveWithWho => 'Live with who';

  @override
  String get studentGuardian => 'Student guardian';

  @override
  String get noWaitingClasses => 'No waiting classes';

  @override
  String get noData => 'No data';

  @override
  String get show => 'Show';

  @override
  String get page => 'Page';

  @override
  String get delete => 'Delete';

  @override
  String get downloading => 'download';

  @override
  String get downloadSuccess => 'downloaded successfuly';

  @override
  String get downloadFailed => 'download failed !';

  @override
  String get downloadExisted => 'file is existed';

  @override
  String get downloadNoFile => 'There\'s no file to download';

  @override
  String get uploadFile => 'upload file';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get deleteFileConfirmation =>
      'Are you sure you want to delete the file?';

  @override
  String get waitingClass => 'Waiting Class';

  @override
  String get weeks => 'Weeks';

  @override
  String get selectWeek => 'Select Week';

  @override
  String get writeHere => 'Write Here';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get messageType => 'Message Type';

  @override
  String get logout => 'Logout';

  @override
  String get sessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get serviceNotAvailable => 'Service is not available';

  @override
  String get classTiming => 'Class Timing';

  @override
  String get classTimingToggleEnable => 'Enable Class Notifications';

  @override
  String get classTimingToggleDisable => 'Disable Class Notifications';

  @override
  String get classTimingNoTimings => 'No class timings set yet.';

  @override
  String get riminders => 'Riminders';

  @override
  String classTimingNotificationTime(Object minutes) {
    return 'Notify before class ($minutes minutes)';
  }

  @override
  String get enableClassTimingConfirmation =>
      'Are you sure you want to enable class Riminders?';

  @override
  String get editClassTiming => 'Edit Riminde Time Before Class';

  @override
  String get invalidNumberValidation => 'Please enter a valid number.';

  @override
  String get notificationTimeRangeValidation =>
      'Notification time must be between 0 and 720 minutes.';

  @override
  String get disableClassTimingConfirmation =>
      'Are you sure you want to disable class Riminders?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get enterPhoneConnectedWithAccounr =>
      'Enter Phone number connected with your account';

  @override
  String get phoneValidation =>
      'Please enter a valid phone number starting with + followed by digits';

  @override
  String get confirmDeleteAccount =>
      'Are you sure you want to delete your account? This action is permanent and cannot be undone.';

  @override
  String get signUpTitlePhone =>
      'No username and password found for the phone number';

  @override
  String get signUpTitleId => 'No username and password found for the ID code';
}
