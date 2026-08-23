enum AttendanceStatus {
  present('s'),
  absent('a'),
  late('l'),
  excused('p'),
  notRecorded('');

  const AttendanceStatus(this.apiValue);

  final String apiValue;

  static AttendanceStatus fromApi(dynamic value) => switch (value?.toString()) {
        's' => AttendanceStatus.present,
        'a' => AttendanceStatus.absent,
        'l' => AttendanceStatus.late,
        'p' => AttendanceStatus.excused,
        _ => AttendanceStatus.notRecorded,
      };
}

extension AttendanceStatusLabel on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.present => 'حاضر',
        AttendanceStatus.absent => 'غائب',
        AttendanceStatus.late => 'متأخر',
        AttendanceStatus.excused => 'مستأذن',
        AttendanceStatus.notRecorded => 'غير مسجل',
      };
}

enum BehaviorNoteType {
  positive('positive'),
  needsImprovement('negative');

  const BehaviorNoteType(this.apiValue);

  final String apiValue;

  static BehaviorNoteType fromApi(dynamic value) =>
      value?.toString() == 'positive'
          ? BehaviorNoteType.positive
          : BehaviorNoteType.needsImprovement;
}

extension BehaviorNoteTypeLabel on BehaviorNoteType {
  String get label => switch (this) {
        BehaviorNoteType.positive => 'إيجابي',
        BehaviorNoteType.needsImprovement => 'بحاجة إلى تحسين',
      };
}

class BehaviorNoteModel {
  const BehaviorNoteModel({
    required this.id,
    required this.name,
    required this.points,
    required this.type,
    required this.iconKey,
    this.usageCount = 0,
  });

  factory BehaviorNoteModel.fromJson(Map<String, dynamic> json) {
    return BehaviorNoteModel(
      id: _asInt(json['id']),
      name: _asString(json['title']),
      points: _asInt(json['points']),
      type: BehaviorNoteType.fromApi(json['note_type']),
      iconKey: _asString(json['icon'], fallback: 'smile'),
      usageCount: _asInt(json['usage_count']),
    );
  }

  final int id;
  final String name;
  final int points;
  final BehaviorNoteType type;
  final String iconKey;
  final int usageCount;

  Map<String, dynamic> toWriteJson() => {
        'title': name,
        'points': points,
        'note_type': type.apiValue,
        if (iconKey.isNotEmpty) 'icon': iconKey,
      };

  BehaviorNoteModel copyWith({
    String? name,
    int? points,
    BehaviorNoteType? type,
    String? iconKey,
    int? usageCount,
  }) {
    return BehaviorNoteModel(
      id: id,
      name: name ?? this.name,
      points: points ?? this.points,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      usageCount: usageCount ?? this.usageCount,
    );
  }
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
      value: _asString(
        json['value'] ??
            json['id'] ??
            json['key'] ??
            json['code'] ??
            json['attendance'],
      ),
      label: _asString(
        json['label'] ??
            json['name'] ??
            json['title'] ??
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
      id: rawId == null || rawId.toString().isEmpty ? null : _asInt(rawId),
      name: _asString(
        json['class_name'] ?? json['name'] ?? json['label'] ?? json['title'],
      ),
      studentsCount: _asInt(
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
      value: _asString(
        json['value'] ?? json['session'] ?? json['id'] ?? json['number'],
      ),
      label: _asString(
        json['label'] ?? json['session_label'] ?? json['name'],
      ),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
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
      classes: _mapList(
        json['classes'],
        PerseveranceClassOption.fromJson,
      ),
      sessions: _mapList(
        json['sessions'],
        PerseveranceSessionOption.fromJson,
      ),
      attendanceStates: _mapList(
        json['attendance_states'],
        PerseveranceOption.fromJson,
      ),
    );
  }

