import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/widgets/sliding_dropdown.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/student_detail_views.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_state_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

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
    final summary =
        state.attendanceRoster?.summary ?? const AttendanceSummary();
    final attendanceStates =
        state.filters?.allowedAttendanceStates ?? const <PerseveranceOption>[];
    final editableStudents =
        state.students.where((student) => student.canModifyAttendance).toList();
    final allSelected = editableStudents.isNotEmpty &&
        editableStudents.every(
            (student) => state.selectedAttendanceIds.contains(student.id));

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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (recording)
              Flexible(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(child: Text('تحديد الكل')),
                  Checkbox(
                    value: allSelected,
                    onChanged: state.saving || editableStudents.isEmpty
                        ? null
                        : (selected) => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleAllAttendanceStudents(selected ?? false),
                  ),
                ],
              )),
          ],
        ),
        if (recording) ...[
          const SizedBox(height: 8),
          if (attendanceStates.isEmpty)
            const FeatureEmptyState(
              message: 'لا توجد حالات حضور متاحة لهذا المعلم',
            )
          else
            SlidingDropdown<AttendanceStatus>(
              value: state.selectedAttendanceStatus,
              menuMaxHeight: 180,
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
              items: attendanceStates
                  .map(
                    (option) => DropdownMenuItem(
                      value: AttendanceStatus.tryFromApi(option.value)!,
                      child: Text(
                        option.label.isEmpty
                            ? AttendanceStatus.fromApi(option.value).label
                            : option.label,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (status) {
                if (status == null) return;
                ref
                    .read(attendanceBehaviorProvider.notifier)
                    .setAttendanceStatus(status);
              },
            ),
        ],
        const SizedBox(height: 12),
        if (students.isEmpty)
          const NoSearchResults()
        else ...[
          ...students.map((student) {
            final selected = state.selectedAttendanceIds.contains(student.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClassroomStudentCard(
                student: student,
                selected: selected,
                accentColor: attendanceStatusColor(student.attendanceStatus),
                footer: AttendanceStatusBadge(
                  status: student.attendanceStatus,
                ),
                badge: student.attendanceNote.trim().isEmpty
                    ? null
                    : Container(
                        width: 25,
                        height: 25,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0FCFC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: AppColors.secondryColor,
                        ),
                      ),
                menu: recording
                    ? null
                    : StudentMoreMenu(
                        canModifyAttendance: student.canModifyAttendance,
                        onSelected: (action) => _openAttendanceAction(
                          context,
                          ref,
                          student,
                          action,
                        ),
                      ),
                details: recording && selected
                    ? _AttendanceNoteEditor(
                        studentId: student.id,
                        noteCodes: state.attendanceNoteCodes,
                        draft: state.attendanceNoteDrafts[student.id],
                        status: state.selectedAttendanceStatus,
                        onChanged: (draft) => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .setAttendanceNoteDraft(student.id, draft),
                      )
                    : _SavedAttendanceDetails(student: student),
                onTap: state.saving || !student.canModifyAttendance
                    ? null
                    : recording
                        ? () => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .toggleAttendanceStudent(student.id)
                        : () =>
                            _showAttendanceEditDialog(context, ref, student),
              ),
            );
          }),
        ],
        if (recording) ...[
          const SizedBox(height: 10),
          PrimaryActionButton(
            label: 'حفظ البيانات',
            onPressed: state.selectedAttendanceIds.isEmpty ||
                    state.selectedAttendanceStatus == null ||
                    state.saving
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
    if (action == 'edit-attendance') {
      _showAttendanceEditDialog(context, ref, student);
      return;
    }
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

  Future<void> _showAttendanceEditDialog(
    BuildContext context,
    WidgetRef ref,
    AttendanceBehaviorStudent student,
  ) async {
    if (!student.canModifyAttendance ||
        ref.read(attendanceBehaviorProvider).saving) {
      return;
    }
    final attendanceStates =
        ref.read(attendanceBehaviorProvider).filters?.allowedAttendanceStates ??
            const <PerseveranceOption>[];
    if (attendanceStates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد حالات حضور متاحة لهذا المعلم'),
        ),
      );
      return;
    }
    final allowedStatuses = attendanceStates
        .map((option) => AttendanceStatus.tryFromApi(option.value)!)
        .toList(growable: false);
    var selectedStatus = allowedStatuses.contains(student.attendanceStatus)
        ? student.attendanceStatus
        : allowedStatuses.first;
    var noteDraft = AttendanceNoteDraft(
      note: student.attendanceNote,
      noteCode: student.attendanceNoteCode.isEmpty
          ? null
          : student.attendanceNoteCode,
      excuseStatus: student.excuseStatus.isEmpty ? null : student.excuseStatus,
    );
    final status = await showDialog<AttendanceStatus>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('تعديل حالة الحضور'),
          content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...attendanceStates.map(
                    (option) {
                      final status = AttendanceStatus.tryFromApi(option.value)!;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          option.label.isEmpty ? status.label : option.label,
                        ),
                        leading: Icon(
                          selectedStatus == status
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: selectedStatus == status
                              ? attendanceStatusColor(status)
                              : Colors.grey,
                        ),
                        onTap: () => setDialogState(() {
                          selectedStatus = status;
                          noteDraft = AttendanceNoteDraft(note: noteDraft.note);
                        }),
                      );
                    },
                  ),
                  _AttendanceNoteEditor(
                    studentId: student.id,
                    noteCodes: ref
                        .read(attendanceBehaviorProvider)
                        .attendanceNoteCodes,
                    draft: noteDraft,
                    status: selectedStatus,
                    onChanged: (draft) =>
                        setDialogState(() => noteDraft = draft),
                  ),
                ],
              ))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(selectedStatus),
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
    if (status == null) return;

    try {
      await ref
          .read(attendanceBehaviorProvider.notifier)
          .updateStudentAttendance(
              studentId: student.id, status: status, note: noteDraft);
      if (!context.mounted) return;
      context.showSnackbarSuccess('تم تعديل حالة الحضور بنجاح');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }
}

