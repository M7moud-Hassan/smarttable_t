enum AttendanceStatus {
  present('s'),
  absent('a'),
  late('l'),
  excused('p'),
  notRecorded('');

  const AttendanceStatus(this.apiValue);

  final String apiValue;

  static AttendanceStatus? tryFromApi(dynamic value) =>
      switch (value?.toString().trim().toLowerCase()) {
        's' => AttendanceStatus.present,
        'a' => AttendanceStatus.absent,
        'l' => AttendanceStatus.late,
        'p' => AttendanceStatus.excused,
        _ => null,
      };

  static AttendanceStatus fromApi(dynamic value) =>
      tryFromApi(value) ?? AttendanceStatus.notRecorded;
}

extension AttendanceStatusLabel on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.present => 'حاضر',
        AttendanceStatus.absent => 'غائب',
        AttendanceStatus.late => 'متأخر',
        AttendanceStatus.excused => 'مستأذن',
        AttendanceStatus.notRecorded => 'غير مسجل',
      };
}
