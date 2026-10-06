import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_report_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class AttendanceReportContent extends ConsumerWidget {
  const AttendanceReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(attendanceReportQueryProvider);
    if (query.studentId case final studentId?) {
      return _StudentAttendanceReportContent(
        studentId: studentId,
        period: query.period,
      );
    }
    final report = ref.watch(attendanceReportProvider);
    return report.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ReportError(
        message: perseveranceErrorMessage(error),
        onRetry: () => ref.invalidate(attendanceReportProvider),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          const Text(
            'نسبة الحضور لكل الفصول',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DonutMetric(
                  value: _asRatio(data.overall.presentPercentage),
                  label: 'حاضر',
                  color: attendanceGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DonutMetric(
                  value: _asRatio(data.overall.absentPercentage),
                  label: 'غائب',
                  color: attendanceRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DonutMetric(
                  value: _asRatio(data.overall.latePercentage),
                  label: 'متأخر',
                  color: attendanceAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'نسب الحضور حسب الفصل',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondryColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (data.classes.isEmpty)
            const EmptyReport(message: 'لا توجد بيانات حضور لهذه الفترة')
          else
            ...data.classes.map(
              (classroom) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _AttendanceClassReportCard(report: classroom),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentAttendanceReportContent extends ConsumerWidget {
  const _StudentAttendanceReportContent({
    required this.studentId,
    required this.period,
  });

  final int studentId;
  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = StudentPeriodQuery(studentId, period);
    final report = ref.watch(studentAttendanceHistoryProvider(query));
    return report.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ReportError(
        message: perseveranceErrorMessage(error),
        onRetry: () => ref.invalidate(studentAttendanceHistoryProvider(query)),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Text(
            'تقرير حضور ${data.student.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StudentReportStat(
                label: 'نسبة الحضور',
                value: '${data.summary.presentPercentage.round()}%',
                color: attendanceGreen,
              ),
              StudentReportStat(
                label: 'حاضر',
                value: '${data.summary.presentDays}',
                color: attendanceGreen,
              ),
              StudentReportStat(
                label: 'غائب',
                value: '${data.summary.absentDays}',
                color: attendanceRed,
              ),
              StudentReportStat(
                label: 'متأخر',
                value: '${data.summary.lateDays}',
                color: attendanceAmber,
              ),
              StudentReportStat(
                label: 'مستأذن',
                value: '${data.summary.permissionDays}',
                color: attendanceNavy,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (data.entries.isEmpty)
            const EmptyReport(message: 'لا يوجد سجل حضور لهذه الفترة')
          else
            ...data.entries.map(
              (entry) => StudentReportEntry(
                title:
                    '${entry.dayName} ${entry.dateHijri.isNotEmpty ? entry.dateHijri : entry.date}'
                        .trim(),
                details: [entry.sessionLabel, entry.courseName]
                    .where((value) => value.isNotEmpty)
                    .join(' • '),
                trailing: AttendanceStatusBadge(status: entry.status),
              ),
            ),
        ],
      ),
    );
  }
}

double _asRatio(double value) {
  final ratio = value > 1 ? value / 100 : value;
  return ratio.clamp(0, 1).toDouble();
}

class _DonutMetric extends StatelessWidget {
  const _DonutMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: const Color(0xFFE8E3E3),
                    color: color,
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AttendanceClassReportCard extends StatelessWidget {
  const _AttendanceClassReportCard({required this.report});

  final AttendanceClassReport report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final segments = [
      (summary.present, attendanceGreen),
      (summary.absent, attendanceRed),
      (summary.late, attendanceAmber),
      (summary.permission, attendanceNavy),
    ].where((segment) => segment.$1 > 0).toList();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفصل ${report.className}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 14,
              child: segments.isEmpty
                  ? const ColoredBox(color: Color(0xFFD7D7D7))
                  : Row(
                      children: segments
                          .map(
                            (segment) => Expanded(
                              flex: segment.$1,
                              child: ColoredBox(color: segment.$2),
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 12,
            runSpacing: 5,
            children: [
              Text(
                '• ${summary.present} حضور',
                style: const TextStyle(color: attendanceGreen),
              ),
              Text(
                '• ${summary.absent} غائب',
                style: const TextStyle(color: attendanceRed),
              ),
              Text(
                '• ${summary.late} متأخر',
                style: const TextStyle(color: attendanceAmber),
              ),
              if (summary.permission > 0)
                Text(
                  '• ${summary.permission} مستأذن',
                  style: const TextStyle(color: attendanceNavy),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
