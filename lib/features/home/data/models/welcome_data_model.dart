class WelcomeDataModel {
  final int teacherId;
  final String welcomeLabel;
  final String teacherName;
  final String schoolName;

  const WelcomeDataModel({
    required this.teacherId,
    required this.welcomeLabel,
    required this.teacherName,
    required this.schoolName,
  });

  factory WelcomeDataModel.fromJson(Map<String, dynamic> json) =>
      WelcomeDataModel(
        teacherId: json["teacher_id"],
        welcomeLabel: json["welcome_label"],
        teacherName: json["teacher_name"],
        schoolName: json["school_name"],
      );

  Map<String, dynamic> toJson() => {
        "teacher_id": teacherId,
        "welcome_label": welcomeLabel,
        "teacher_name": teacherName,
        "school_name": schoolName,
      };
}
