import 'attendance_models.dart';
import 'attendance_status_models.dart';
import 'json_readers.dart';

class StudentAttendanceSummary {
  const StudentAttendanceSummary({
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.permissionDays,
    required this.totalDays,
    required this.presentPercentage,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      presentDays: readJsonInt(json['present_days']),
      absentDays: readJsonInt(json['absent_days']),
      lateDays: readJsonInt(json['late_days']),
      permissionDays: readJsonInt(json['permission_days']),
      totalDays: readJsonInt(json['total_days']),
      presentPercentage: readJsonDouble(json['present_percentage']),
    );
  }

  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int permissionDays;
  final int totalDays;
  final double presentPercentage;
}

class AttendanceHistoryEntry {
  const AttendanceHistoryEntry({
    required this.recordId,
    required this.date,
    required this.dateHijri,
    required this.dayName,
    required this.session,
    required this.sessionLabel,
    required this.startTime,
    required this.endTime,
    required this.courseName,
    required this.status,
    required this.note,
  });

  factory AttendanceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryEntry(
      recordId: readNullableJsonInt(json['record_id']),
      date: readJsonString(json['date']),
      dateHijri: readJsonString(json['date_hijri']),
      dayName: readJsonString(json['day_name']),
      session: readJsonString(json['session']),
      sessionLabel: readJsonString(json['session_label']),
      startTime: readJsonString(json['start_time']),
      endTime: readJsonString(json['end_time']),
      courseName: readJsonString(json['course_name']),
      status: AttendanceStatus.fromApi(json['attendance']),
      note: readJsonString(json['note']),
    );
  }

  final int? recordId;
  final String date;
  final String dateHijri;
  final String dayName;
  final String session;
  final String sessionLabel;
  final String startTime;
  final String endTime;
  final String courseName;
  final AttendanceStatus status;
  final String note;
}

class StudentAttendanceHistory {
  const StudentAttendanceHistory({
    required this.student,
    required this.period,
    required this.dateFrom,
    required this.dateTo,
    required this.summary,
    required this.entries,
  });

  factory StudentAttendanceHistory.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceHistory(
      student: StudentBrief.fromJson(readJsonMap(json['student'])),
      period: readJsonString(json['period']),
      dateFrom: readJsonString(json['date_from']),
      dateTo: readJsonString(json['date_to']),
      summary: StudentAttendanceSummary.fromJson(readJsonMap(json['summary'])),
      entries: readJsonList(json['entries'], AttendanceHistoryEntry.fromJson),
    );
  }

  final StudentBrief student;
  final String period;
  final String dateFrom;
  final String dateTo;
  final StudentAttendanceSummary summary;
  final List<AttendanceHistoryEntry> entries;
}

class StudentProcedureModel {
  const StudentProcedureModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.reason,
    required this.date,
    required this.dateHijri,
    required this.source,
    required this.sourceLabel,
    required this.sessionLabel,
  });

  factory StudentProcedureModel.fromJson(Map<String, dynamic> json) {
    return StudentProcedureModel(
      id: readJsonInt(json['id']),
      studentId: readJsonInt(json['student']),
      title: readJsonString(
        json['procedure_type_label'] ?? json['procedure_type'],
      ),
      reason: readJsonString(json['reason']),
      date: readJsonString(json['date']),
      dateHijri: readJsonString(json['date_hijri']),
      source: readJsonString(json['source']),
      sourceLabel: readJsonString(json['source_label']),
      sessionLabel: readJsonString(json['session_label']),
    );
  }

  final int id;
  final int studentId;
  final String title;
  final String reason;
  final String date;
  final String dateHijri;
  final String source;
  final String sourceLabel;
  final String sessionLabel;
}
