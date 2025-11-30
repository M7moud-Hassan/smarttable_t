class HealthCaseDetailsModel {
  int id;
  String nameStudent;
  String name;
  String recommendations;
  String dealingWithSituation;

  HealthCaseDetailsModel({
    required this.id,
    required this.nameStudent,
    required this.name,
    required this.recommendations,
    required this.dealingWithSituation,
  });

  factory HealthCaseDetailsModel.fromJson(Map<String, dynamic> json) =>
      HealthCaseDetailsModel(
        id: json["id"],
        nameStudent: json["name_student"],
        name: json["name"],
        recommendations: json["recommendations"],
        dealingWithSituation: json["dealing_with_situation"],
      );
}
