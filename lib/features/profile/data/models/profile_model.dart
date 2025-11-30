class ProfileModel {
  int id;
  String phoneNumber;
  String teacherName;
  String teacherNickname;
  String teacherNameLabel;
  String schoolName;
  String? fcmToken;

  ProfileModel({
    required this.id,
    required this.phoneNumber,
    required this.teacherName,
    required this.teacherNickname,
    required this.teacherNameLabel,
    required this.schoolName,
    required this.fcmToken,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["id"],
      phoneNumber: json["phone_number"],
      teacherName: json["teacher_name"],
      teacherNickname: json["teacher_nickname"],
      teacherNameLabel: json["teacher_name_label"],
      schoolName: json["school_name"],
      fcmToken: json["fcm_token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "phone_number": phoneNumber,
      "teacher_name": teacherName,
      "teacher_nickname": teacherNickname,
      "teacher_name_label": teacherNameLabel,
      "school_name": schoolName,
      "fcm_token": fcmToken,
    };
  }
}