  final List<PerseveranceClassOption> classes;
  final List<PerseveranceSessionOption> sessions;
  final List<PerseveranceOption> attendanceStates;
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
      present: _asInt(json['present']),
      absent: _asInt(json['absent']),
      late: _asInt(json['late']),
      permission: _asInt(json['permission']),
      total: _asInt(json['total']),
      notRecorded: _asInt(json['not_recorded']),
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
    final classId = _asInt(json['class_id']);
    final className = _asString(json['class_name']);
    return AttendanceRosterData(
      classId: classId,
      className: className,
      session: _asString(json['session']),
      sessionLabel: _asString(json['session_label']),
      date: _asString(json['date']),
      dateHijri: _asString(json['date_hijri']),
      summary: AttendanceSummary.fromJson(_asMap(json['summary'])),
      students: _mapList(json['students'], (studentJson) {
        return AttendanceBehaviorStudent(
          id: _asInt(studentJson['student_id']),
          name: _asString(studentJson['name']),
          numberStudent: _asString(studentJson['number_student']),
          classId: classId,
          className: className,
          attendanceRecordId: _asNullableInt(studentJson['record_id']),
          attendanceStatus: AttendanceStatus.fromApi(studentJson['attendance']),
          attendanceNote: _asString(studentJson['note']),
          proceduresCount: _asInt(studentJson['procedures_count']),
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

class BehaviorRosterStudentData {
  const BehaviorRosterStudentData({
    required this.studentId,
    required this.name,
    required this.numberStudent,
    required this.recordId,
    required this.notes,
    required this.additionalNotes,
    required this.totalPoints,
    required this.proceduresCount,
  });

  factory BehaviorRosterStudentData.fromJson(Map<String, dynamic> json) {
    return BehaviorRosterStudentData(
      studentId: _asInt(json['student_id']),
      name: _asString(json['name']),
      numberStudent: _asString(json['number_student']),
      recordId: _asNullableInt(json['record_id']),
      notes: _mapList(json['notes'], BehaviorNoteModel.fromJson),
      additionalNotes: _asString(json['additional_notes']),
      totalPoints: _asInt(json['total_points']),
      proceduresCount: _asInt(json['procedures_count']),
    );
  }

  final int studentId;
  final String name;
  final String numberStudent;
  final int? recordId;
  final List<BehaviorNoteModel> notes;
  final String additionalNotes;
  final int totalPoints;
  final int proceduresCount;
}

class BehaviorRosterData {
  const BehaviorRosterData({
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.date,
    required this.dateHijri,
    required this.recordedCount,
    required this.students,
  });

  factory BehaviorRosterData.fromJson(Map<String, dynamic> json) {
    return BehaviorRosterData(
      classId: _asInt(json['class_id']),
      className: _asString(json['class_name']),
      session: _asString(json['session']),
      sessionLabel: _asString(json['session_label']),
      date: _asString(json['date']),
      dateHijri: _asString(json['date_hijri']),
      recordedCount: _asInt(json['recorded_count']),
      students: _mapList(
        json['students'],
        BehaviorRosterStudentData.fromJson,
      ),
    );
  }

  final int classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String date;
  final String dateHijri;
  final int recordedCount;
  final List<BehaviorRosterStudentData> students;
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
        id: _asInt(json['id']),
        name: _asString(json['name']),
        numberStudent: _asString(json['number_student']),
        classId: _asInt(json['class_id']),
        className: _asString(json['class_name']),
      );

  final int id;
  final String name;
  final String numberStudent;
  final int classId;
  final String className;
}

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
      presentDays: _asInt(json['present_days']),
      absentDays: _asInt(json['absent_days']),
      lateDays: _asInt(json['late_days']),
      permissionDays: _asInt(json['permission_days']),
      totalDays: _asInt(json['total_days']),
      presentPercentage: _asDouble(json['present_percentage']),
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
      recordId: _asNullableInt(json['record_id']),
      date: _asString(json['date']),
      dateHijri: _asString(json['date_hijri']),
      dayName: _asString(json['day_name']),
      session: _asString(json['session']),
      sessionLabel: _asString(json['session_label']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      courseName: _asString(json['course_name']),
      status: AttendanceStatus.fromApi(json['attendance']),
      note: _asString(json['note']),
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
      student: StudentBrief.fromJson(_asMap(json['student'])),
      period: _asString(json['period']),
      dateFrom: _asString(json['date_from']),
      dateTo: _asString(json['date_to']),
      summary: StudentAttendanceSummary.fromJson(_asMap(json['summary'])),
      entries: _mapList(json['entries'], AttendanceHistoryEntry.fromJson),
    );
  }

  final StudentBrief student;
  final String period;
  final String dateFrom;
  final String dateTo;
  final StudentAttendanceSummary summary;
  final List<AttendanceHistoryEntry> entries;
}

class StudentBehaviorSummary {
  const StudentBehaviorSummary({
    required this.recordsCount,
    required this.positiveCount,
    required this.negativeCount,
    required this.totalPoints,
  });

  factory StudentBehaviorSummary.fromJson(Map<String, dynamic> json) {
    return StudentBehaviorSummary(
      recordsCount: _asInt(json['records_count']),
      positiveCount: _asInt(json['positive_count']),
      negativeCount: _asInt(json['negative_count']),
      totalPoints: _asInt(json['total_points']),
    );
  }

  final int recordsCount;
  final int positiveCount;
  final int negativeCount;
  final int totalPoints;
}

class BehaviorHistoryEntry {
  const BehaviorHistoryEntry({
    required this.recordId,
    required this.date,
    required this.dateHijri,
    required this.dayName,
    required this.session,
    required this.sessionLabel,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.additionalNotes,
    required this.totalPoints,
  });

  factory BehaviorHistoryEntry.fromJson(Map<String, dynamic> json) {
    return BehaviorHistoryEntry(
      recordId: _asNullableInt(json['record_id']),
      date: _asString(json['date']),
      dateHijri: _asString(json['date_hijri']),
      dayName: _asString(json['day_name']),
      session: _asString(json['session']),
      sessionLabel: _asString(json['session_label']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      notes: _mapList(json['notes'], BehaviorNoteModel.fromJson),
      additionalNotes: _asString(json['additional_notes']),
      totalPoints: _asInt(json['total_points']),
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
  final List<BehaviorNoteModel> notes;
  final String additionalNotes;
  final int totalPoints;
}

class StudentBehaviorHistory {
  const StudentBehaviorHistory({
    required this.student,
    required this.period,
    required this.dateFrom,
    required this.dateTo,
    required this.summary,
    required this.entries,
  });

  factory StudentBehaviorHistory.fromJson(Map<String, dynamic> json) {
    return StudentBehaviorHistory(
      student: StudentBrief.fromJson(_asMap(json['student'])),
      period: _asString(json['period']),
      dateFrom: _asString(json['date_from']),
      dateTo: _asString(json['date_to']),
      summary: StudentBehaviorSummary.fromJson(_asMap(json['summary'])),
      entries: _mapList(json['entries'], BehaviorHistoryEntry.fromJson),
    );
  }

  final StudentBrief student;
  final String period;
  final String dateFrom;
  final String dateTo;
  final StudentBehaviorSummary summary;
  final List<BehaviorHistoryEntry> entries;
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
      id: _asInt(json['id']),
      studentId: _asInt(json['student']),
      title: _asString(
        json['procedure_type_label'] ?? json['procedure_type'],
      ),
      reason: _asString(json['reason']),
      date: _asString(json['date']),
      dateHijri: _asString(json['date_hijri']),
      source: _asString(json['source']),
      sourceLabel: _asString(json['source_label']),
      sessionLabel: _asString(json['session_label']),
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

class ReportQuery {
  const ReportQuery({
    this.classId,
    this.period = 'month',
    this.dateFrom,
    this.dateTo,
  });

  final int? classId;
  final String period;
  final String? dateFrom;
  final String? dateTo;

  Map<String, dynamic> toParameters({bool includeStudents = false}) => {
        if (classId != null) 'class_id': classId,
        'period': period,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (includeStudents) 'include_students': true,
      };

  @override
  bool operator ==(Object other) =>
      other is ReportQuery &&
      classId == other.classId &&
      period == other.period &&
      dateFrom == other.dateFrom &&
      dateTo == other.dateTo;

  @override
  int get hashCode => Object.hash(classId, period, dateFrom, dateTo);
}

class AttendanceReportSummary {
  const AttendanceReportSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.permission,
    required this.total,
    required this.presentPercentage,
    required this.absentPercentage,
    required this.latePercentage,
  });

  factory AttendanceReportSummary.fromJson(Map<String, dynamic> json) {
    final percentages = _asMap(json['percentages']);
    final present = _asInt(json['present']);
    final absent = _asInt(json['absent']);
    final late = _asInt(json['late']);
    final permission = _asInt(json['permission']);
    final total = _asInt(
      json['total'] ?? json['recorded_total'] ?? json['total_records'],
      fallback: present + absent + late + permission,
    );
    double percentage(String key, int count) {
      final explicit = json['${key}_percentage'] ?? percentages[key];
      return explicit == null
          ? (total == 0 ? 0 : count * 100 / total)
          : _asDouble(explicit);
    }

    return AttendanceReportSummary(
      present: present,
      absent: absent,
      late: late,
      permission: permission,
      total: total,
      presentPercentage: percentage('present', present),
      absentPercentage: percentage('absent', absent),
      latePercentage: percentage('late', late),
    );
  }

  final int present;
  final int absent;
  final int late;
  final int permission;
  final int total;
  final double presentPercentage;
  final double absentPercentage;
  final double latePercentage;
}

class AttendanceClassReport {
  const AttendanceClassReport({
    required this.classId,
    required this.className,
    required this.summary,
  });

  factory AttendanceClassReport.fromJson(Map<String, dynamic> json) {
    final summary =
        _asMap(json['summary']).isEmpty ? json : _asMap(json['summary']);
    return AttendanceClassReport(
      classId: _asInt(json['class_id'] ?? json['id']),
      className: _asString(
        json['class_name'] ?? json['name'] ?? json['label'],
      ),
      summary: AttendanceReportSummary.fromJson(summary),
    );
  }

  final int classId;
  final String className;
  final AttendanceReportSummary summary;
}

class AttendanceReportData {
  const AttendanceReportData({required this.overall, required this.classes});

  factory AttendanceReportData.fromJson(Map<String, dynamic> json) {
    final overall = _asMap(json['overall']).isEmpty
        ? _asMap(json['summary'])
        : _asMap(json['overall']);
    return AttendanceReportData(
      overall: AttendanceReportSummary.fromJson(overall),
      classes: _mapList(json['classes'], AttendanceClassReport.fromJson),
    );
  }

  final AttendanceReportSummary overall;
  final List<AttendanceClassReport> classes;
}

class BehaviorClassReport {
  const BehaviorClassReport({
    required this.classId,
    required this.className,
    required this.excellent,
    required this.veryGood,
    required this.good,
    required this.acceptable,
    required this.weak,
  });

  factory BehaviorClassReport.fromJson(Map<String, dynamic> json) {
    final counts = _asMap(json['bands']).isEmpty
        ? (_asMap(json['summary']).isEmpty ? json : _asMap(json['summary']))
        : _asMap(json['bands']);
    return BehaviorClassReport(
      classId: _asInt(json['class_id'] ?? json['id']),
      className: _asString(
        json['class_name'] ?? json['name'] ?? json['label'],
      ),
      excellent: _asInt(counts['excellent'] ?? counts['excellent_count']),
      veryGood: _asInt(counts['very_good'] ?? counts['very_good_count']),
      good: _asInt(counts['good'] ?? counts['good_count']),
      acceptable: _asInt(counts['acceptable'] ?? counts['acceptable_count']),
      weak: _asInt(counts['weak'] ?? counts['weak_count']),
    );
  }

  final int classId;
  final String className;
  final int excellent;
  final int veryGood;
  final int good;
  final int acceptable;
  final int weak;

  int get total => excellent + veryGood + good + acceptable + weak;
}

class BehaviorReportData {
  const BehaviorReportData({required this.classes});

  factory BehaviorReportData.fromJson(Map<String, dynamic> json) {
    return BehaviorReportData(
      classes: _mapList(json['classes'], BehaviorClassReport.fromJson),
    );
  }

  final List<BehaviorClassReport> classes;
}

class ReportOptions {
  const ReportOptions({
    required this.reportTypes,
    required this.periods,
    required this.classes,
    required this.formats,
  });

  factory ReportOptions.fromJson(Map<String, dynamic> json) {
    return ReportOptions(
      reportTypes: _mapList(
        json['report_types'] ?? json['types'],
        PerseveranceOption.fromJson,
      ),
      periods: _mapList(json['periods'], PerseveranceOption.fromJson),
      classes: _mapList(
        json['classes'],
        PerseveranceClassOption.fromJson,
      ),
      formats: _mapList(
        json['formats'] ?? json['file_formats'],
        PerseveranceOption.fromJson,
      ),
    );
  }

  final List<PerseveranceOption> reportTypes;
  final List<PerseveranceOption> periods;
  final List<PerseveranceClassOption> classes;
  final List<PerseveranceOption> formats;
}

class PerseveranceExportFile {
  const PerseveranceExportFile({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<T> _mapList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) mapper,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final result = value.toString();
  return result.isEmpty ? fallback : result;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return _asInt(value);
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
