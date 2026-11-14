import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/confirm_dialog_widget.dart';
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
    final assignableStudents = state.students;
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

    return Column(
      children: [
        Expanded(
            child: ListView(
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
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_2_outlined,
                        color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('سلوك الطلاب',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    if (!recording)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromHeight(36),
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: state.saving || assignableStudents.isEmpty
                            ? null
                            : onSelectionStarted,
                        icon: const Icon(Icons.checklist_rounded, size: 18),
                        label: const Text('تحديد الطلاب'),
                      ),
                  ],
                ),
                if (recording)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                        'تحديد جميع طلاب الفصل (${state.selectedBehaviorIds.length} محدد)'),
                    value: allSelected,
                    onChanged: state.saving || assignableStudents.isEmpty
                        ? null
                        : (selected) => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleAllBehaviorStudents(selected ?? false),
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
              ...students.map((student) {
                final note = _noteForStudent(state, student);
                final notes = [
                  for (final id in student.behaviorNoteIds)
                    for (final item in state.behaviorNotes)
                      if (item.id == id) item,
                ];
                return _BehaviorStudentCard(
                  student: student,
                  selected: state.selectedBehaviorIds.contains(student.id),
                  enabled: !state.saving,
                  badge: PointBadge(points: student.totalBehaviorPoints),
                  footer: notes.isEmpty
                      ? const Text('لا توجد ملاحظات مسجلة',
                          style:
                              TextStyle(color: Color(0xFF686868), fontSize: 12))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final item in notes)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: behaviorNoteColor(item)
                                      .withValues(alpha: .09),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(item.name,
                                    style: TextStyle(
                                        color: behaviorNoteColor(item),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ),
                          ],
                        ),
                  onAddNote: recording || state.saving
                      ? null
                      : () => _giveBehaviorNote(context, ref,
                          studentName: student.name, studentIds: [student.id]),
                  onTap: state.saving
                      ? null
                      : recording
                          ? () => ref
                              .read(attendanceBehaviorProvider.notifier)
                              .toggleBehaviorStudent(student.id)
                          : () => _showStudentDetails(
                              context, ref, student, notes, note),
                );
              }),
            ],
          ],
        )),
        if (recording)
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Row(children: [
              TextButton(
                onPressed: state.saving
                    ? null
                    : () {
                        ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleAllBehaviorStudents(false);
                        onFinishedRecording();
                      },
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: PrimaryActionButton(
                label:
                    'منح ملاحظة للمحددين (${state.selectedBehaviorIds.length})',
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
              )),
            ]),
          ),
      ],
    );
  }

  Future<void> _showStudentDetails(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
    List<BehaviorNoteModel> notes,
    BehaviorNoteModel? note,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF7FAFA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        Widget actionTile(
            IconData icon, String title, String subtitle, String value) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 21),
                ),
                title: Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                subtitle: Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF758484))),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF879797)),
                onTap: () => Navigator.pop(sheetContext, value),
              ),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    StudentAvatar(name: student.name, radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تفاصيل الطالب',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF758484))),
                        const SizedBox(height: 3),
                        Text(student.name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                      ],
                    )),
                    const SizedBox(width: 8),
                    PointBadge(points: student.totalBehaviorPoints),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE3EEEE))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.auto_awesome_outlined,
                                color: AppColors.primaryColor, size: 19),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('ملاحظات السلوك',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14))),
                            Text('${notes.length}',
                                style: const TextStyle(
                                    color: Color(0xFF758484), fontSize: 12)),
                          ]),
                          const SizedBox(height: 12),
                          if (notes.isEmpty)
                            const Text('لا توجد ملاحظات مسجلة',
                                style: TextStyle(
                                    color: Color(0xFF758484), fontSize: 12))
                          else
                            for (final item in notes)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                    color: behaviorNoteColor(item)
                                        .withValues(alpha: .08),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(children: [
                                  Expanded(
                                      child: Text(item.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700))),
                                  Text(
                                      '${item.signedPoints > 0 ? '+' : ''}${item.signedPoints} نقطة',
                                      style: TextStyle(
                                          color: behaviorNoteColor(item),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800)),
                                ]),
                              ),
                          if (student.behaviorRecordId != null &&
                              student.teacherCanModifyBehavior) ...[
                            const SizedBox(height: 4),
                            Row(children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    fixedSize: const Size.fromHeight(40),
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    foregroundColor: AppColors.primaryColor,
                                    side: const BorderSide(
                                        color: AppColors.primaryColor),
                                  ),
                                  onPressed: () => Navigator.pop(
                                      sheetContext, 'edit-behavior'),
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text('تعديل الملاحظات',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    fixedSize: const Size.fromHeight(40),
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    foregroundColor: attendanceRed,
                                    side:
                                        const BorderSide(color: attendanceRed),
                                  ),
                                  onPressed: () => Navigator.pop(
                                      sheetContext, 'delete-behavior'),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16),
                                  label: const Text('حذف السجل',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ]),
                          ],
                        ]),
                  ),
                  const SizedBox(height: 20),
                  const Text('المتابعة والإجراءات',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  actionTile(Icons.history_rounded, 'سجل سلوك الطالب',
                      'عرض سجل الملاحظات', 'history'),
                  actionTile(Icons.assignment_outlined, 'اتخاذ إجراء',
                      'إضافة إجراء للطالب', 'take-action'),
                  actionTile(Icons.fact_check_outlined, 'الإجراءات المتخذة',
                      'عرض الإجراءات السابقة', 'actions'),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (action != null && context.mounted) {
      await _openBehaviorAction(context, ref, student, note, action);
    }
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
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final changed = selectedNoteIds.length != originalNoteIds.length ||
              !selectedNoteIds.every(originalNoteIds.contains);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .85,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(18, 8, 6, 8),
                      child: Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            tooltip: 'إغلاق',
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'تعديل ملاحظة السلوك',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            student.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'حدد الملاحظات التي تريد الاحتفاظ بها أو إضافتها',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF686868)),
                          ),
                          const SizedBox(height: 14),
                          for (final note in ref
                              .read(attendanceBehaviorProvider)
                              .behaviorNotes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: selectedNoteIds.contains(note.id)
                                    ? AppColors.primaryColor
                                        .withValues(alpha: .06)
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: selectedNoteIds.contains(note.id)
                                        ? AppColors.primaryColor
                                        : const Color(0xFFE6EEEE),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CheckboxListTile(
                                  key:
                                      ValueKey('behavior-edit-note-${note.id}'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  value: selectedNoteIds.contains(note.id),
                                  title: Text(
                                    note.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    'النقاط: ${note.signedPoints > 0 ? '+' : ''}${note.signedPoints}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: behaviorNoteColor(note)),
                                  ),
                                  onChanged: (selected) => setSheetState(() {
                                    if (selected == true) {
                                      selectedNoteIds.add(note.id);
                                    } else {
                                      selectedNoteIds.remove(note.id);
                                    }
                                  }),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: selectedNoteIds.isEmpty || !changed
                              ? null
                              : () => Navigator.of(sheetContext)
                                  .pop(selectedNoteIds),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('حفظ التعديل',
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
    var confirmed = false;
    await showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialogWidget(
        title: 'هل تريد حذف جميع ملاحظات السلوك المسجلة لـ ${student.name}؟',
        onConfirm: () => confirmed = true,
      ),
    );
    if (!confirmed || !context.mounted) return;
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

class _BehaviorStudentCard extends StatelessWidget {
  const _BehaviorStudentCard({
    required this.student,
    required this.selected,
    required this.enabled,
    required this.badge,
    required this.footer,
    required this.onAddNote,
    required this.onTap,
  });

  final AttendanceBehaviorStudent student;
  final bool selected;
  final bool enabled;
  final Widget badge;
  final Widget footer;
  final VoidCallback? onAddNote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: enabled ? 1 : .48,
        child: Material(
          color: selected ? const Color(0xFFF0FCFC) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color:
                  AppColors.primaryColor.withValues(alpha: selected ? 1 : .18),
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (selected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryColor, size: 32)
                      else
                        StudentAvatar(name: student.name, radius: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IntrinsicWidth(child: badge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  footer,
                  if (onAddNote != null)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: OutlinedButton.icon(
                        onPressed: onAddNote,
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size.fromHeight(36),
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('منح ملاحظة'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
    final border = BorderRadius.circular(16);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: border,
                border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: .2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('نقاط الفصل اليوم',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      IntrinsicWidth(child: PointBadge(points: points)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: positivePercent / 100,
                      minHeight: 6,
                      color: attendanceGreen,
                      backgroundColor: attendanceRed.withValues(alpha: .14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('$positivePercent% إيجابي',
                      style: const TextStyle(
                          color: attendanceGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Material(
              color: AppColors.primaryColor.withValues(alpha: .08),
              borderRadius: border,
              child: InkWell(
                borderRadius: border,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BehaviorNotesView()),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt_rounded,
                          color: AppColors.primaryColor),
                      SizedBox(height: 10),
                      Text('ملاحظات السلوك',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
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
