import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/widgets/sliding_dropdown.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
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
          SlidingDropdown<int>(
            value: selectedNoteId,
            menuMaxHeight: 240,
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
          const NoSearchResults()
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
                        onChanged: student.behaviorRecordId != null &&
                                !student.teacherCanModifyBehavior
                            ? null
                            : (_) => ref
                                .read(attendanceBehaviorProvider.notifier)
                                .toggleBehaviorStudent(student.id),
                      )
                    : StudentMoreMenu(
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
                        subtitle: Text('${behaviorNote.points} نقاط'),
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
