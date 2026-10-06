import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/service/download_service.dart';
import 'package:smart_table_app/core/widgets/sliding_dropdown.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/data/repositories/perseverance_repository.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_report_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class ReportFilterView extends ConsumerStatefulWidget {
  const ReportFilterView({
    super.key,
    required this.initialReportIndex,
    this.initialSession,
  });

  final int initialReportIndex;
  final String? initialSession;

  @override
  ConsumerState<ReportFilterView> createState() => _ReportFilterViewState();
}

class _ReportFilterViewState extends ConsumerState<ReportFilterView> {
  String? _reportType;
  String? _period;
  String? _classId;
  String? _studentId;
  String? _format;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    final query = ref.read(widget.initialReportIndex == 0
        ? attendanceReportQueryProvider
        : behaviorReportQueryProvider);
    _period = query.period;
    _classId = query.classId?.toString();
    _studentId = query.studentId?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final asyncOptions = ref.watch(reportOptionsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: 'فلتر'),
        body: asyncOptions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ReportError(
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
    final selectedClassId = int.tryParse(classValue);
    final studentQuery = selectedClassId == null
        ? null
        : (classId: selectedClassId, session: widget.initialSession);
    final studentOptions = selectedClassId == null
        ? null
        : ref.watch(reportStudentsProvider(studentQuery!));
    final selectedStudentId = studentOptions?.asData?.value.any(
              (student) => student.id.toString() == _studentId,
            ) ==
            true
        ? _studentId
        : null;

    if (reportType == null || period == null || format == null) {
      return const EmptyReport(message: 'خيارات التقرير غير متاحة حالياً');
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
          onChanged: (value) => setState(() {
            _classId = value;
            _studentId = null;
          }),
        ),
        if (selectedClassId == null)
          const _FilterDropdown(
            label: 'اسم الطالب',
            value: '',
            options: [PerseveranceOption(value: '', label: 'كل الطلاب')],
            helperText: 'اختر فصلاً لتحديد طالب',
            onChanged: null,
          )
        else
          _buildStudentDropdown(studentQuery!, studentOptions!),
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
                  studentId: selectedStudentId,
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
                          studentId: selectedStudentId,
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

  Widget _buildStudentDropdown(
    ReportStudentsQuery query,
    AsyncValue<List<AttendanceBehaviorStudent>> students,
  ) {
    return students.when(
      loading: () => const _FilterDropdown(
        label: 'اسم الطالب',
        value: '',
        options: [PerseveranceOption(value: '', label: 'جارٍ تحميل الطلاب...')],
        onChanged: null,
      ),
      error: (_, __) => const _FilterDropdown(
        label: 'اسم الطالب',
        value: '',
        options: [PerseveranceOption(value: '', label: 'كل الطلاب')],
        onChanged: null,
      ),
      data: (items) {
        final options = <PerseveranceOption>[
          const PerseveranceOption(value: '', label: 'كل الطلاب'),
          for (final student in items)
            PerseveranceOption(
              value: student.id.toString(),
              label: student.name,
            ),
        ];
        final value = _validOption(_studentId, options) ?? '';
        return _FilterDropdown(
          key: ValueKey('student-${query.classId}'),
          label: 'اسم الطالب',
          value: value,
          options: options,
          onChanged: items.isEmpty
              ? null
              : (selected) => setState(() => _studentId = selected),
        );
      },
    );
  }

  ReportQuery _query(String period, String classId, String? studentId) {
    final parsedClassId = int.tryParse(classId);
    return ReportQuery(
      classId: parsedClassId,
      studentId: parsedClassId == null ? null : int.tryParse(studentId ?? ''),
      period: period,
    );
  }

  void _preview({
    required String reportType,
    required String period,
    required String classId,
    required String? studentId,
  }) {
    final query = _query(period, classId, studentId);
    if (reportType == 'attendance' || reportType == 'combined') {
      ref.read(attendanceReportQueryProvider.notifier).state = query;
    }
    if (reportType == 'behavior' || reportType == 'combined') {
      ref.read(behaviorReportQueryProvider.notifier).state = query;
    }
    Navigator.of(context).pop(reportType);
  }

  Future<void> _download({
    required String reportType,
    required String fileFormat,
    required String period,
    required String classId,
    required String? studentId,
  }) async {
    setState(() => _downloading = true);
    try {
      final export =
          await ref.read(perseveranceRepositoryProvider).exportReport(
                reportType: reportType,
                fileFormat: fileFormat,
                query: _query(period, classId, studentId),
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
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
  });

  final String label;
  final String value;
  final List<PerseveranceOption> options;
  final ValueChanged<String>? onChanged;
  final String? helperText;

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
          SlidingDropdown<String>(
            value: value,
            menuMaxHeight: 280,
            decoration: InputDecoration(
              helperText: helperText,
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
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onChanged == null
                ? null
                : (selected) {
                    if (selected != null) onChanged!(selected);
                  },
          ),
        ],
      ),
    );
  }
}
