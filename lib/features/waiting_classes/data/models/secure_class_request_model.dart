class SecureClassRequestModel {
  const SecureClassRequestModel({
    required this.id,
    required this.applicantName,
    required this.substituteName,
    required this.cellNumber,
    required this.date,
    required this.status,
    required this.statusText,
    required this.stage,
    required this.awaitingSubstitute,
    required this.note,
    required this.managerNote,
    required this.lesson,
    required this.createdAt,
  });

  final int id;
  final String applicantName;
  final String substituteName;
  final int? cellNumber;
  final String date;
  final String status;
  final String statusText;
  final int stage;
  final bool awaitingSubstitute;
  final String note;
  final String managerNote;
  final SecureClassRequestLesson lesson;
  final String createdAt;

  bool get canCancel => status == 'pending';
  bool get canRespond => awaitingSubstitute;

  String get stageText => switch (stage) {
        1 => 'بانتظار رد المعلم البديل',
        2 => 'بانتظار اعتماد الإدارة',
        _ => 'منتهي',
      };

  factory SecureClassRequestModel.fromJson(Map<String, dynamic> json) {
    return SecureClassRequestModel(
      id: _asInt(json['id']) ?? 0,
      applicantName: _asText(json['applicant_name']),
      substituteName: _asText(json['substitute_name']),
      cellNumber: _asInt(json['cell_number']),
      date: _asText(json['date']),
      status: _asText(json['status']),
      statusText: _asText(json['status_text']),
      stage: _asInt(json['stage']) ?? 0,
      awaitingSubstitute: _asBool(json['awaiting_substitute']),
      note: _asText(json['note']),
      managerNote: _asText(json['manager_note']),
      lesson: SecureClassRequestLesson.fromJson(json['lesson']),
      createdAt: _asText(json['created_at']),
    );
  }
}

class SecureClassRequestLesson {
  const SecureClassRequestLesson({
    required this.subject,
    required this.classroom,
    required this.dayName,
    required this.classNumberText,
    required this.startTime,
    required this.endTime,
  });

  final String subject;
  final String classroom;
  final String dayName;
  final String classNumberText;
  final String startTime;
  final String endTime;

  factory SecureClassRequestLesson.fromJson(dynamic value) {
    if (value is String) {
      return SecureClassRequestLesson(
        subject: value,
        classroom: '',
        dayName: '',
        classNumberText: '',
        startTime: '',
        endTime: '',
      );
    }

    final json = value is Map
        ? Map<String, dynamic>.from(value)
        : const <String, dynamic>{};
    final cellText = json['cell_text'] is Map
        ? Map<String, dynamic>.from(json['cell_text'])
        : const <String, dynamic>{};
    final cellLines = _asText(cellText['subject'])
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    return SecureClassRequestLesson(
      subject: _firstText([
        json['subject'],
        json['course_name'],
        if (cellLines.isNotEmpty) cellLines.last,
      ]),
      classroom: _firstText([
        json['classroom'],
        json['class_name'],
        if (cellLines.length > 1) cellLines.first,
      ]),
      dayName: _asText(json['day_name']),
      classNumberText: _firstText([
        json['class_number_text'],
        json['lesson_name'],
      ]),
      startTime: _asText(json['start_time']),
      endTime: _asText(json['end_time']),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' || 'yes' => true,
    _ => false,
  };
}

String _asText(dynamic value) => value?.toString().trim() ?? '';

String _firstText(List<dynamic> values) {
  for (final value in values) {
    final text = _asText(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}
