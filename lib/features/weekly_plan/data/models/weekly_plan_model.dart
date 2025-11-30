class WeeklyPlanModel {
  int id;
  String file;
  String fileName;
  String teacherName;
  String weekInfo;
  DateTime createdAt;

  WeeklyPlanModel({
    required this.id,
    required this.file,
    required this.fileName,
    required this.teacherName,
    required this.createdAt,
    required this.weekInfo,
  });

  factory WeeklyPlanModel.fromJson(Map<String, dynamic> json) =>
      WeeklyPlanModel(
        id: json["id"],
        file: json["file"],
        fileName: json["file_name"],
        weekInfo: json["week_info_text"],
        teacherName: json["teacher_name"],
        createdAt: DateTime.parse(json["created_at"]),
      );
}
