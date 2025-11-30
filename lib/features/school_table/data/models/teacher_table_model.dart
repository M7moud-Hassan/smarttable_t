import 'package:smart_table_app/features/school_table/data/models/day_model.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';

class TeacherTableModel {
  String currentLesson;
  String remainingTimeForNextLesson;
  List<TableInfoModel> tableInfo;

  TeacherTableModel({
    required this.currentLesson,
    required this.remainingTimeForNextLesson,
    required this.tableInfo,
  });

  factory TeacherTableModel.fromJson(Map<String, dynamic> json) {
    return TeacherTableModel(
      currentLesson: json['current_lesson'],
      remainingTimeForNextLesson: json['remaining_time_for_next_lesson'],
      tableInfo: List<TableInfoModel>.from(
        json['table_info'].map((x) => TableInfoModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_lesson': currentLesson,
      'remaining_time_for_next_lesson': remainingTimeForNextLesson,
      'table_info': List<dynamic>.from(tableInfo.map((x) => x.toJson())),
    };
  }
}

class TableInfoModel {
  String teacherName;
  String teacherNameLabel;
  List<DaysOfWeekModel> daysOfWeek;
  List<LessonModel> lessons;

  TableInfoModel({
    required this.teacherName,
    required this.teacherNameLabel,
    required this.daysOfWeek,
    required this.lessons,
  });

  factory TableInfoModel.fromJson(Map<String, dynamic> json) {
    return TableInfoModel(
      teacherName: json['teacher_name'],
      teacherNameLabel: json['teacher_name_label'],
      daysOfWeek: List<DaysOfWeekModel>.from(
          json['days_of_week'].map((x) => DaysOfWeekModel.fromJson(x))),
      lessons: List<LessonModel>.from(
          json['lessons'].map((x) => LessonModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_name': teacherName,
      'teacher_name_label': teacherNameLabel,
      'days_of_week': List<dynamic>.from(daysOfWeek.map((x) => x.toJson())),
      'lessons': List<dynamic>.from(lessons.map((x) => x.toJson())),
    };
  }
}
