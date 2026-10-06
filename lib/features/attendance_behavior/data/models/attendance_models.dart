import 'attendance_status_models.dart';
import 'json_readers.dart';

class AttendanceNoteDraft {
  const AttendanceNoteDraft({
    required this.note,
    this.noteCode,
    this.isCustom = false,
  });

  final String note;
  final String? noteCode;
  final bool isCustom;
}

class AttendanceBehaviorStudent {
  const AttendanceBehaviorStudent({
    required this.id,
    required this.name,
    required this.className,
    required this.attendanceStatus,
    this.numberStudent = '',
    this.classId,
    this.attendanceRecordId,
    this.attendanceNote = '',
    this.behaviorRecordId,
    this.teacherCanModifyBehavior = false,
    this.behaviorNoteIds = const [],
    this.additionalBehaviorNotes = '',
    this.totalBehaviorPoints = 0,
    this.proceduresCount = 0,
  });

  final int id;
  final String name;
  final String className;
  final String numberStudent;
  final int? classId;
  final AttendanceStatus attendanceStatus;
  final int? attendanceRecordId;
  final String attendanceNote;
  final int? behaviorRecordId;
  final bool teacherCanModifyBehavior;
  final List<int> behaviorNoteIds;
  final String additionalBehaviorNotes;
  final int totalBehaviorPoints;
  final int proceduresCount;

  int? get behaviorNoteId =>
      behaviorNoteIds.isEmpty ? null : behaviorNoteIds.first;
}

class PerseveranceOption {
  const PerseveranceOption({required this.value, required this.label});

  factory PerseveranceOption.fromJson(Map<String, dynamic> json) {
    return PerseveranceOption(
      value: readJsonString(
        json['value'] ??
            json['id'] ??
            json['key'] ??
            json['code'] ??
            json['note_code'] ??
            json['attendance'],
      ),
      label: readJsonString(
        json['label'] ??
            json['name'] ??
            json['title'] ??
            json['note'] ??
            json['text'] ??
            json['attendance_label'] ??
            json['value'],
      ),
    );
  }

  final String value;
  final String label;
}

class PerseveranceClassOption {
  const PerseveranceClassOption({
    required this.id,
    required this.name,
    this.studentsCount = 0,
  });

  factory PerseveranceClassOption.fromJson(Map<String, dynamic> json) {
    final rawId = json['class_id'] ?? json['id'] ?? json['value'];
    return PerseveranceClassOption(
      id: rawId == null || rawId.toString().isEmpty ? null : readJsonInt(rawId),
      name: readJsonString(
        json['class_name'] ?? json['name'] ?? json['label'] ?? json['title'],
      ),
      studentsCount: readJsonInt(
        json['students_count'] ?? json['student_count'] ?? json['count'],
      ),
    );
  }

  final int? id;
  final String name;
  final int studentsCount;
}

class PerseveranceSessionOption {
  const PerseveranceSessionOption({
    required this.value,
    required this.label,
    this.startTime = '',
    this.endTime = '',
  });

  factory PerseveranceSessionOption.fromJson(Map<String, dynamic> json) {
    return PerseveranceSessionOption(
      value: readJsonString(
        json['value'] ?? json['session'] ?? json['id'] ?? json['number'],
      ),
      label: readJsonString(
        json['label'] ?? json['session_label'] ?? json['name'],
      ),
      startTime: readJsonString(json['start_time']),
      endTime: readJsonString(json['end_time']),
    );
  }

  final String value;
  final String label;
  final String startTime;
  final String endTime;
}

class PerseveranceFilters {
  const PerseveranceFilters({
    required this.classes,
    required this.sessions,
    required this.attendanceStates,
  });

  factory PerseveranceFilters.fromJson(Map<String, dynamic> json) {
    return PerseveranceFilters(
      classes: readJsonList(
        json['classes'],
        PerseveranceClassOption.fromJson,
      ),
      sessions: readJsonList(
        json['sessions'],
        PerseveranceSessionOption.fromJson,
      ),
      attendanceStates: readJsonList(
        json['attendance_states'],
        PerseveranceOption.fromJson,
      ),
    );
  }

  final List<PerseveranceClassOption> classes;
  final List<PerseveranceSessionOption> sessions;
  final List<PerseveranceOption> attendanceStates;

  List<PerseveranceOption> get allowedAttendanceStates {
    final seen = <AttendanceStatus>{};
    return attendanceStates.where((option) {
      final status = AttendanceStatus.tryFromApi(option.value);
      return status != null && seen.add(status);
    }).toList(growable: false);
  }
}

class AttendanceSummary {
  const AttendanceSummary({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.permission = 0,
    this.total = 0,
    this.notRecorded = 0,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      present: readJsonInt(json['present']),
      absent: readJsonInt(json['absent']),
      late: readJsonInt(json['late']),
      permission: readJsonInt(json['permission']),
      total: readJsonInt(json['total']),
      notRecorded: readJsonInt(json['not_recorded']),
    );
  }

  final int present;
  final int absent;
  final int late;
  final int permission;
  final int total;
  final int notRecorded;
}

class AttendanceRosterData {
  const AttendanceRosterData({
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.date,
    required this.dateHijri,
    required this.summary,
    required this.students,
  });

  factory AttendanceRosterData.fromJson(Map<String, dynamic> json) {
    final classId = readJsonInt(json['class_id']);
    final className = readJsonString(json['class_name']);
    return AttendanceRosterData(
      classId: classId,
      className: className,
      session: readJsonString(json['session']),
      sessionLabel: readJsonString(json['session_label']),
      date: readJsonString(json['date']),
      dateHijri: readJsonString(json['date_hijri']),
      summary: AttendanceSummary.fromJson(readJsonMap(json['summary'])),
      students: readJsonList(json['students'], (studentJson) {
        return AttendanceBehaviorStudent(
          id: readJsonInt(studentJson['student_id']),
          name: readJsonString(studentJson['name']),
          numberStudent: readJsonString(studentJson['number_student']),
          classId: classId,
          className: className,
          attendanceRecordId: readNullableJsonInt(studentJson['record_id']),
          attendanceStatus: AttendanceStatus.fromApi(studentJson['attendance']),
          attendanceNote: readJsonString(studentJson['note']),
          proceduresCount: readJsonInt(studentJson['procedures_count']),
        );
      }),
    );
  }

  final int classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String date;
  final String dateHijri;
  final AttendanceSummary summary;
  final List<AttendanceBehaviorStudent> students;
}

class StudentBrief {
  const StudentBrief({
    required this.id,
    required this.name,
    required this.numberStudent,
    required this.classId,
    required this.className,
  });

  factory StudentBrief.fromJson(Map<String, dynamic> json) => StudentBrief(
        id: readJsonInt(json['id']),
        name: readJsonString(json['name']),
        numberStudent: readJsonString(json['number_student']),
        classId: readJsonInt(json['class_id']),
        className: readJsonString(json['class_name']),
      );

  final int id;
  final String name;
  final String numberStudent;
  final int classId;
  final String className;
}
