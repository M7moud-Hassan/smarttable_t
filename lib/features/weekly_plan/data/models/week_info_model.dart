class WeekInfoModel {
  int id;
  int weekNumber;
  String weekNumberText;

  WeekInfoModel({
    required this.id,
    required this.weekNumber,
    required this.weekNumberText,
  });

  factory WeekInfoModel.fromJson(Map<String, dynamic> json) => WeekInfoModel(
        id: json["id"],
        weekNumber: json["week_number"],
        weekNumberText: json["week_number_text"],
      );
}
