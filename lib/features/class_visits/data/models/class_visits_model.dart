class ClassVisitsModel {
  int id;
  String teacherName;
  String visitorName;
  String session;
  String className;
  String date;
  String dateHijri;

  ClassVisitsModel({
    required this.id,
    required this.teacherName,
    required this.visitorName,
    required this.session,
    required this.className,
    required this.date,
    required this.dateHijri,
  });

  factory ClassVisitsModel.fromJson(Map<String, dynamic> json) =>
      ClassVisitsModel(
        id: json["id"],
        teacherName: json["teacher_name"],
        visitorName: json["visitor_name"],
        session: json["session"],
        className: json["class_name"],
        date: json["date"],
        dateHijri: json["date_hijri"],
      );
}
