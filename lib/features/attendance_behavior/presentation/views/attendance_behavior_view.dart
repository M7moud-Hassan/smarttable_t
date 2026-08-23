import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_reports_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/behavior_notes_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/student_detail_views.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class AttendanceBehaviorView extends ConsumerStatefulWidget {
  const AttendanceBehaviorView({super.key});

  @override
  ConsumerState<AttendanceBehaviorView> createState() =>
      _AttendanceBehaviorViewState();
}

class _AttendanceBehaviorViewState
    extends ConsumerState<AttendanceBehaviorView> {
  final _searchController = TextEditingController();
  int _sectionIndex = 0;
  int _attendanceMode = 0;
  int _behaviorMode = 0;
  int _reportIndex = 0;
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: FeatureTitleAppBar(
          title: 'المواظبة والسلوك',
          action: IconButton.filled(
            tooltip: 'فلترة',
            onPressed: () {
              if (_sectionIndex == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportFilterView(
                      initialReportIndex: _reportIndex,
                    ),
                  ),
                );
              } else {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AttendanceBehaviorFilterSheet(),
                );
              }
            },
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: FeatureSegmentedControl(
                labels: const ['المواظبة', 'السلوك', 'التقارير والإحصائيات'],
                selectedIndex: _sectionIndex,
                onSelected: (index) {
                  setState(() {
                    _sectionIndex = index;
                    _showSearch = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
            ),
            if (_showSearch && _sectionIndex != 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(
                    () => _searchQuery = value.trim().toLowerCase(),
                  ),
                ),
              ),
            Expanded(child: _buildSection()),
          ],
        ),
        bottomNavigationBar:
            _sectionIndex == 2 ? null : _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildSection() {
    return switch (_sectionIndex) {
      0 => AttendancePanel(
          recording: _attendanceMode == 1,
          searchQuery: _searchQuery,
          onFinishedRecording: () => setState(() => _attendanceMode = 0),
        ),
      1 => BehaviorPanel(
          recording: _behaviorMode == 1,
          searchQuery: _searchQuery,
          onFinishedRecording: () => setState(() => _behaviorMode = 0),
        ),
      _ => AttendanceBehaviorReportsPanel(
          reportIndex: _reportIndex,
          onReportChanged: (index) => setState(() => _reportIndex = index),
        ),
    };
  }

  Widget _buildBottomNavigation() {
    final isAttendance = _sectionIndex == 0;
    final selected = isAttendance ? _attendanceMode : _behaviorMode;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: FloatingActionButton(
              heroTag: 'attendance-behavior-search',
              elevation: 0,
              onPressed: () => setState(() => _showSearch = !_showSearch),
              child: const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FeatureSegmentedControl(
              labels: isAttendance
                  ? const ['قائمة الطلاب', 'تسجيل الحضور']
                  : const ['سلوك الطلاب', 'تسجيل السلوك'],
              selectedIndex: selected,
              onSelected: (index) {
                setState(() {
                  if (isAttendance) {
                    _attendanceMode = index;
                  } else {
                    _behaviorMode = index;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AttendancePanel extends ConsumerWidget {
  const AttendancePanel({
    super.key,
    required this.recording,
    required this.searchQuery,
    required this.onFinishedRecording,
  });

  final bool recording;
  final String searchQuery;
  final VoidCallback onFinishedRecording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceBehaviorProvider);
    if (state.loading && state.students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.students.isEmpty) {
      return _FeatureLoadError(
        message: state.errorMessage!,
        onRetry: () => ref.read(attendanceBehaviorProvider.notifier).load(),
      );
    }
    if (state.filters != null &&
        state.filters!.classes.where((item) => item.id != null).isEmpty) {
      return const _FeatureEmptyState(
        message: 'لا توجد فصول مرتبطة بالمعلم حالياً',
      );
    }
    final students = state.students
        .where((student) => student.name.toLowerCase().contains(searchQuery))
        .toList(growable: false);
    final summary =
        state.attendanceRoster?.summary ?? const AttendanceSummary();
    final allSelected =
        state.selectedAttendanceIds.length == state.students.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
      children: [
        LessonContextHeader(
          date: state.attendanceRoster?.dateHijri.isNotEmpty == true
              ? state.attendanceRoster!.dateHijri
              : state.attendanceRoster?.date ?? '',
          session: state.attendanceRoster?.sessionLabel ?? '',
          className: state.attendanceRoster?.className ?? '',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CountBadge(
              count: summary.present,
              label: 'حاضر',
              color: attendanceGreen,
            ),
            const SizedBox(width: 7),
            CountBadge(
              count: summary.absent,
              label: 'غائب',
              color: attendanceRed,
            ),
            const SizedBox(width: 7),
            CountBadge(
              count: summary.late,
              label: 'متأخر',
              color: attendanceAmber,
            ),
            const SizedBox(width: 7),
            CountBadge(
              count: summary.permission,
              label: 'مستأذن',
              color: attendanceNavy,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.groups_2_outlined, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                recording ? 'تسجيل حالة الطلاب' : 'أسماء الطلاب',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (recording)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تحديد الكل'),
                  Checkbox(
                    value: allSelected,
                    onChanged: (selected) => ref
                        .read(attendanceBehaviorProvider.notifier)
                        .toggleAllAttendanceStudents(selected ?? false),
                  ),
                ],
              ),
          ],
        ),
        if (recording) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<AttendanceStatus>(
            initialValue: state.selectedAttendanceStatus,
            decoration: InputDecoration(
              labelText: 'اختر حالة الحضور للطلاب المحددين',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
            items: AttendanceStatus.values
                .where((status) => status != AttendanceStatus.notRecorded)
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                )
                .toList(growable: false),
            onChanged: (status) => ref
                .read(attendanceBehaviorProvider.notifier)
                .setAttendanceStatus(status!),
          ),
        ],
        const SizedBox(height: 12),
        if (students.isEmpty)
          const _NoSearchResults()
        else
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StudentSummaryCard(
                student: student,
                subtitle: AttendanceStatusBadge(
                  status: student.attendanceStatus,
                ),
                trailing: recording
                    ? Checkbox(
                        value: state.selectedAttendanceIds.contains(student.id),
                        onChanged: (_) => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleAttendanceStudent(student.id),
                      )
                    : _StudentMoreMenu(
                        onSelected: (action) => _openAttendanceAction(
                          context,
                          ref,
                          student,
                          action,
                        ),
                      ),
              ),
            ),
          ),
        if (recording) ...[
          const SizedBox(height: 10),
          PrimaryActionButton(
            label: 'حفظ البيانات',
            onPressed: state.selectedAttendanceIds.isEmpty || state.saving
                ? null
                : () async {
                    try {
                      await ref
                          .read(attendanceBehaviorProvider.notifier)
                          .saveAttendance();
                      if (!context.mounted) return;
                      context.showSnackbarSuccess(
                        'تم حفظ بيانات الحضور بنجاح',
                      );
                      onFinishedRecording();
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(perseveranceErrorMessage(error)),
                        ),
                      );
                    }
                  },
          ),
        ],
      ],
    );
  }

  void _openAttendanceAction(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
    String action,
  ) {
    final Widget page = switch (action) {
      'history' => StudentAttendanceHistoryView(student: student),
      'take-action' => TakeStudentActionView(
          student: student,
          source: 'attendance',
          recordId: student.attendanceRecordId,
          session: ref.read(attendanceBehaviorProvider).selectedSession,
          date: ref.read(attendanceBehaviorProvider).selectedDate,
          reason: student.attendanceStatus == AttendanceStatus.absent
              ? 'غياب بدون عذر'
              : student.attendanceStatus.label,
        ),
      _ => StudentActionsView(student: student),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class BehaviorPanel extends ConsumerWidget {
  const BehaviorPanel({
    super.key,
    required this.recording,
    required this.searchQuery,
    required this.onFinishedRecording,
  });

  final bool recording;
  final String searchQuery;
  final VoidCallback onFinishedRecording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceBehaviorProvider);
    if (state.loading && state.students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.students.isEmpty) {
      return _FeatureLoadError(
        message: state.errorMessage!,
        onRetry: () => ref.read(attendanceBehaviorProvider.notifier).load(),
      );
    }
    if (state.filters != null &&
        state.filters!.classes.where((item) => item.id != null).isEmpty) {
      return const _FeatureEmptyState(
        message: 'لا توجد فصول مرتبطة بالمعلم حالياً',
      );
    }
    final students = state.students
        .where((student) => student.name.toLowerCase().contains(searchQuery))
        .toList(growable: false);
    final allSelected =
        state.selectedBehaviorIds.length == state.students.length;
    final selectedNoteId = state.behaviorNotes.any(
      (note) => note.id == state.selectedBehaviorNoteId,
    )
        ? state.selectedBehaviorNoteId
        : state.behaviorNotes.isEmpty
            ? null
            : state.behaviorNotes.first.id;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
      children: [
        LessonContextHeader(
          date: state.behaviorRoster?.dateHijri.isNotEmpty == true
              ? state.behaviorRoster!.dateHijri
              : state.behaviorRoster?.date ?? '',
          session: state.behaviorRoster?.sessionLabel ?? '',
          className: state.behaviorRoster?.className ?? '',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BehaviorNotesView()),
          ),
          icon: const Icon(Icons.format_list_bulleted_rounded),
          label: const Text('إدارة قائمة ملاحظات السلوك'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.groups_2_outlined, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                recording ? 'تسجيل سلوك الطلاب' : 'أسماء الطلاب',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (recording)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تحديد الكل'),
                  Checkbox(
                    value: allSelected,
                    onChanged: (selected) => ref
                        .read(attendanceBehaviorProvider.notifier)
                        .toggleAllBehaviorStudents(selected ?? false),
                  ),
                ],
              ),
          ],
        ),
        if (recording && state.behaviorNotes.isNotEmpty) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: selectedNoteId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'اختر ملاحظة السلوك',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
            items: state.behaviorNotes
                .map(
                  (note) => DropdownMenuItem(
                    value: note.id,
                    child: Text('${note.name} (${note.points} نقاط)'),
                  ),
                )
                .toList(growable: false),
            onChanged: (noteId) => ref
                .read(attendanceBehaviorProvider.notifier)
                .selectBehaviorNote(noteId!),
          ),
        ],
        const SizedBox(height: 12),
        if (students.isEmpty)
          const _NoSearchResults()
        else
          ...students.map((student) {
            final note = _noteForStudent(state, student);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StudentSummaryCard(
                student: student,
                subtitle: note == null
                    ? const Text('لا توجد ملاحظة مسجلة')
                    : BehaviorNoteBadge(note: note),
                trailing: recording
                    ? Checkbox(
                        value: state.selectedBehaviorIds.contains(student.id),
                        onChanged: (_) => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleBehaviorStudent(student.id),
                      )
                    : _StudentMoreMenu(
                        behavior: true,
                        onSelected: (action) => _openBehaviorAction(
                          context,
                          ref,
                          student,
                          note,
                          action,
                        ),
                      ),
              ),
            );
          }),
        if (recording) ...[
          const SizedBox(height: 10),
          PrimaryActionButton(
            label: 'حفظ البيانات',
            onPressed: state.selectedBehaviorIds.isEmpty ||
                    selectedNoteId == null ||
                    state.saving
                ? null
                : () async {
                    if (state.selectedBehaviorNoteId != selectedNoteId) {
                      ref
                          .read(attendanceBehaviorProvider.notifier)
                          .selectBehaviorNote(selectedNoteId);
                    }
                    try {
                      await ref
                          .read(attendanceBehaviorProvider.notifier)
                          .saveBehaviorAssignment();
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(perseveranceErrorMessage(error)),
                        ),
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    onFinishedRecording();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FeatureSuccessView(
                          title: 'تم إضافة ملاحظة السلوك بنجاح',
                        ),
                      ),
                    );
                  },
          ),
        ],
      ],
    );
  }

  BehaviorNoteModel? _noteForStudent(
    AttendanceBehaviorState state,
    AttendanceBehaviorStudent student,
  ) {
    for (final note in state.behaviorNotes) {
      if (note.id == student.behaviorNoteId) return note;
    }
    return null;
  }

  void _openBehaviorAction(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
    BehaviorNoteModel? note,
    String action,
  ) {
    final Widget page = switch (action) {
      'history' => StudentBehaviorHistoryView(student: student),
      'take-action' => TakeStudentActionView(
          student: student,
          source: 'behavior',
          recordId: student.behaviorRecordId,
          session: ref.read(attendanceBehaviorProvider).selectedSession,
          date: ref.read(attendanceBehaviorProvider).selectedDate,
          reason: note?.name ?? 'ملاحظة سلوكية',
        ),
      _ => StudentActionsView(student: student),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _StudentMoreMenu extends StatelessWidget {
  const _StudentMoreMenu({
    required this.onSelected,
    this.behavior = false,
  });

  final ValueChanged<String> onSelected;
  final bool behavior;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'خيارات الطالب',
      onSelected: onSelected,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'history',
          child: Text(behavior ? 'سجل سلوك الطالب' : 'سجل حضور الطالب'),
        ),
        const PopupMenuItem(
          value: 'take-action',
          child: Text('اتخاذ إجراء'),
        ),
        const PopupMenuItem(
          value: 'actions',
          child: Text('الإجراءات المتخذة'),
        ),
      ],
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 52, color: AppColors.primaryColor),
          SizedBox(height: 10),
          Text('لا توجد نتائج مطابقة'),
        ],
      ),
    );
  }
}

