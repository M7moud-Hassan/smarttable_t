import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/data/repositories/perseverance_repository.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class StudentAttendanceHistoryView extends ConsumerStatefulWidget {
  const StudentAttendanceHistoryView({super.key, required this.student});

  final AttendanceBehaviorStudent student;

  @override
  ConsumerState<StudentAttendanceHistoryView> createState() =>
      _StudentAttendanceHistoryViewState();
}

class _StudentAttendanceHistoryViewState
    extends ConsumerState<StudentAttendanceHistoryView> {
  String _period = 'month';

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(
      studentAttendanceHistoryProvider(
        StudentPeriodQuery(widget.student.id, _period),
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: 'سجل حضور الطالب'),
        body: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _AsyncErrorView(
            message: perseveranceErrorMessage(error),
            onRetry: () => ref.invalidate(
              studentAttendanceHistoryProvider(
                StudentPeriodQuery(widget.student.id, _period),
              ),
            ),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              StudentDetailHeader(student: widget.student),
              const SizedBox(height: 18),
              Row(
                children: [
                  CountBadge(
                    count: data.summary.presentPercentage.round(),
                    label: '% حضور',
                    color: attendanceGreen,
                  ),
                  const SizedBox(width: 8),
                  CountBadge(
                    count: data.summary.absentDays,
                    label: 'يوم غياب',
                    color: attendanceRed,
                  ),
                  const SizedBox(width: 8),
                  CountBadge(
                    count: data.summary.lateDays,
                    label: 'يوم تأخر',
                    color: attendanceAmber,
                  ),
                  const SizedBox(width: 8),
                  CountBadge(
                    count: data.summary.permissionDays,
                    label: 'استئذان',
                    color: attendanceNavy,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _PeriodSelector(
                value: _period,
                onChanged: (value) => setState(() => _period = value),
              ),
              const SizedBox(height: 12),
              if (data.entries.isEmpty)
                const _EmptyDetailState(message: 'لا يوجد سجل حضور لهذه الفترة')
              else
                ..._groupAttendanceEntries(data.entries).entries.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AttendanceDayCard(
                          title: group.key,
                          entries: group.value,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<AttendanceHistoryEntry>> _groupAttendanceEntries(
    List<AttendanceHistoryEntry> entries,
  ) {
    final grouped = <String, List<AttendanceHistoryEntry>>{};
    for (final entry in entries) {
      final date = entry.dateHijri.isNotEmpty ? entry.dateHijri : entry.date;
      final title = '${entry.dayName} $date'.trim();
      grouped.putIfAbsent(title, () => []).add(entry);
    }
    return grouped;
  }
}

class _AttendanceDayCard extends StatelessWidget {
  const _AttendanceDayCard({required this.title, required this.entries});

  final String title;
  final List<AttendanceHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: panelBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(
          Icons.calendar_month_outlined,
          color: AppColors.secondryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.secondryColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: entries
            .map(
              (entry) => Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFB4B4B4)),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.sessionLabel,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (entry.startTime.isNotEmpty ||
                              entry.endTime.isNotEmpty)
                            Text(
                              '${entry.startTime} - ${entry.endTime}',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(entry.courseName),
                    const SizedBox(width: 12),
                    AttendanceStatusBadge(status: entry.status),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class StudentBehaviorHistoryView extends ConsumerStatefulWidget {
  const StudentBehaviorHistoryView({super.key, required this.student});

  final AttendanceBehaviorStudent student;

  @override
  ConsumerState<StudentBehaviorHistoryView> createState() =>
      _StudentBehaviorHistoryViewState();
}

class _StudentBehaviorHistoryViewState
    extends ConsumerState<StudentBehaviorHistoryView> {
  String _period = 'month';

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(
      studentBehaviorHistoryProvider(
        StudentPeriodQuery(widget.student.id, _period),
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: 'سجل سلوك الطالب'),
        body: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _AsyncErrorView(
            message: perseveranceErrorMessage(error),
            onRetry: () => ref.invalidate(
              studentBehaviorHistoryProvider(
                StudentPeriodQuery(widget.student.id, _period),
              ),
            ),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              StudentDetailHeader(student: widget.student),
              const SizedBox(height: 16),
              Row(
                children: [
                  CountBadge(
                    count: data.summary.positiveCount,
                    label: 'إيجابي',
                    color: attendanceGreen,
                  ),
                  const SizedBox(width: 8),
                  CountBadge(
                    count: data.summary.negativeCount,
                    label: 'بحاجة لتحسين',
                    color: attendanceAmber,
                  ),
                  const SizedBox(width: 8),
                  CountBadge(
                    count: data.summary.totalPoints,
                    label: 'مجموع النقاط',
                    color: attendanceNavy,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PeriodSelector(
                value: _period,
                onChanged: (value) => setState(() => _period = value),
              ),
              const SizedBox(height: 16),
              if (data.entries.isEmpty)
                const _EmptyDetailState(message: 'لا يوجد سجل سلوك لهذه الفترة')
              else
                ...data.entries
                    .map((entry) => _BehaviorHistoryCard(entry: entry)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BehaviorHistoryCard extends StatelessWidget {
  const _BehaviorHistoryCard({required this.entry});

  final BehaviorHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final positive = entry.totalPoints >= 0;
    final color = positive ? attendanceGreen : attendanceAmber;
    final date = entry.dateHijri.isNotEmpty ? entry.dateHijri : entry.date;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8ED),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              positive
                  ? Icons.sentiment_satisfied_alt_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.notes.isEmpty
                      ? entry.additionalNotes
                      : entry.notes.map((note) => note.name).join('، '),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${entry.dayName} $date • ${entry.sessionLabel}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${entry.totalPoints > 0 ? '+' : ''}${entry.totalPoints} نقاط',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class StudentActionsView extends ConsumerStatefulWidget {
  const StudentActionsView({super.key, required this.student});

  final AttendanceBehaviorStudent student;

  @override
  ConsumerState<StudentActionsView> createState() => _StudentActionsViewState();
}

class _StudentActionsViewState extends ConsumerState<StudentActionsView> {
  String _period = 'month';

  @override
  Widget build(BuildContext context) {
    final query = StudentPeriodQuery(widget.student.id, _period);
    final actions = ref.watch(studentProceduresProvider(query));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: 'الإجراءات المتخذة'),
        body: actions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _AsyncErrorView(
            message: perseveranceErrorMessage(error),
            onRetry: () => ref.invalidate(studentProceduresProvider(query)),
          ),
          data: (items) => ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              StudentDetailHeader(student: widget.student),
              const SizedBox(height: 18),
              _PeriodSelector(
                value: _period,
                onChanged: (value) => setState(() => _period = value),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const _EmptyDetailState(message: 'لا توجد إجراءات مسجلة')
              else
                ...items.map((action) => _ProcedureCard(action: action)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard({required this.action});

  final StudentProcedureModel action;

  @override
  Widget build(BuildContext context) {
    final displayDate = action.dateHijri.isNotEmpty
        ? '${action.dateHijri} (${action.date})'
        : action.date;
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: behaviorOrange, width: 1.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: behaviorOrange, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.title,
                  style: const TextStyle(
                    color: behaviorOrange,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action.sourceLabel.isNotEmpty) Text(action.sourceLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(displayDate),
          if (action.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'السبب: ${action.reason}',
              style: const TextStyle(
                color: attendanceRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TakeStudentActionView extends ConsumerStatefulWidget {
  const TakeStudentActionView({
    super.key,
    required this.student,
    required this.reason,
    required this.source,
    this.recordId,
    this.session,
    this.date,
  });

  final AttendanceBehaviorStudent student;
  final String reason;
  final String source;
  final int? recordId;
  final String? session;
  final String? date;

  @override
  ConsumerState<TakeStudentActionView> createState() =>
      _TakeStudentActionViewState();
}

class _TakeStudentActionViewState extends ConsumerState<TakeStudentActionView> {
  String? _selected;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(procedureTypesProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: 'اتخاذ إجراء'),
        body: types.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _AsyncErrorView(
            message: perseveranceErrorMessage(error),
            onRetry: () => ref.invalidate(procedureTypesProvider),
          ),
          data: (options) {
            final selected = options.any((item) => item.value == _selected)
                ? _selected
                : options.isEmpty
                    ? null
                    : options.first.value;
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              children: [
                StudentDetailHeader(student: widget.student),
                const SizedBox(height: 22),
                Text(
                  widget.reason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: attendanceAmber,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Icon(Icons.alt_route_rounded,
                        color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'اختر نوع الإجراء المناسب للطالب',
                      style: TextStyle(
                        color: AppColors.secondryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (options.isEmpty)
                  const _EmptyDetailState(
                      message: 'لا توجد أنواع إجراءات متاحة')
                else
                  RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (value) => setState(() => _selected = value),
                    child: Column(
                      children: options
                          .map(
                            (option) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selected == option.value
                                      ? AppColors.primaryColor
                                      : const Color(0xFFB8B8B8),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: RadioListTile<String>(
                                value: option.value,
                                title: Text(
                                  option.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                const SizedBox(height: 20),
                PrimaryActionButton(
                  label: _saving ? 'جارٍ الحفظ...' : 'حفظ البيانات',
                  onPressed: selected == null || _saving
                      ? null
                      : () => _save(selected),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _save(String procedureType) async {
    setState(() => _saving = true);
    try {
      await ref.read(perseveranceRepositoryProvider).createProcedure(
            studentId: widget.student.id,
            procedureType: procedureType,
            source: widget.source,
            reason: widget.reason,
            classId: widget.recordId == null ? widget.student.classId : null,
            session: widget.recordId == null ? widget.session : null,
            date: widget.recordId == null ? widget.date : null,
            attendanceRecordId:
                widget.source == 'attendance' ? widget.recordId : null,
            behaviorRecordId:
                widget.source == 'behavior' ? widget.recordId : null,
          );
      ref.invalidate(studentProceduresProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const FeatureSuccessView(
          title: 'تم حفظ الإجراء بنجاح',
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const options = {
    'today': 'اليوم',
    'week': 'هذا الأسبوع',
    'month': 'هذا الشهر',
    'term': 'هذا الفصل',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'الفترة',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF999999)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: options.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (selected) => onChanged(selected!),
            ),
          ),
        ),
      ],
    );
  }
}

class _AsyncErrorView extends StatelessWidget {
  const _AsyncErrorView({required this.message, required this.onRetry});

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

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          const Icon(
            Icons.fact_check_outlined,
            size: 56,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}

class FeatureSuccessView extends StatelessWidget {
  const FeatureSuccessView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(title: ''),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9FAFA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 92,
                    color: AppColors.secondryColor,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: 28,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 190,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('عودة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
