import 'lesson_model.dart';

class MasterTableModel {
  String currentClass;
  String currentClassLabel;
  String remainingTimeForNextLesson;
  List<MasterTable> masterTable;

  MasterTableModel({
    required this.currentClass,
    required this.currentClassLabel,
    required this.remainingTimeForNextLesson,
    required this.masterTable,
  });

  factory MasterTableModel.fromJson(Map<String, dynamic> json) =>
      MasterTableModel(
        currentClass: json["current_class"],
        currentClassLabel: json["current_class_label"],
        remainingTimeForNextLesson: json["remaining_time_for_next_lesson"],
        masterTable: List<MasterTable>.from(
            json["master_table"].map((x) => MasterTable.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "current_class": currentClass,
        "current_class_label": currentClassLabel,
        "remaining_time_for_next_lesson": remainingTimeForNextLesson,
        "master_table": List<dynamic>.from(masterTable.map((x) => x.toJson())),
      };
}

class MasterTable {
  int teacherId;
  String teacherNameLabel;
  String teacherName;
  List<LessonModel> lessons;

  MasterTable({
    required this.teacherId,
    required this.teacherNameLabel,
    required this.teacherName,
    required this.lessons,
  });

  factory MasterTable.fromJson(Map<String, dynamic> json) => MasterTable(
        teacherId: json["teacher_id"],
        teacherNameLabel: json["teacher_name_label"],
        teacherName: json["teacher_name"],
        lessons: List<LessonModel>.from(
            json["lessons"].map((x) => LessonModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "teacher_id": teacherId,
        "teacher_name_label": teacherNameLabel,
        "teacher_name": teacherName,
        "lessons": List<dynamic>.from(lessons.map((x) => x.toJson())),
      };
}