class AttendanceBehaviorFilterSheet extends ConsumerStatefulWidget {
  const AttendanceBehaviorFilterSheet({super.key});

  @override
  ConsumerState<AttendanceBehaviorFilterSheet> createState() =>
      _AttendanceBehaviorFilterSheetState();
}

class _AttendanceBehaviorFilterSheetState
    extends ConsumerState<AttendanceBehaviorFilterSheet> {
  int? _classId;
  String? _session;
  String? _date;

  @override
  void initState() {
    super.initState();
    final state = ref.read(attendanceBehaviorProvider);
    _classId = state.selectedClassId;
    _session = state.selectedSession;
    _date = state.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final featureState = ref.watch(attendanceBehaviorProvider);
    final filters = featureState.filters;
    final classes =
        filters?.classes.where((item) => item.id != null).toList() ?? const [];
    final sessions = filters?.sessions ?? const [];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'فلترة القائمة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: classes.any((item) => item.id == _classId)
                    ? _classId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'الفصل',
                  border: OutlineInputBorder(),
                ),
                items: classes
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          item.studentsCount > 0
                              ? '${item.name} (${item.studentsCount})'
                              : item.name,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _classId = value),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: sessions.any((item) => item.value == _session)
                    ? _session
                    : null,
                decoration: const InputDecoration(
                  labelText: 'الحصة',
                  border: OutlineInputBorder(),
                ),
                items: sessions
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.value,
                        child: Text(item.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _session = value),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(_date?.isNotEmpty == true ? _date! : 'تاريخ اليوم'),
                onPressed: _pickDate,
              ),
              const SizedBox(height: 20),
              PrimaryActionButton(
                label: featureState.loading ? 'جارٍ التحميل...' : 'تطبيق',
                onPressed: _classId == null ||
                        _session == null ||
                        featureState.loading
                    ? null
                    : () async {
                        try {
                          await ref
                              .read(attendanceBehaviorProvider.notifier)
                              .changeContext(
                                classId: _classId!,
                                session: _session!,
                                date: _date,
                              );
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(perseveranceErrorMessage(error)),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_date ?? '') ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null) return;
    setState(() {
      _date = '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    });
  }
}

class _FeatureLoadError extends StatelessWidget {
  const _FeatureLoadError({required this.message, required this.onRetry});

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

class _FeatureEmptyState extends StatelessWidget {
  const _FeatureEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
