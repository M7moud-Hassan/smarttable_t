class SocialCaseDetailsModel {
  int id;
  String name;
  bool fatherIsAlive;
  bool motherIsAlive;
  String studentGuardian;
  String kinshipWithStudent;
  String withLive;
  String withLiveText;

  SocialCaseDetailsModel({
    required this.id,
    required this.name,
    required this.fatherIsAlive,
    required this.motherIsAlive,
    required this.studentGuardian,
    required this.kinshipWithStudent,
    required this.withLive,
    required this.withLiveText,
  });

  factory SocialCaseDetailsModel.fromJson(Map<String, dynamic> json) =>
      SocialCaseDetailsModel(
        id: json["id"],
        name: json["name"],
        fatherIsAlive: json["father_is_alive"],
        motherIsAlive: json["mother_is_alive"],
        studentGuardian: json["student_guardian"],
        kinshipWithStudent: json["kinship_with_student"],
        withLive: json["with_live"],
        withLiveText: json["with_live_text"],
      );
}
