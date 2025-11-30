class ScheduledTasksModel {
  final String date;
  final List<Task> tasks;

  ScheduledTasksModel({
    required this.date,
    required this.tasks,
  });

  factory ScheduledTasksModel.fromJson(Map<String, dynamic> json) =>
      ScheduledTasksModel(
        date: json["date"],
        tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "tasks": List<dynamic>.from(tasks.map((x) => x.toJson())),
      };
}

class Task {
  final int id;
  final String title;
  final String details;

  Task({
    required this.id,
    required this.title,
    required this.details,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        details: json["details"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "details": details,
      };
}
