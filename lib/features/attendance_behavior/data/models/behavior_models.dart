import 'attendance_models.dart';
import 'json_readers.dart';

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
      id: readJsonInt(json['id']),
      name: readJsonString(json['title']),
      points: readJsonInt(json['points']),
      type: BehaviorNoteType.fromApi(json['note_type']),
      iconKey: readJsonString(json['icon'], fallback: 'smile'),
      usageCount: readJsonInt(json['usage_count']),
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

class BehaviorRosterStudentData {
  const BehaviorRosterStudentData({
    required this.studentId,
    required this.name,
    required this.numberStudent,
    required this.recordId,
    required this.notes,
    required this.teacherCanModify,
    required this.additionalNotes,
    required this.totalPoints,
    required this.proceduresCount,
  });

  factory BehaviorRosterStudentData.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    final firstNote = rawNotes is List && rawNotes.isNotEmpty
        ? readJsonMap(rawNotes.first)
        : const <String, dynamic>{};
    return BehaviorRosterStudentData(
      studentId: readJsonInt(json['student_id']),
      name: readJsonString(json['name']),
      numberStudent: readJsonString(json['number_student']),
      recordId: readNullableJsonInt(json['record_id']),
      notes: readJsonList(json['notes'], BehaviorNoteModel.fromJson),
      teacherCanModify: readJsonBool(
        json['teacher_can_modify'] ?? firstNote['teacher_can_modify'],
      ),
      additionalNotes: readJsonString(json['additional_notes']),
      totalPoints: readJsonInt(json['total_points']),
      proceduresCount: readJsonInt(json['procedures_count']),
    );
  }

  final int studentId;
  final String name;
  final String numberStudent;
  final int? recordId;
  final List<BehaviorNoteModel> notes;
  final bool teacherCanModify;
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
      classId: readJsonInt(json['class_id']),
      className: readJsonString(json['class_name']),
      session: readJsonString(json['session']),
      sessionLabel: readJsonString(json['session_label']),
      date: readJsonString(json['date']),
      dateHijri: readJsonString(json['date_hijri']),
      recordedCount: readJsonInt(json['recorded_count']),
      students: readJsonList(
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

class StudentBehaviorSummary {
  const StudentBehaviorSummary({
    required this.recordsCount,
    required this.positiveCount,
    required this.negativeCount,
    required this.totalPoints,
  });

  factory StudentBehaviorSummary.fromJson(Map<String, dynamic> json) {
    return StudentBehaviorSummary(
      recordsCount: readJsonInt(json['records_count']),
      positiveCount: readJsonInt(json['positive_count']),
      negativeCount: readJsonInt(json['negative_count']),
      totalPoints: readJsonInt(json['total_points']),
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
      recordId: readNullableJsonInt(json['record_id']),
      date: readJsonString(json['date']),
      dateHijri: readJsonString(json['date_hijri']),
      dayName: readJsonString(json['day_name']),
      session: readJsonString(json['session']),
      sessionLabel: readJsonString(json['session_label']),
      startTime: readJsonString(json['start_time']),
      endTime: readJsonString(json['end_time']),
      notes: readJsonList(json['notes'], BehaviorNoteModel.fromJson),
      additionalNotes: readJsonString(json['additional_notes']),
      totalPoints: readJsonInt(json['total_points']),
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
      student: StudentBrief.fromJson(readJsonMap(json['student'])),
      period: readJsonString(json['period']),
      dateFrom: readJsonString(json['date_from']),
      dateTo: readJsonString(json['date_to']),
      summary: StudentBehaviorSummary.fromJson(readJsonMap(json['summary'])),
      entries: readJsonList(json['entries'], BehaviorHistoryEntry.fromJson),
    );
  }

  final StudentBrief student;
  final String period;
  final String dateFrom;
  final String dateTo;
  final StudentBehaviorSummary summary;
  final List<BehaviorHistoryEntry> entries;
}
