class LessonModel {
  int dayId;
  String classNumber;
  String classNumberText;
  String startTime;
  String endTime;
  String timeText;
  bool isWaiting;
  String confirmLink;
  String wcPriority;
  bool confirmed;
  CellText cellText;
  String? originalTeacherName;
  String? teacherImageUrl;
  int? secureCellNumber;

  LessonModel({
    required this.dayId,
    required this.classNumber,
    required this.classNumberText,
    this.startTime = "",
    this.endTime = "",
    this.timeText = "",
    required this.isWaiting,
    required this.confirmLink,
    required this.wcPriority,
    required this.confirmed,
    required this.cellText,
    this.originalTeacherName,
    this.teacherImageUrl,
    this.secureCellNumber,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final cellTextJson = Map<String, dynamic>.from(json["cell_text"] ?? {});

    return LessonModel(
      dayId: json["day_id"],
      classNumber: json["class_number"],
      classNumberText: json["class_number_text"],
      startTime: json["start_time"]?.toString() ?? "",
      endTime: json["end_time"]?.toString() ?? "",
      timeText: json["time_text"]?.toString() ?? "",
      isWaiting: json["is_waiting"],
      confirmLink: json["confirm_link"],
      wcPriority: json["wc_priority"],
      confirmed: json["confirmed"],
      cellText: CellText.fromJson(cellTextJson),
      originalTeacherName: _firstNonEmptyString(
            json,
            const [
              "original_teacher_name",
              "main_teacher_name",
              "basic_teacher_name",
              "teacher_name",
            ],
          ) ??
          _firstNonEmptyString(
            cellTextJson,
            const [
              "original_teacher_name",
              "main_teacher_name",
              "basic_teacher_name",
              "teacher_name",
            ],
          ),
      teacherImageUrl: _firstNonEmptyString(
            json,
            const ["teacher_image_url", "teacher_image", "image_url", "avatar"],
          ) ??
          _firstNonEmptyString(
            cellTextJson,
            const [
              "teacher_image_url",
              "teacher_image",
              "image_url",
              "avatar",
            ],
          ),
      secureCellNumber: _tryParseInt(json["cell_number"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "day_id": dayId,
        "class_number": classNumber,
        "class_number_text": classNumberText,
        "start_time": startTime,
        "end_time": endTime,
        "time_text": timeText,
        "is_waiting": isWaiting,
        "confirm_link": confirmLink,
        "wc_priority": wcPriority,
        "confirmed": confirmed,
        "cell_text": cellText.toJson(),
        if (originalTeacherName != null)
          "original_teacher_name": originalTeacherName,
        if (teacherImageUrl != null) "teacher_image_url": teacherImageUrl,
        if (secureCellNumber != null) "cell_number": secureCellNumber,
      };

  /// factory for init LessonModel
  factory LessonModel.init() => LessonModel(
        dayId: 0,
        classNumber: "",
        classNumberText: "",
        isWaiting: false,
        confirmLink: "",
        wcPriority: "",
        confirmed: false,
        cellText: CellText(
          subject: "",
        ),
      );

  LessonModel copyWith({
    int? dayId,
    String? classNumber,
    String? classNumberText,
    String? startTime,
    String? endTime,
    String? timeText,
    bool? isWaiting,
    String? confirmLink,
    String? wcPriority,
    bool? confirmed,
    CellText? cellText,
    String? originalTeacherName,
    String? teacherImageUrl,
    int? secureCellNumber,
  }) {
    return LessonModel(
      dayId: dayId ?? this.dayId,
      classNumber: classNumber ?? this.classNumber,
      classNumberText: classNumberText ?? this.classNumberText,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeText: timeText ?? this.timeText,
      isWaiting: isWaiting ?? this.isWaiting,
      confirmLink: confirmLink ?? this.confirmLink,
      wcPriority: wcPriority ?? this.wcPriority,
      confirmed: confirmed ?? this.confirmed,
      cellText: cellText ?? this.cellText,
      originalTeacherName: originalTeacherName ?? this.originalTeacherName,
      teacherImageUrl: teacherImageUrl ?? this.teacherImageUrl,
      secureCellNumber: secureCellNumber ?? this.secureCellNumber,
    );
  }

  static const String waitingLabel = "منتظر";

  String get displayTimeText {
    final formatted = timeText.trim();
    if (formatted.isNotEmpty) return formatted;

    final start = startTime.trim();
    final end = endTime.trim();
    if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    return start.isNotEmpty ? start : end;
  }

  List<String> get contentLines => cellText.subject
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !_isTimeTextLine(line))
      .toList(growable: false);

  bool _isTimeTextLine(String line) {
    final formatted = timeText.trim();
    return formatted.isNotEmpty && line == formatted;
  }

  /// A waiting slot may arrive from the API before it is assigned, in which
  /// case [isWaiting] is false but the cell still contains the waiting label.
  bool get isWaitingSlot =>
      isWaiting || contentLines.any((line) => line.contains(waitingLabel));

  /// Secure-class requests belong to the teacher's own primary lessons, not
  /// waiting assignments. Empty timetable cells are never eligible.
  bool get canBeSecured =>
      !isWaitingSlot && subjectName.isNotEmpty && cellNumber != null;

  /// Waiting assignments use their original confirmation flow and must not
  /// open the secure-class substitute picker.
  bool get canAcceptWaitingClass =>
      isWaiting && !confirmed && confirmLink.trim().isNotEmpty;

  /// The waiting marker shown in timetable cells, including its slot number.
  /// Classroom details following a colon are displayed in the details sheet.
  String get waitingTitle {
    for (final line in contentLines) {
      final title = _waitingTitleFrom(line);
      if (title != null) return title;
    }
    return waitingLabel;
  }

  String? _waitingTitleFrom(String value) {
    final waitingIndex = value.indexOf(waitingLabel);
    if (waitingIndex == -1) return null;

    final waitingText = value.substring(waitingIndex).trim();
    final separatorIndex = waitingText.indexOf(RegExp(r'[:：]'));
    final title = separatorIndex == -1
        ? waitingText
        : waitingText.substring(0, separatorIndex).trim();
    return title.isEmpty ? waitingLabel : title;
  }

  /// Text shown in the compact timetable cell/card.
  String get compactTitle =>
      isWaitingSlot ? waitingTitle : truncateText(subjectName, 10);

  /// The actual subject, excluding the waiting marker and classroom.
  String get subjectName {
    if (contentLines.isEmpty) return "";
    if (!isWaitingSlot) return contentLines.last;

    return contentLines.firstWhere(
      (line) => !line.contains(waitingLabel),
      orElse: () => "",
    );
  }

  /// Classroom encoded in the API cell text (for example: "منتظر : م2/م2").
  String get classroomName {
    if (contentLines.isEmpty) return "";

    if (isWaitingSlot) {
      for (final line in contentLines.where(
        (line) => line.contains(waitingLabel),
      )) {
        final separatorIndex = line.indexOf(RegExp(r'[:：]'));
        if (separatorIndex != -1) {
          return line.substring(separatorIndex + 1).trim();
        }
      }
      return "";
    }

    return contentLines.length > 1 ? contentLines.first : "";
  }

  int? get cellNumber {
    if (secureCellNumber != null) return secureCellNumber;
    if (confirmLink.isEmpty) return null;
    try {
      final uri = Uri.tryParse(confirmLink);
      if (uri != null) {
        for (final segment in uri.pathSegments) {
          if (RegExp(r'^\d+$').hasMatch(segment)) {
            return int.parse(segment);
          }
        }
      }
    } catch (_) {}
    return null;
  }
}

int? _tryParseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String truncateText(String value, int maxCharacters) {
  final characters = value.runes.toList(growable: false);
  if (characters.length <= maxCharacters) return value;
  return '${String.fromCharCodes(characters.take(maxCharacters))}…';
}

String? _firstNonEmptyString(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

class CellText {
  String subject;

  CellText({required this.subject});

  factory CellText.fromJson(Map<String, dynamic> json) =>
      CellText(subject: json["subject"]);

  Map<String, dynamic> toJson() => {
        "subject": subject,
      };
}
