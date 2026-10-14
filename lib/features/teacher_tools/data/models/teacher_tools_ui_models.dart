class TeacherToolsContext {
  const TeacherToolsContext({
    required this.classId,
    required this.className,
    required this.session,
    required this.sessionLabel,
    required this.subject,
    required this.date,
    this.students = const [],
    this.fallbackToPreviewStudents = true,
  });

  final int? classId;
  final String className;
  final String session;
  final String sessionLabel;
  final String subject;
  final DateTime date;
  final List<TeacherToolStudent> students;
  final bool fallbackToPreviewStudents;

  List<TeacherToolStudent> get availableStudents =>
      students.isEmpty && fallbackToPreviewStudents
          ? teacherToolsPreviewStudents
          : students;

  String get apiDate {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class TeacherToolStudent {
  const TeacherToolStudent({
    required this.id,
    required this.name,
    required this.number,
  });

  final int id;
  final String name;
  final String number;

  factory TeacherToolStudent.fromJson(Map<String, dynamic> json) {
    return TeacherToolStudent(
      id: _readInt(json['id'] ?? json['student_id']),
      name: _readString(json['name']),
      number: _readString(json['number_student']),
    );
  }
}

int _readInt(dynamic value) => switch (value) {
      int number => number,
      num number => number.toInt(),
      _ => int.tryParse(value?.toString() ?? '') ?? 0,
    };

String _readString(dynamic value) => value?.toString() ?? '';

/// Temporary local data used only while the Lesson Tools API is not connected.
const teacherToolsPreviewStudents = <TeacherToolStudent>[
  TeacherToolStudent(id: 1, name: 'أحمد محمد العتيبي', number: '١٠١'),
  TeacherToolStudent(id: 2, name: 'خالد عبدالله الحربي', number: '١٠٢'),
  TeacherToolStudent(id: 3, name: 'سلمان فهد القحطاني', number: '١٠٣'),
  TeacherToolStudent(id: 4, name: 'راكان علي المطيري', number: '١٠٤'),
  TeacherToolStudent(id: 5, name: 'يوسف سعد الغامدي', number: '١٠٥'),
  TeacherToolStudent(id: 6, name: 'عبدالعزيز ناصر الشهري', number: '١٠٦'),
  TeacherToolStudent(id: 7, name: 'محمد وليد الزهراني', number: '١٠٧'),
  TeacherToolStudent(id: 8, name: 'عمر حسن الدوسري', number: '١٠٨'),
  TeacherToolStudent(id: 9, name: 'زياد ماجد العنزي', number: '١٠٩'),
  TeacherToolStudent(id: 10, name: 'تركي صالح السبيعي', number: '١١٠'),
  TeacherToolStudent(id: 11, name: 'بدر إبراهيم الشمري', number: '١١١'),
  TeacherToolStudent(id: 12, name: 'فيصل عادل المالكي', number: '١١٢'),
];
