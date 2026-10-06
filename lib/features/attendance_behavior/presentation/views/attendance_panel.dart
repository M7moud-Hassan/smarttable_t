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
        else
          ...students.map(
            (student) {
              final selected = state.selectedAttendanceIds.contains(student.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    StudentSummaryCard(
                      student: student,
                      subtitle: AttendanceStatusBadge(
                        status: student.attendanceStatus,
                      ),
                      attendanceNote: !recording
                          ? student.attendanceNote
                          : selected
                              ? state.attendanceNoteDrafts
                                      .containsKey(student.id)
                                  ? state.attendanceNoteDrafts[student.id]!.note
                                  : student.attendanceNote
                              : null,
                      trailing: recording
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) => ref
                                  .read(attendanceBehaviorProvider.notifier)
                                  .toggleAttendanceStudent(student.id),
                            )
                          : StudentMoreMenu(
                              onSelected: (action) => _openAttendanceAction(
                                context,
                                ref,
                                student,
                                action,
                              ),
                            ),
                    ),
                    if (recording && selected)
                      _AttendanceNoteEditor(
                        studentId: student.id,
                        noteCodes: state.attendanceNoteCodes,
                        draft: state.attendanceNoteDrafts[student.id],
                        onSelect: (value) {
                          final notifier =
                              ref.read(attendanceBehaviorProvider.notifier);
                          final draft = state.attendanceNoteDrafts[student.id];
                          if (value == _noAttendanceNote) {
                            notifier.setAttendanceNoteCode(
                              studentId: student.id,
                              noteCode: null,
                            );
                            return;
                          }
                          if (value == _customAttendanceNote) {
                            notifier.setAttendanceNoteCode(
                              studentId: student.id,
                              noteCode: null,
                              note: draft?.note ?? '',
                              isCustom: true,
                            );
                            return;
                          }
                          for (final option in state.attendanceNoteCodes) {
                            if (option.value != value) continue;
                            notifier.setAttendanceNoteCode(
                              studentId: student.id,
                              noteCode: option.value,
                              note: option.label,
                            );
                            return;
                          }
                        },
                        onTextChanged: (note) => ref
                            .read(attendanceBehaviorProvider.notifier)
                            .setAttendanceNoteText(
                              studentId: student.id,
                              note: note,
                            ),
                      ),
                  ],
                ),
              );
            },
          ),
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
    final status = await showDialog<AttendanceStatus>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('تعديل حالة الحضور'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: attendanceStates.map(
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
                  onTap: () => setDialogState(
                    () => selectedStatus = status,
                  ),
                );
              },
            ).toList(growable: false),
          ),
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
    if (status == null || status == student.attendanceStatus) return;

    try {
      await ref
          .read(attendanceBehaviorProvider.notifier)
          .updateStudentAttendance(studentId: student.id, status: status);
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

const _customAttendanceNote = '__custom_attendance_note__';
const _noAttendanceNote = '__no_attendance_note__';

class _AttendanceNoteEditor extends StatelessWidget {
  const _AttendanceNoteEditor({
    required this.studentId,
    required this.noteCodes,
    required this.draft,
    required this.onSelect,
    required this.onTextChanged,
  });

  final int studentId;
  final List<PerseveranceOption> noteCodes;
  final AttendanceNoteDraft? draft;
  final ValueChanged<String?> onSelect;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = draft?.noteCode ??
        (draft?.isCustom == true ? _customAttendanceNote : null);
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: _noAttendanceNote,
        child: Text('بدون ملاحظة'),
      ),
      ...noteCodes.map(
        (option) => DropdownMenuItem(
          value: option.value,
          child: Text(option.label),
        ),
      ),
      const DropdownMenuItem(
        value: _customAttendanceNote,
        child: Text('كتابة ملاحظة'),
      ),
    ];

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 18, end: 18, top: 8),
      child: Column(
        children: [
          SlidingDropdown<String>(
            value: selectedValue,
            hint: const Text('ملاحظة المواظبة (اختياري)'),
            menuMaxHeight: 220,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
            items: items,
            onChanged: onSelect,
          ),
          if (draft?.isCustom == true) ...[
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('attendance-note-$studentId'),
              initialValue: draft?.note ?? '',
              onChanged: onTextChanged,
              maxLines: 2,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اكتب الملاحظة',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  tooltip: 'مسح الملاحظة',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onTextChanged(''),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
