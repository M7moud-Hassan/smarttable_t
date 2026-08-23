import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/service/download_service.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/data/repositories/perseverance_repository.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class AttendanceBehaviorReportsPanel extends StatelessWidget {
  const AttendanceBehaviorReportsPanel({
    super.key,
    required this.reportIndex,
    required this.onReportChanged,
  });

  final int reportIndex;
  final ValueChanged<int> onReportChanged;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportFilterView(
                        initialReportIndex: reportIndex,
                      ),
                    ),
                  ),
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

class AttendanceReportContent extends ConsumerWidget {
  const AttendanceReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(attendanceReportProvider);
    return report.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ReportError(
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
            const _EmptyReport(message: 'لا توجد بيانات حضور لهذه الفترة')
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

class BehaviorReportContent extends ConsumerWidget {
  const BehaviorReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(behaviorReportProvider);
    return report.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ReportError(
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
            const _EmptyReport(message: 'لا توجد بيانات سلوك لهذه الفترة')
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

class ReportFilterView extends ConsumerStatefulWidget {
  const ReportFilterView({
    super.key,
    required this.initialReportIndex,
  });

  final int initialReportIndex;

  @override
  ConsumerState<ReportFilterView> createState() => _ReportFilterViewState();
}

class _ReportFilterViewState extends ConsumerState<ReportFilterView> {
  String? _reportType;
  String? _period;
  String? _classId;
  String? _format;
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    final asyncOptions = ref.watch(reportOptionsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: 'فلتر'),
        body: asyncOptions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ReportError(
            message: perseveranceErrorMessage(error),
            onRetry: () => ref.invalidate(reportOptionsProvider),
          ),
          data: _buildForm,
        ),
      ),
    );
  }

  Widget _buildForm(ReportOptions options) {
    final reportTypes = options.reportTypes;
    final periods = options.periods;
    final formats = options.formats;
    final preferredType =
        widget.initialReportIndex == 0 ? 'attendance' : 'behavior';
    final reportType = _validOption(_reportType, reportTypes) ??
        (_validOption(preferredType, reportTypes) ??
            (reportTypes.isEmpty ? null : reportTypes.first.value));
    final period = _validOption(_period, periods) ??
        (_validOption('month', periods) ??
            (periods.isEmpty ? null : periods.first.value));
    final format = _validOption(_format, formats) ??
        (_validOption('pdf', formats) ??
            (formats.isEmpty ? null : formats.first.value));
    final classItems = <PerseveranceClassOption>[
      if (!options.classes.any((item) => item.id == null))
        const PerseveranceClassOption(id: null, name: 'كل الفصول'),
      ...options.classes,
    ];
    final String classValue = classItems.any(
      (item) => (item.id?.toString() ?? '') == _classId,
    )
        ? _classId!
        : '';

    if (reportType == null || period == null || format == null) {
      return const _EmptyReport(message: 'خيارات التقرير غير متاحة حالياً');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        _FilterDropdown(
          label: 'نوع التقرير',
          value: reportType,
          options: reportTypes,
          onChanged: (value) => setState(() => _reportType = value),
        ),
        _FilterDropdown(
          label: 'الفترة',
          value: period,
          options: periods,
          onChanged: (value) => setState(() => _period = value),
        ),
        _FilterDropdown(
          label: 'اسم الفصل',
          value: classValue,
          options: classItems
              .map(
                (item) => PerseveranceOption(
                  value: item.id?.toString() ?? '',
                  label: item.name,
                ),
              )
              .toList(growable: false),
          onChanged: (value) => setState(() => _classId = value),
        ),
        _FilterDropdown(
          label: 'الصيغة',
          value: format,
          options: formats,
          onChanged: (value) => setState(() => _format = value),
        ),
        const SizedBox(height: 70),
        Row(
          children: [
            Expanded(
              child: PrimaryActionButton(
                label: 'استعراض',
                onPressed: () => _preview(
                  reportType: reportType,
                  period: period,
                  classId: classValue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryActionButton(
                label: _downloading ? 'جارٍ التحميل...' : 'تحميل',
                icon: Icons.download_rounded,
                onPressed: _downloading || format == 'json'
                    ? null
                    : () => _download(
                          reportType: reportType,
                          fileFormat: format,
                          period: period,
                          classId: classValue,
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _validOption(String? value, List<PerseveranceOption> options) {
    return options.any((item) => item.value == value) ? value : null;
  }

  ReportQuery _query(String period, String classId) {
    return ReportQuery(
      classId: int.tryParse(classId),
      period: period,
    );
  }

  void _preview({
    required String reportType,
    required String period,
    required String classId,
  }) {
    final query = _query(period, classId);
    if (reportType == 'attendance' || reportType == 'combined') {
      ref.read(attendanceReportQueryProvider.notifier).state = query;
    }
    if (reportType == 'behavior' || reportType == 'combined') {
      ref.read(behaviorReportQueryProvider.notifier).state = query;
    }
    Navigator.of(context).pop();
  }

  Future<void> _download({
    required String reportType,
    required String fileFormat,
    required String period,
    required String classId,
  }) async {
    setState(() => _downloading = true);
    try {
      final export =
          await ref.read(perseveranceRepositoryProvider).exportReport(
                reportType: reportType,
                fileFormat: fileFormat,
                query: _query(period, classId),
              );
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${export.fileName}');
      await file.writeAsBytes(export.bytes, flush: true);
      if (!mounted) return;
      final renderBox = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = renderBox != null && renderBox.hasSize
          ? renderBox.localToGlobal(Offset.zero) & renderBox.size
          : const Rect.fromLTWH(1, 1, 1, 1);
      await ref.read(downloadServiceProvider).saveFileOnDevice(
            export.fileName,
            file,
            sharePositionOrigin: sharePositionOrigin,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحميل التقرير بنجاح')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<PerseveranceOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (selected) => onChanged(selected!),
          ),
        ],
      ),
    );
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}
