class HealthCaseModel {
  int id;
  String name;
  int healthConditionsCount;

  HealthCaseModel(
      {required this.id,
      required this.name,
      required this.healthConditionsCount});

  factory HealthCaseModel.fromJson(Map<String, dynamic> json) {
    return HealthCaseModel(
      id: json['id'],
      name: json['name'],
      healthConditionsCount: json['health_conditions_count'],
    );
  }
}
