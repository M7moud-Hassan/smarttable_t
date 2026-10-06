import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_report_views.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/behavior_report_views.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/report_filter_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

export 'attendance_report_views.dart' show AttendanceReportContent;
export 'behavior_report_views.dart' show BehaviorReportContent;
export 'report_filter_view.dart' show ReportFilterView;

class AttendanceBehaviorReportsPanel extends ConsumerWidget {
  const AttendanceBehaviorReportsPanel({
    super.key,
    required this.reportIndex,
    required this.onReportChanged,
    this.initialSession,
  });

  final int reportIndex;
  final ValueChanged<int> onReportChanged;
  final String? initialSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(attendanceReportQueryProvider);
    ref.watch(behaviorReportQueryProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: FeatureSegmentedControl(
            labels: const ['تقارير الحضور', 'تقارير السلوك'],
            selectedIndex: reportIndex,
            onSelected: onReportChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final reportType = await Navigator.of(context).push<String>(
                      MaterialPageRoute<String>(
                        builder: (_) => ReportFilterView(
                          initialReportIndex: reportIndex,
                          initialSession: initialSession,
                        ),
                      ),
                    );
                    if (reportType == 'attendance') onReportChanged(0);
                    if (reportType == 'behavior') onReportChanged(1);
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('فلترة وتصدير التقرير'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: reportIndex == 0
              ? const AttendanceReportContent()
              : const BehaviorReportContent(),
        ),
      ],
    );
  }
}
