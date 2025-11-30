class ExamHallModel {
  int id;
  String period;
  String name;
  String day;
  List<String> courses;
  String date;
  String startTime;
  String endTime;

  ExamHallModel({
    required this.id,
    required this.period,
    required this.name,
    required this.day,
    required this.courses,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory ExamHallModel.fromJson(Map<String, dynamic> json) {
    return ExamHallModel(
      id: json['id'],
      period: json['period'],
      name: json['name'],
      day: json['day'],
      courses: List<String>.from(json['courses']),
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
