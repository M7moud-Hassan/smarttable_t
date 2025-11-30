class SocialCaseModel {
  int id;
  String name;
  int studentsCount;

  SocialCaseModel(
      {required this.id, required this.name, required this.studentsCount});

  factory SocialCaseModel.fromJson(Map<String, dynamic> json) {
    return SocialCaseModel(
      id: json['id'],
      name: json['name'],
      studentsCount: json['students_count'],
    );
  }
}
