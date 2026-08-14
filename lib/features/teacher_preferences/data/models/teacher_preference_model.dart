class WishCourse {
  const WishCourse({required this.id, required this.name});

  final int id;
  final String name;

  factory WishCourse.fromJson(Map<String, dynamic> json) {
    return WishCourse(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class TeacherPreference {
  const TeacherPreference({
    required this.id,
    required this.classId,
    required this.className,
    required this.courses,
    required this.coursesCount,
    required this.note,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int classId;
  final String className;
  final List<WishCourse> courses;
  final String coursesCount;
  final String note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  List<String> get subjects =>
      courses.map((course) => course.name).toList(growable: false);

  factory TeacherPreference.fromJson(Map<String, dynamic> json) {
    final rawCourses = json['courses'];
    final courses = rawCourses is List
        ? rawCourses
            .whereType<Map>()
            .map(
              (course) => WishCourse.fromJson(
                Map<String, dynamic>.from(course),
              ),
            )
            .toList(growable: false)
        : const <WishCourse>[];

    return TeacherPreference(
      id: _asInt(json['id']),
      classId: _asInt(json['classroom_id']),
      className: json['classroom_name']?.toString() ?? '',
      courses: courses,
      coursesCount: json['courses_count']?.toString() ?? '${courses.length}',
      note: json['note']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class TeacherClassOption {
  const TeacherClassOption({
    required this.id,
    required this.name,
    required this.coursesCount,
    required this.wishId,
    required this.selectedCoursesCount,
  });

  final int id;
  final String name;
  final int coursesCount;
  final int? wishId;
  final int selectedCoursesCount;

  factory TeacherClassOption.fromJson(Map<String, dynamic> json) {
    return TeacherClassOption(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      coursesCount: _asInt(json['courses_count']),
      wishId: _asNullableInt(json['wish_id']),
      selectedCoursesCount: _asInt(json['selected_courses_count']),
    );
  }
}

class WishAvailableCourse {
  const WishAvailableCourse({
    required this.id,
    required this.name,
    required this.shortName,
    required this.isSelected,
    required this.isTaken,
    required this.assignedTeacherId,
    required this.assignedTeacherName,
  });

  final int id;
  final String name;
  final String shortName;
  final bool isSelected;
  final bool isTaken;
  final int? assignedTeacherId;
  final String? assignedTeacherName;

  factory WishAvailableCourse.fromJson(Map<String, dynamic> json) {
    final assignedTeacherName = json['assigned_teacher_name']?.toString();
    return WishAvailableCourse(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
      isSelected: json['is_selected'] == true,
      isTaken: json['is_taken'] == true,
      assignedTeacherId: _asNullableInt(json['assigned_teacher_id']),
      assignedTeacherName:
          assignedTeacherName == null || assignedTeacherName.isEmpty
              ? null
              : assignedTeacherName,
    );
  }
}

class TeacherPreferenceDraft {
  const TeacherPreferenceDraft({
    required this.classroomId,
    required this.courseIds,
    this.note = '',
  });

  final int classroomId;
  final List<int> courseIds;
  final String note;
}

int _asInt(dynamic value) => _asNullableInt(value) ?? 0;

int? _asNullableInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
