class DayModel {
  int dayId;
  String dayName;
  String dayNumber;
  bool isCurrent;

  DayModel({
    required this.dayId,
    required this.dayName,
    required this.dayNumber,
    required this.isCurrent,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) => DayModel(
        dayId: json["day_id"],
        dayName: json["day_name"],
        dayNumber: json["day_number"],
        isCurrent: json["is_current"],
      );

  Map<String, dynamic> toJson() => {
        "day_id": dayId,
        "day_name": dayName,
        "day_number": dayNumber,
        "is_current": isCurrent,
      };
}

class DaysOfWeekModel {
  int id;
  String name;
  bool highlighted;

  DaysOfWeekModel({
    required this.id,
    required this.name,
    required this.highlighted,
  });

  factory DaysOfWeekModel.fromJson(Map<String, dynamic> json) =>
      DaysOfWeekModel(
        id: json["id"],
        name: json["name"],
        highlighted: json["highlighted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "highlighted": highlighted,
      };
}