class _AttendanceNoteEditor extends StatelessWidget {
  const _AttendanceNoteEditor({
    required this.studentId,
    required this.noteCodes,
    required this.draft,
    required this.status,
    required this.onChanged,
  });

  final int studentId;
  final List<PerseveranceOption> noteCodes;
  final AttendanceNoteDraft? draft;
  final AttendanceStatus? status;
  final ValueChanged<AttendanceNoteDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = noteCodes
        .where((option) =>
            option.attendance.isEmpty || option.attendance == status?.apiValue)
        .toList();
    final selected =
        options.where((option) => option.value == draft?.noteCode).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ملاحظة المواظبة',
              key: ValueKey('attendance-note-student-$studentId'),
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SlidingDropdown<String>(
            value: selected?.value ?? '',
            decoration: const InputDecoration(
                isDense: true, border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: '', child: Text('بدون ملاحظة')),
              ...options.map((option) => DropdownMenuItem(
                  value: option.value, child: Text(option.label))),
            ],
            onChanged: (value) {
              final option =
                  options.where((option) => option.value == value).firstOrNull;
              onChanged(AttendanceNoteDraft(
                note: draft?.note ?? '',
                noteCode: option?.value,
                excuseStatus: option?.excusable == true ? 'unexcused' : null,
              ));
            },
          ),
          if (selected?.excusable == true) ...[
            const SizedBox(height: 8),
            const Text('حالة العذر'),
            SlidingDropdown<String>(
              value: ['excused', 'unexcused'].contains(draft?.excuseStatus)
                  ? draft!.excuseStatus
                  : 'unexcused',
              decoration: const InputDecoration(
                  isDense: true, border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'unexcused', child: Text('بدون عذر')),
                DropdownMenuItem(value: 'excused', child: Text('بعذر')),
              ],
              onChanged: (value) => onChanged(AttendanceNoteDraft(
                note: draft?.note ?? '',
                noteCode: draft?.noteCode,
                excuseStatus: value,
              )),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('attendance-note-$studentId'),
            initialValue: draft?.note ?? '',
            onChanged: (value) => onChanged(AttendanceNoteDraft(
              note: value,
              noteCode: selected?.value,
              excuseStatus: selected?.excusable == true
                  ? draft?.excuseStatus ?? 'unexcused'
                  : null,
            )),
            maxLines: 2,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
                hintText: 'ملاحظات (اختياري)', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class _SavedAttendanceDetails extends StatelessWidget {
  const _SavedAttendanceDetails({required this.student});

  final AttendanceBehaviorStudent student;

  @override
  Widget build(BuildContext context) {
    final labels = [
      student.attendanceNoteCodeLabel.trim(),
      student.excuseStatusLabel.trim()
    ].where((label) => label.isNotEmpty).toList();
    final note = student.attendanceNote.trim();
    if (labels.isEmpty && note.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labels.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: labels
                  .map((label) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondryColor,
                            )),
                      ))
                  .toList(growable: false),
            ),
          if (note.isNotEmpty) ...[
            if (labels.isNotEmpty) const SizedBox(height: 6),
            Text(note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, height: 1.5, color: Color(0xFF58656B))),
          ],
        ],
      ),
    );
  }
}
