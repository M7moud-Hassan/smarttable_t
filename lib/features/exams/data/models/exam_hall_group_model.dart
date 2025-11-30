class ExamHallGroupModel {
  const ExamHallGroupModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  final int id;
  final String name;
  final String startDate;
  final String endDate;

  factory ExamHallGroupModel.fromJson(Map<String, dynamic> json) {
    return ExamHallGroupModel(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}
