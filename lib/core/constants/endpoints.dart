import 'package:flutter/foundation.dart';

class Endpoints {
  static const String baseUrl = kDebugMode
      ? 'https://www.smartble.net/teacher-mobile/v2/'
      : 'https://www.smartble.net/teacher-mobile/v2/';

  static const String login = 'auth/login/';
  static const String logout = 'auth/logout/';
  static const String register = 'auth/register/';
  static const String registerByPhone = 'register-by-phone/';
  static const String checkPhone = 'check-phone/';
  static const String resetPassword = 'auth/reset-password/';
  static const String updateFcmToken = 'auth/update-fcm-token/';
  static const String deleteMyAccount = 'auth/delete-my-account/';
  static const String homeMenus = 'app_features/menus/';
  static const String masterTable = 'master-table/';
  static const String teacherTable = 'teacher-table/';
  static const String waitingClasses = 'waiting-classes/';
  static const String days = 'days/';
  static const String notifications = 'notifications/';
  static const String deleteNotifications = 'delete-notification/';
  static const String teacherNotes = 'followers/notes/';
  static const String profile = 'auth/me/';
  static const String circulars = 'followers/circulars/';
  static const String classVisits = 'followers/class-visits/';
  static const String healthCases = 'followers/health-conditions/';
  static const String dailyTasks = 'daily-tasks/';
  static const String socialCases = 'followers/social-status/';
  static const String aboutUs =
      'https://www.smartble.net/api/about-page-content/';
  static const String weekPlan = 'followers/week-plan/';
  static const String weekInfo = 'followers/week-info/';
  static const String contactUs = 'contact-us/';
  static const String examHalls = 'exam-hall-groups/';
  static const String classTiming = 'classes-timing/';
}
