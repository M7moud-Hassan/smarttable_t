class CircularsModel {
  final String date;
  final List<Tasks> tasks;

  CircularsModel({
    required this.date,
    required this.tasks,
  });

  factory CircularsModel.fromJson(Map<String, dynamic> json) => CircularsModel(
        date: json["date"],
        tasks: List<Tasks>.from(json["tasks"].map((x) => Tasks.fromJson(x))),
      );
}

class Tasks {
  final int id;
  final String title;
  final String details;
  final String date;
  final String dateHijri;
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String fileIcon;

  Tasks({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
    required this.dateHijri,
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileIcon,
  });

  factory Tasks.fromJson(Map<String, dynamic> json) => Tasks(
        id: json["id"],
        title: json["title"],
        details: json["details"],
        date: json["date"],
        dateHijri: json["date_hijri"],
        fileId: json["file_id"],
        fileName: json["file_name"],
        fileUrl: json["file_url"],
        fileIcon: json["file_icon"],
      );
}
