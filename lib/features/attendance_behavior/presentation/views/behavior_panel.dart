import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/behavior_note_picker_sheet.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/behavior_notes_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/student_detail_views.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_state_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class BehaviorPanel extends ConsumerWidget {
  const BehaviorPanel({
    super.key,
    required this.recording,
    required this.searchQuery,
    required this.onFinishedRecording,
    required this.onSelectionStarted,
  });

  final bool recording;
  final String searchQuery;
  final VoidCallback onFinishedRecording;
  final VoidCallback onSelectionStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceBehaviorProvider);
    if (state.loading && state.students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.students.isEmpty) {
      return FeatureLoadError(
        message: state.errorMessage!,
        onRetry: () => ref.read(attendanceBehaviorProvider.notifier).load(),
      );
    }
    if (state.filters != null &&
        state.filters!.classes.where((item) => item.id != null).isEmpty) {
      return const FeatureEmptyState(
        message: 'لا توجد فصول مرتبطة بالمعلم حالياً',
      );
    }
    final students = state.students
        .where((student) => student.name.toLowerCase().contains(searchQuery))
        .toList(growable: false);
    final assignableStudents = state.students
        .where(
          (student) =>
              student.behaviorRecordId == null ||
              student.teacherCanModifyBehavior,
        )
        .toList(growable: false);
    final allSelected = assignableStudents.isNotEmpty &&
        assignableStudents.every(
          (student) => state.selectedBehaviorIds.contains(student.id),
        );
    final totalPoints = state.students.fold<int>(
      0,
      (sum, student) => sum + student.totalBehaviorPoints,
    );
    final positiveNoteIds = state.behaviorNotes
        .where((note) => note.type == BehaviorNoteType.positive)
        .map((note) => note.id)
        .toSet();
    final recordedNoteIds = state.students
        .expand((student) => student.behaviorNoteIds)
        .toList(growable: false);
    final positiveCount =
        recordedNoteIds.where(positiveNoteIds.contains).length;
    final positivePercent = recordedNoteIds.isEmpty
        ? 0
        : ((positiveCount / recordedNoteIds.length) * 100).round();

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
        _BehaviorScoreBanner(
          points: totalPoints,
          positivePercent: positivePercent,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BehaviorNotesView()),
            ),
            icon: const Icon(Icons.tune_rounded, size: 19),
            label: const Text('إدارة قائمة ملاحظات السلوك'),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.groups_2_outlined, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'سلوك الطلاب',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تحديد الكل'),
                  Checkbox(
                    value: allSelected,
                    onChanged: state.saving || assignableStudents.isEmpty
                        ? null
                        : (selected) {
                            onSelectionStarted();
                            ref.read(attendanceBehaviorProvider.notifier)
                                .toggleAllBehaviorStudents(selected ?? false);
                          },
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (students.isEmpty)
          const NoSearchResults()
        else ...[
          ...[
            _WholeClassBehaviorCard(
              points: totalPoints,
              enabled: assignableStudents.isNotEmpty && !state.saving,
              onTap: () => _giveBehaviorNote(
                context,
                ref,
                studentName: 'الفصل كاملاً',
                studentIds: assignableStudents.map((student) => student.id),
              ),
            ),
            const SizedBox(height: 12),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .58,
            ),
            itemBuilder: (_, index) {
              final student = students[index];
              final note = _noteForStudent(state, student);
              final canChange = student.behaviorRecordId == null ||
                  student.teacherCanModifyBehavior;
              return ClassroomStudentCard(
                student: student,
                selected: state.selectedBehaviorIds.contains(student.id),
                enabled: !state.saving,
                badge: PointBadge(points: student.totalBehaviorPoints),
                footer: Text(
                  note?.name ?? 'منح ملاحظة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: note == null
                        ? AppColors.secondryColor
                        : behaviorNoteColor(note),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                menu: StudentMoreMenu(
                  behavior: true,
                  canModifyBehavior: student.behaviorRecordId != null &&
                      student.teacherCanModifyBehavior,
                  onSelected: (action) => _openBehaviorAction(
                    context,
                    ref,
                    student,
                    note,
                    action,
                  ),
                ),
                onTap: state.saving
                    ? null
                    : recording && canChange
                        ? () => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleBehaviorStudent(student.id)
                        : canChange
                            ? () => _giveBehaviorNote(
                                  context,
                                  ref,
                                  studentName: student.name,
                                  studentIds: [student.id],
                                )
                            : () => _showReadOnlyMessage(context),
              );
            },
          ),
        ],
        if (recording) ...[
          const SizedBox(height: 10),
          PrimaryActionButton(
            label: 'منح ملاحظة للمحددين (${state.selectedBehaviorIds.length})',
            onPressed: state.selectedBehaviorIds.isEmpty || state.saving
                ? null
                : () async {
                    final saved = await _giveBehaviorNote(
                      context,
                      ref,
                      studentName: 'الطلاب المحددون',
                      studentIds: state.selectedBehaviorIds.toList(),
                    );
                    if (!saved || !context.mounted) return;
                    ref
                        .read(attendanceBehaviorProvider.notifier)
                        .toggleAllBehaviorStudents(false);
                    onFinishedRecording();
                  },
          ),
        ],
      ],
    );
  }

  Future<bool> _giveBehaviorNote(
    BuildContext context,
    WidgetRef ref, {
    required String studentName,
    required Iterable<int> studentIds,
  }) async {
    final state = ref.read(attendanceBehaviorProvider);
    if (state.behaviorNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد ملاحظات سلوك متاحة')),
      );
      return false;
    }
    final note = await showBehaviorNotePickerSheet(
      context,
      studentName: studentName,
      notes: state.behaviorNotes,
    );
    if (note == null || !context.mounted) return false;
    try {
      await ref.read(attendanceBehaviorProvider.notifier).assignBehaviorNote(
            studentIds: studentIds,
            noteId: note.id,
          );
      if (!context.mounted) return false;
      context.showSnackbarSuccess(
        'تم منح ${note.name} إلى $studentName',
      );
      return true;
    } catch (error) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
      return false;
    }
  }

  void _showReadOnlyMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الملاحظة غير قابلة للتعديل حسب صلاحيات المعلم'),
      ),
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

  Future<void> _openBehaviorAction(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
    BehaviorNoteModel? note,
    String action,
  ) async {
    if (action == 'edit-behavior') {
      await _showBehaviorEditDialog(context, ref, student);
      return;
    }
    if (action == 'delete-behavior') {
      await _deleteBehaviorRecord(context, ref, student);
      return;
    }
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

  Future<void> _showBehaviorEditDialog(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
  ) async {
    final originalNoteIds = student.behaviorNoteIds.toSet();
    final selectedNoteIds = {...originalNoteIds};
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('تعديل ملاحظة السلوك'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .55,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ref
                    .read(attendanceBehaviorProvider)
                    .behaviorNotes
                    .map(
                      (behaviorNote) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: selectedNoteIds.contains(behaviorNote.id),
                        title: Text(behaviorNote.name),
                        subtitle: Text('${behaviorNote.signedPoints} نقاط'),
                        secondary: Icon(
                          behaviorIcon(behaviorNote.iconKey),
                          color: behaviorNoteColor(behaviorNote),
                        ),
                        onChanged: (selected) => setDialogState(() {
                          if (selected == true) {
                            selectedNoteIds.add(behaviorNote.id);
                          } else {
                            selectedNoteIds.remove(behaviorNote.id);
                          }
                        }),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: selectedNoteIds.isEmpty
                  ? null
                  : () => Navigator.of(dialogContext).pop(selectedNoteIds),
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
    if (result == null ||
        (result.length == originalNoteIds.length &&
            result.every(originalNoteIds.contains))) {
      return;
    }
    try {
      await ref.read(attendanceBehaviorProvider.notifier).updateStudentBehavior(
            studentId: student.id,
            noteIds: result.toList(growable: false),
          );
      if (!context.mounted) return;
      context.showSnackbarSuccess('تم تعديل ملاحظة السلوك بنجاح');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }

  Future<void> _deleteBehaviorRecord(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('حذف ملاحظة السلوك'),
        content: Text('هل تريد حذف ملاحظة ${student.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'حذف',
              style: TextStyle(color: attendanceRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(attendanceBehaviorProvider.notifier)
          .deleteStudentBehaviorRecord(student.id);
      if (!context.mounted) return;
      context.showSnackbarSuccess('تم حذف ملاحظة السلوك بنجاح');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }
}

class _BehaviorScoreBanner extends StatelessWidget {
  const _BehaviorScoreBanner({
    required this.points,
    required this.positivePercent,
  });

  final int points;
  final int positivePercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: .2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'نقاط الفصل اليوم',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              PointBadge(points: points),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: positivePercent / 100,
                    minHeight: 8,
                    color: attendanceGreen,
                    backgroundColor: attendanceRed.withValues(alpha: .14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$positivePercent% إيجابي',
                style: const TextStyle(
                  color: attendanceGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WholeClassBehaviorCard extends StatelessWidget {
  const _WholeClassBehaviorCard({
    required this.points,
    required this.enabled,
    required this.onTap,
  });

  final int points;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Material(
        color: AppColors.secondryColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_2_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الفصل كاملاً',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'امنح الملاحظة نفسها لجميع الطلاب',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                PointBadge(points: points),
                const SizedBox(width: 7),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
