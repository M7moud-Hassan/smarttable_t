import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_report_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class BehaviorReportContent extends ConsumerWidget {
  const BehaviorReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(behaviorReportQueryProvider);
    if (query.studentId case final studentId?) {
      return _StudentBehaviorReportContent(
        studentId: studentId,
        period: query.period,
      );
    }
    final report = ref.watch(behaviorReportProvider);
    return report.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ReportError(
        message: perseveranceErrorMessage(error),
        onRetry: () => ref.invalidate(behaviorReportProvider),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          const Text(
            'نسب السلوك حسب الفصل',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondryColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (data.classes.isEmpty)
            const EmptyReport(message: 'لا توجد بيانات سلوك لهذه الفترة')
          else
            ...data.classes.map(
              (classroom) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _BehaviorClassReportCard(report: classroom),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentBehaviorReportContent extends ConsumerWidget {
  const _StudentBehaviorReportContent({
    required this.studentId,
    required this.period,
  });

  final int studentId;
  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = StudentPeriodQuery(studentId, period);
    final report = ref.watch(studentBehaviorHistoryProvider(query));
    return report.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ReportError(
        message: perseveranceErrorMessage(error),
        onRetry: () => ref.invalidate(studentBehaviorHistoryProvider(query)),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Text(
            'تقرير سلوك ${data.student.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StudentReportStat(
                label: 'سجلات السلوك',
                value: '${data.summary.recordsCount}',
              ),
              StudentReportStat(
                label: 'إيجابي',
                value: '${data.summary.positiveCount}',
              ),
              StudentReportStat(
                label: 'بحاجة لتحسين',
                value: '${data.summary.negativeCount}',
              ),
              StudentReportStat(
                label: 'مجموع النقاط',
                value: '${data.summary.totalPoints}',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (data.entries.isEmpty)
            const EmptyReport(message: 'لا يوجد سجل سلوك لهذه الفترة')
          else
            ...data.entries.map(
              (entry) => StudentReportEntry(
                title:
                    '${entry.dayName} ${entry.dateHijri.isNotEmpty ? entry.dateHijri : entry.date}'
                        .trim(),
                details: [
                  entry.sessionLabel,
                  ...entry.notes.map((note) => note.name),
                  entry.additionalNotes,
                ].where((value) => value.isNotEmpty).join(' • '),
                trailing: Text('${entry.totalPoints} نقاط'),
              ),
            ),
        ],
      ),
    );
  }
}

class _BehaviorClassReportCard extends StatelessWidget {
  const _BehaviorClassReportCard({required this.report});

  final BehaviorClassReport report;

  @override
  Widget build(BuildContext context) {
    final segments = [
      (report.excellent, const Color(0xFF12B886)),
      (report.veryGood, attendanceGreen),
      (report.good, behaviorOrange),
      (report.acceptable, attendanceAmber),
      (report.weak, attendanceRed),
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
          const SizedBox(height: 11),
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
                '• ${report.excellent} ممتاز',
                style: const TextStyle(color: Color(0xFF12B886)),
              ),
              Text(
                '• ${report.veryGood} جيد جداً',
                style: const TextStyle(color: attendanceGreen),
              ),
              Text(
                '• ${report.good} جيد',
                style: const TextStyle(color: behaviorOrange),
              ),
              Text(
                '• ${report.acceptable} مقبول',
                style: const TextStyle(color: attendanceAmber),
              ),
              Text(
                '• ${report.weak} ضعيف',
                style: const TextStyle(color: attendanceRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
