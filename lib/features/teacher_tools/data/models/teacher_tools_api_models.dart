import 'teacher_tools_ui_models.dart';

class PresentStudentsData {
  const PresentStudentsData({
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.date,
    required this.dateHijri,
    required this.students,
  });

  factory PresentStudentsData.fromJson(Map<String, dynamic> json) {
    return PresentStudentsData(
      classId: readInt(json['class_id']),
      className: readString(json['class_name']),
      session: readString(json['session']),
      sessionLabel: readString(json['session_label']),
      date: readString(json['date']),
      dateHijri: readString(json['date_hijri']),
      students: readMapList(json['students'])
          .map(TeacherToolStudent.fromJson)
          .toList(growable: false),
    );
  }

  final int classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String date;
  final String dateHijri;
  final List<TeacherToolStudent> students;
}

enum QuickQuestionRating {
  understood('u'),
  partial('p'),
  notUnderstood('n');

  const QuickQuestionRating(this.apiValue);

  final String apiValue;

  static QuickQuestionRating? tryFromApi(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'u' || 'understood' || 'understand' => QuickQuestionRating.understood,
      'p' || 'partial' || 'partially_understood' => QuickQuestionRating.partial,
      'n' ||
      'not_understood' ||
      'not-understood' =>
        QuickQuestionRating.notUnderstood,
      _ => null,
    };
  }
}

class QuickQuestionStudent {
  const QuickQuestionStudent({
    required this.student,
    this.rating,
  });

  factory QuickQuestionStudent.fromJson(Map<String, dynamic> json) {
    return QuickQuestionStudent(
      student: TeacherToolStudent.fromJson(json),
      rating: QuickQuestionRating.tryFromApi(json['rating']),
    );
  }

  final TeacherToolStudent student;
  final QuickQuestionRating? rating;
}

class QuickQuestionData {
  const QuickQuestionData({
    required this.id,
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.date,
    required this.dateHijri,
    required this.question,
    required this.note,
    required this.understoodCount,
    required this.partialCount,
    required this.notUnderstoodCount,
    required this.students,
    this.updatedAt,
  });

  factory QuickQuestionData.fromJson(Map<String, dynamic> json) {
    return QuickQuestionData(
      id: readInt(json['id']),
      classId: readInt(json['class_id']),
      className: readString(json['class_name']),
      session: readString(json['session']),
      sessionLabel: readString(json['session_label']),
      date: readString(json['date']),
      dateHijri: readString(json['date_hijri']),
      question: readString(json['question']),
      note: readString(json['note']),
      understoodCount: readInt(json['understood_count']),
      partialCount: readInt(json['partial_count']),
      notUnderstoodCount: readInt(json['not_understood_count']),
      updatedAt: DateTime.tryParse(readString(json['updated_at'])),
      students: readMapList(json['students'])
          .map(QuickQuestionStudent.fromJson)
          .toList(growable: false),
    );
  }

  final int id;
  final int classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String date;
  final String dateHijri;
  final String question;
  final String note;
  final int understoodCount;
  final int partialCount;
  final int notUnderstoodCount;
  final List<QuickQuestionStudent> students;
  final DateTime? updatedAt;
}

class RandomPickResult {
  const RandomPickResult({
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.date,
    required this.dateHijri,
    required this.cycleReset,
    required this.picked,
    required this.alreadyPickedToday,
  });

  factory RandomPickResult.fromJson(Map<String, dynamic> json) {
    return RandomPickResult(
      classId: readInt(json['class_id']),
      className: readString(json['class_name']),
      session: readString(json['session']),
      sessionLabel: readString(json['session_label']),
      date: readString(json['date']),
      dateHijri: readString(json['date_hijri']),
      cycleReset: readBool(json['cycle_reset']),
      picked: readMapList(json['picked'])
          .map(TeacherToolStudent.fromJson)
          .toList(growable: false),
      alreadyPickedToday: readMapList(json['already_picked_today'])
          .map(TeacherToolStudent.fromJson)
          .toList(growable: false),
    );
  }

  final int classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String date;
  final String dateHijri;
  final bool cycleReset;
  final List<TeacherToolStudent> picked;
  final List<TeacherToolStudent> alreadyPickedToday;
}

class SeatAssignment {
  const SeatAssignment({
    required this.student,
    required this.row,
    required this.col,
  });

  factory SeatAssignment.fromJson(Map<String, dynamic> json) {
    return SeatAssignment(
      student: TeacherToolStudent.fromJson(json),
      row: readInt(json['row']),
      col: readInt(json['col']),
    );
  }

  final TeacherToolStudent student;
  final int row;
  final int col;
}

class ClassSeatMapData {
  const ClassSeatMapData({
    required this.classId,
    required this.className,
    required this.rows,
    required this.cols,
    required this.assignments,
    required this.unassignedStudents,
  });

  factory ClassSeatMapData.fromJson(Map<String, dynamic> json) {
    return ClassSeatMapData(
      classId: readInt(json['class_id']),
      className: readString(json['class_name']),
      rows: readInt(json['rows']),
      cols: readInt(json['cols']),
      assignments: readMapList(json['assignments'])
          .map(SeatAssignment.fromJson)
          .toList(growable: false),
      unassignedStudents: readMapList(json['unassigned_students'])
          .map(TeacherToolStudent.fromJson)
          .toList(growable: false),
    );
  }

