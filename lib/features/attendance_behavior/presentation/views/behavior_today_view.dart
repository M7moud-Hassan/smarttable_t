import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class BehaviorTodayView extends ConsumerWidget {
  const BehaviorTodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceBehaviorProvider);
    final noteById = {for (final note in state.behaviorNotes) note.id: note};
    final entries =
        <({AttendanceBehaviorStudent student, BehaviorNoteModel note})>[
      for (final student in state.students)
        for (final noteId in student.behaviorNoteIds)
          if (noteById[noteId] != null)
            (student: student, note: noteById[noteId]!),
    ];
    final positiveCount = entries
        .where((entry) => entry.note.type == BehaviorNoteType.positive)
        .length;
    final improvementCount = entries.length - positiveCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBFB),
        appBar: const FeatureTitleAppBar(title: 'سجل الحصة'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Text(
              '${state.behaviorRoster?.className ?? ''} · '
              '${state.behaviorRoster?.sessionLabel ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _TodayCount(
                  count: entries.length,
                  label: 'ملاحظة',
                  color: AppColors.secondryColor,
                ),
                const SizedBox(width: 9),
                _TodayCount(
                  count: positiveCount,
                  label: 'إيجابية',
                  color: attendanceGreen,
                ),
                const SizedBox(width: 9),
                _TodayCount(
                  count: improvementCount,
                  label: 'تحتاج تحسين',
                  color: attendanceRed,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 50),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 50,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(height: 10),
                    Text('لم تُسجّل ملاحظات في هذه الحصة بعد'),
                  ],
                ),
              )
            else
              ...entries.map(
                (entry) => _TodayEntryCard(
                  student: entry.student,
                  note: entry.note,
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'يعرض هذا السجل الملاحظات الحالية للحصة. سيُضاف الترتيب الزمني عند ربط واجهة سجل الأدوات.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF858585),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCount extends StatelessWidget {
  const _TodayCount({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _TodayEntryCard extends StatelessWidget {
  const _TodayEntryCard({required this.student, required this.note});

  final AttendanceBehaviorStudent student;
  final BehaviorNoteModel note;

  @override
  Widget build(BuildContext context) {
    final color = behaviorNoteColor(note);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(behaviorIcon(note.iconKey), color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  note.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6F6F6F),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PointBadge(points: note.points),
        ],
      ),
    );
  }
}
