class LessonModel {
  int dayId;
  String classNumber;
  String classNumberText;
  bool isWaiting;
  String confirmLink;
  String wcPriority;
  bool confirmed;
  CellText cellText;

  LessonModel({
    required this.dayId,
    required this.classNumber,
    required this.classNumberText,
    required this.isWaiting,
    required this.confirmLink,
    required this.wcPriority,
    required this.confirmed,
    required this.cellText,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        dayId: json["day_id"],
        classNumber: json["class_number"],
        classNumberText: json["class_number_text"],
        isWaiting: json["is_waiting"],
        confirmLink: json["confirm_link"],
        wcPriority: json["wc_priority"],
        confirmed: json["confirmed"],
        cellText: CellText.fromJson(json["cell_text"]),
      );

  Map<String, dynamic> toJson() => {
        "day_id": dayId,
        "class_number": classNumber,
        "class_number_text": classNumberText,
        "is_waiting": isWaiting,
        "confirm_link": confirmLink,
        "wc_priority": wcPriority,
        "confirmed": confirmed,
        "cell_text": cellText.toJson(),
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
    bool? isWaiting,
    String? confirmLink,
    String? wcPriority,
    bool? confirmed,
    CellText? cellText,
  }) {
    return LessonModel(
      dayId: dayId ?? this.dayId,
      classNumber: classNumber ?? this.classNumber,
      classNumberText: classNumberText ?? this.classNumberText,
      isWaiting: isWaiting ?? this.isWaiting,
      confirmLink: confirmLink ?? this.confirmLink,
      wcPriority: wcPriority ?? this.wcPriority,
      confirmed: confirmed ?? this.confirmed,
      cellText: cellText ?? this.cellText,
    );
  }
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
