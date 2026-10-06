import 'attendance_models.dart';
import 'json_readers.dart';

class ReportQuery {
  const ReportQuery({
    this.classId,
    this.studentId,
    this.period = 'month',
    this.dateFrom,
    this.dateTo,
  });

  final int? classId;
  final int? studentId;
  final String period;
  final String? dateFrom;
  final String? dateTo;

  Map<String, dynamic> toParameters({bool includeStudents = false}) => {
        if (studentId == null && classId != null) 'class_id': classId,
        if (studentId != null) 'student_id': studentId,
        'period': period,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (includeStudents) 'include_students': true,
      };

  @override
  bool operator ==(Object other) =>
      other is ReportQuery &&
      classId == other.classId &&
      studentId == other.studentId &&
      period == other.period &&
      dateFrom == other.dateFrom &&
      dateTo == other.dateTo;

  @override
  int get hashCode => Object.hash(classId, studentId, period, dateFrom, dateTo);
}

class AttendanceReportSummary {
  const AttendanceReportSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.permission,
    required this.total,
    required this.presentPercentage,
    required this.absentPercentage,
    required this.latePercentage,
  });

  factory AttendanceReportSummary.fromJson(Map<String, dynamic> json) {
    final percentages = readJsonMap(json['percentages']);
    final present = readJsonInt(json['present']);
    final absent = readJsonInt(json['absent']);
    final late = readJsonInt(json['late']);
    final permission = readJsonInt(json['permission']);
    final total = readJsonInt(
      json['total'] ?? json['recorded_total'] ?? json['total_records'],
      fallback: present + absent + late + permission,
    );
    double percentage(String key, int count) {
      final explicit = json['${key}_percentage'] ?? percentages[key];
      return explicit == null
          ? (total == 0 ? 0 : count * 100 / total)
          : readJsonDouble(explicit);
    }

    return AttendanceReportSummary(
      present: present,
      absent: absent,
      late: late,
      permission: permission,
      total: total,
      presentPercentage: percentage('present', present),
      absentPercentage: percentage('absent', absent),
      latePercentage: percentage('late', late),
    );
  }

  final int present;
  final int absent;
  final int late;
  final int permission;
  final int total;
  final double presentPercentage;
  final double absentPercentage;
  final double latePercentage;
}

class AttendanceClassReport {
  const AttendanceClassReport({
    required this.classId,
    required this.className,
    required this.summary,
  });

  factory AttendanceClassReport.fromJson(Map<String, dynamic> json) {
    final summary = readJsonMap(json['summary']).isEmpty
        ? json
        : readJsonMap(json['summary']);
    return AttendanceClassReport(
      classId: readJsonInt(json['class_id'] ?? json['id']),
      className: readJsonString(
        json['class_name'] ?? json['name'] ?? json['label'],
      ),
      summary: AttendanceReportSummary.fromJson(summary),
    );
  }

  final int classId;
  final String className;
  final AttendanceReportSummary summary;
}

class AttendanceReportData {
  const AttendanceReportData({required this.overall, required this.classes});

  factory AttendanceReportData.fromJson(Map<String, dynamic> json) {
    final overall = readJsonMap(json['overall']).isEmpty
        ? readJsonMap(json['summary'])
        : readJsonMap(json['overall']);
    return AttendanceReportData(
      overall: AttendanceReportSummary.fromJson(overall),
      classes: readJsonList(json['classes'], AttendanceClassReport.fromJson),
    );
  }

  final AttendanceReportSummary overall;
  final List<AttendanceClassReport> classes;
}

class BehaviorClassReport {
  const BehaviorClassReport({
    required this.classId,
    required this.className,
    required this.excellent,
    required this.veryGood,
    required this.good,
    required this.acceptable,
    required this.weak,
  });

  factory BehaviorClassReport.fromJson(Map<String, dynamic> json) {
    final counts = readJsonMap(json['bands']).isEmpty
        ? (readJsonMap(json['summary']).isEmpty
            ? json
            : readJsonMap(json['summary']))
        : readJsonMap(json['bands']);
    return BehaviorClassReport(
      classId: readJsonInt(json['class_id'] ?? json['id']),
      className: readJsonString(
        json['class_name'] ?? json['name'] ?? json['label'],
      ),
      excellent: readJsonInt(counts['excellent'] ?? counts['excellent_count']),
      veryGood: readJsonInt(counts['very_good'] ?? counts['very_good_count']),
      good: readJsonInt(counts['good'] ?? counts['good_count']),
      acceptable:
          readJsonInt(counts['acceptable'] ?? counts['acceptable_count']),
      weak: readJsonInt(counts['weak'] ?? counts['weak_count']),
    );
  }

  final int classId;
  final String className;
  final int excellent;
  final int veryGood;
  final int good;
  final int acceptable;
  final int weak;

  int get total => excellent + veryGood + good + acceptable + weak;
}

class BehaviorReportData {
  const BehaviorReportData({required this.classes});

  factory BehaviorReportData.fromJson(Map<String, dynamic> json) {
    return BehaviorReportData(
      classes: readJsonList(json['classes'], BehaviorClassReport.fromJson),
    );
  }

  final List<BehaviorClassReport> classes;
}

class ReportOptions {
  const ReportOptions({
    required this.reportTypes,
    required this.periods,
    required this.classes,
    required this.formats,
  });

  factory ReportOptions.fromJson(Map<String, dynamic> json) {
    return ReportOptions(
      reportTypes: readJsonList(
        json['report_types'] ?? json['types'],
        PerseveranceOption.fromJson,
      ),
      periods: readJsonList(json['periods'], PerseveranceOption.fromJson),
      classes: readJsonList(
        json['classes'],
        PerseveranceClassOption.fromJson,
      ),
      formats: readJsonList(
        json['formats'] ?? json['file_formats'],
        PerseveranceOption.fromJson,
      ),
    );
  }

  final List<PerseveranceOption> reportTypes;
  final List<PerseveranceOption> periods;
  final List<PerseveranceClassOption> classes;
  final List<PerseveranceOption> formats;
}

class PerseveranceExportFile {
  const PerseveranceExportFile({
    required this.bytes,
    required this.fileName,
  });

  final List<int> bytes;
  final String fileName;
}