  final int classId;
  final String className;
  final int rows;
  final int cols;
  final List<SeatAssignment> assignments;
  final List<TeacherToolStudent> unassignedStudents;

  List<TeacherToolStudent> get students => [
        ...assignments.map((assignment) => assignment.student),
        ...unassignedStudents,
      ];
}

class SessionSummaryAttendance {
  const SessionSummaryAttendance({
    required this.recordedCount,
    required this.present,
    required this.absent,
    required this.late,
    required this.permission,
  });

  factory SessionSummaryAttendance.fromJson(Map<String, dynamic> json) =>
      SessionSummaryAttendance(
        recordedCount: readInt(json['recorded_count']),
        present: readInt(json['present']),
        absent: readInt(json['absent']),
        late: readInt(json['late']),
        permission: readInt(json['permission']),
      );

  final int recordedCount;
  final int present;
  final int absent;
  final int late;
  final int permission;
}

class SessionSummaryBehavior {
  const SessionSummaryBehavior({
    required this.recordsCount,
    required this.positiveCount,
    required this.negativeCount,
    required this.totalPoints,
  });

  factory SessionSummaryBehavior.fromJson(Map<String, dynamic> json) =>
      SessionSummaryBehavior(
        recordsCount: readInt(json['records_count']),
        positiveCount: readInt(json['positive_count']),
        negativeCount: readInt(json['negative_count']),
        totalPoints: readInt(json['total_points']),
      );

  final int recordsCount;
  final int positiveCount;
  final int negativeCount;
  final int totalPoints;
}

class SessionSummaryQuickQuestion {
  const SessionSummaryQuickQuestion({
    required this.asked,
    required this.question,
    required this.understoodCount,
    required this.partialCount,
    required this.notUnderstoodCount,
  });

  factory SessionSummaryQuickQuestion.fromJson(Map<String, dynamic> json) =>
      SessionSummaryQuickQuestion(
        asked: readBool(json['asked']),
        question: readString(json['question']),
        understoodCount: readInt(json['understood_count']),
        partialCount: readInt(json['partial_count']),
        notUnderstoodCount: readInt(json['not_understood_count']),
      );

  final bool asked;
  final String question;
  final int understoodCount;
  final int partialCount;
  final int notUnderstoodCount;
}

class SuggestedSummaryElement {
  const SuggestedSummaryElement({required this.key, required this.label});

  factory SuggestedSummaryElement.fromJson(Map<String, dynamic> json) =>
      SuggestedSummaryElement(
        key: readString(json['key']),
        label: readString(json['label']),
      );

  final String key;
  final String label;
}

class SessionSummaryData {
  const SessionSummaryData({
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.date,
    required this.dateHijri,
    required this.attendance,
    required this.behavior,
    required this.quickQuestion,
    required this.suggestedElements,
    required this.alreadySaved,
    required this.selectedElements,
    this.evidenceCategoryId,
    this.evidenceId,
  });

  factory SessionSummaryData.fromJson(Map<String, dynamic> json) {
    return SessionSummaryData(
      classId: readInt(json['class_id']),
      className: readString(json['class_name']),
      session: readString(json['session']),
      sessionLabel: readString(json['session_label']),
      date: readString(json['date']),
      dateHijri: readString(json['date_hijri']),
      attendance: SessionSummaryAttendance.fromJson(
        readMap(json['attendance']),
      ),
      behavior: SessionSummaryBehavior.fromJson(readMap(json['behavior'])),
      quickQuestion: SessionSummaryQuickQuestion.fromJson(
        readMap(json['quick_question']),
      ),
      suggestedElements: readMapList(json['suggested_elements'])
          .map(SuggestedSummaryElement.fromJson)
          .toList(growable: false),
      alreadySaved: readBool(json['already_saved']),
      selectedElements: readList(json['selected_elements'])
          .map(readString)
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      evidenceCategoryId: readNullableInt(json['evidence_category_id']),
      evidenceId: readNullableInt(json['evidence_id']),
    );
  }

  final int classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String date;
  final String dateHijri;
  final SessionSummaryAttendance attendance;
  final SessionSummaryBehavior behavior;
  final SessionSummaryQuickQuestion quickQuestion;
  final List<SuggestedSummaryElement> suggestedElements;
  final bool alreadySaved;
  final List<String> selectedElements;
  final int? evidenceCategoryId;
  final int? evidenceId;
}

class TeacherToolEvidenceCategory {
  const TeacherToolEvidenceCategory({required this.id, required this.name});

  factory TeacherToolEvidenceCategory.fromJson(Map<String, dynamic> json) =>
      TeacherToolEvidenceCategory(
        id: readInt(json['id']),
        name: readString(json['name']),
      );

  final int id;
  final String name;
}

int readInt(dynamic value) => switch (value) {
      int number => number,
      num number => number.toInt(),
      _ => int.tryParse(value?.toString() ?? '') ?? 0,
    };

int? readNullableInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return readInt(value);
}

String readString(dynamic value) => value?.toString() ?? '';

bool readBool(dynamic value) => switch (value) {
      bool boolean => boolean,
      1 || '1' || 'true' => true,
      _ => false,
    };

Map<String, dynamic> readMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

List<dynamic> readList(dynamic value) => value is List ? value : const [];

List<Map<String, dynamic>> readMapList(dynamic value) => readList(value)
    .whereType<Map>()
    .map((item) => Map<String, dynamic>.from(item))
    .toList(growable: false);
