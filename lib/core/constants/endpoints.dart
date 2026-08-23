import 'package:flutter/foundation.dart';

class Endpoints {
  static const String baseUrl =
      kDebugMode ? 'https://test.smartble.net/' : 'https://test.smartble.net/';

  static const String login = 'teacher-mobile/v2/auth/login/';
  static const String logout = 'teacher-mobile/v2/auth/logout/';
  static const String register = 'teacher-mobile/v2/auth/register/';
  static const String registerByPhone = 'teacher-mobile/v2/register-by-phone/';
  static const String checkPhone = 'teacher-mobile/v2/check-phone/';
  static const String verifyPhone = 'teacher-mobile/v2/verify-phone-code/';
  static const String resetPassword = 'teacher-mobile/v2/auth/reset-password/';
  static const String updateFcmToken =
      'teacher-mobile/v2/auth/update-fcm-token/';
  static const String deleteMyAccount =
      'teacher-mobile/v2/auth/delete-my-account/';
  static const String homeMenus = 'teacher-mobile/v2/app_features/menus/';
  static const String masterTable = 'teacher-mobile/v2/master-table/';
  static const String teacherTable = 'teacher-mobile/v2/teacher-table/';
  static const String waitingClasses = 'teacher-mobile/v2/waiting-classes/';
  static String secureClassSubstitutes(int cellNumber) =>
      'teacher-mobile/v2/secure-class/lessons/$cellNumber/substitutes/';
  static const String secureClassRequests =
      'teacher-mobile/v2/secure-class/requests/';
  static String secureClassRequest(int requestId) =>
      'teacher-mobile/v2/secure-class/requests/$requestId/';
  static const String days = 'teacher-mobile/v2/days/';
  static const String notifications = 'teacher-mobile/v2/notifications/';
  static const String deleteNotifications =
      'teacher-mobile/v2/delete-notification/';
  static const String teacherNotes = 'teacher-mobile/v2/followers/notes/';
  static const String profile = 'teacher-mobile/v2/auth/me/';
  static const String profilePhoto = 'teacher-mobile/v2/photo/';
  static const String deleteProfilePhoto = 'teacher-mobile/v2/photo/delete/';
  static const String getProfilePhoto = 'teacher-mobile/v2/photo/me/';
  static const String signature = 'teacher-mobile/v2/signature/';
  static const String deleteSignature = 'teacher-mobile/v2/signature/delete/';
  static const String getSignature = 'teacher-mobile/v2/signature/me/';
  static const String circulars = 'teacher-mobile/v2/followers/circulars/';
  static const String classVisits = 'teacher-mobile/v2/followers/class-visits/';
  static const String healthCases =
      'teacher-mobile/v2/followers/health-conditions/';
  static const String dutyRoster = 'teacher-mobile/v2/duty-roster/';
  static const String socialCases =
      'teacher-mobile/v2/followers/social-status/';
  static const String aboutUs =
      'https://www.smartble.net/api/about-page-content/';
  static const String weekPlan = 'teacher-mobile/v2/followers/week-plan/';
  static const String weekInfo = 'teacher-mobile/v2/followers/week-info/';
  static const String contactUs = 'teacher-mobile/v2/contact-us/';
  static const String examHalls = 'teacher-mobile/v2/exam-hall-groups/';
  static const String classTiming = 'teacher-mobile/v2/classes-timing/';
  static const String performanceEvidence = 'api/notes/evidence/';
  static const String performanceEvidenceCategories =
      'api/notes/evidence-categories/';
  static const String wishes = 'teacher-mobile/v2/wishes/';
  static const String wishClassrooms = 'teacher-mobile/v2/wishes/classrooms/';
  static String wishClassroomCourses(int classroomId) =>
      'teacher-mobile/v2/wishes/classrooms/$classroomId/courses/';
  static String wish(int wishId) => 'teacher-mobile/v2/wishes/$wishId/';
  static const String administrativeProcedures =
      'teacher-mobile/v2/followers/administrative-procedures/';
  static String administrativeProcedure(String procedureType, int id) =>
      'teacher-mobile/v2/followers/administrative-procedures/'
      '$procedureType/$id/';

  static const String perseveranceAttendance =
      'teacher-mobile/v2/perseverance/attendance/';
  static String perseveranceStudentAttendance(int studentId) =>
      'teacher-mobile/v2/perseverance/attendance/students/$studentId/';
  static const String perseveranceBehavior =
      'teacher-mobile/v2/perseverance/behavior/';
  static const String perseveranceBehaviorNotes =
      'teacher-mobile/v2/perseverance/behavior/notes/';
  static String perseveranceBehaviorNote(int noteId) =>
      'teacher-mobile/v2/perseverance/behavior/notes/$noteId/';
  static String perseveranceStudentBehavior(int studentId) =>
      'teacher-mobile/v2/perseverance/behavior/students/$studentId/';
  static const String perseveranceFilters =
      'teacher-mobile/v2/perseverance/filters/';
  static const String perseveranceProcedures =
      'teacher-mobile/v2/perseverance/procedures/';
  static const String perseveranceProcedureTypes =
      'teacher-mobile/v2/perseverance/procedures/types/';
  static const String perseveranceAttendanceReport =
      'teacher-mobile/v2/perseverance/reports/attendance/';
  static const String perseveranceBehaviorReport =
      'teacher-mobile/v2/perseverance/reports/behavior/';
  static const String perseveranceReportExport =
      'teacher-mobile/v2/perseverance/reports/export/';
  static const String perseveranceReportOptions =
      'teacher-mobile/v2/perseverance/reports/options/';
}
