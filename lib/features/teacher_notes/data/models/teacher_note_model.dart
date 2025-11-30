class TeacherNoteModel {
  final int id;
  final String date;
  final String dateHijri;
  final String title;
  final String details;
  final String typeNote;
  final String typeNoteText;
  final String? comment;

  TeacherNoteModel({
    required this.id,
    required this.date,
    required this.dateHijri,
    required this.title,
    required this.details,
    required this.typeNote,
    required this.typeNoteText,
    this.comment,
  });

  factory TeacherNoteModel.fromJson(Map<String, dynamic> json) {
    return TeacherNoteModel(
      id: json['id'],
      date: json['date'],
      dateHijri: json['date_hijri'],
      title: json['title'],
      details: json['details'],
      typeNote: json['type_note'],
      typeNoteText: json['type_note_text'],
      comment: json['comment'],
    );
  }
}
