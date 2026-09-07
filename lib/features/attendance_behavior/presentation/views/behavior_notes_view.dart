import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

class BehaviorNotesView extends ConsumerStatefulWidget {
  const BehaviorNotesView({super.key});

  @override
  ConsumerState<BehaviorNotesView> createState() => _BehaviorNotesViewState();
}

class _BehaviorNotesViewState extends ConsumerState<BehaviorNotesView> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final featureState = ref.watch(attendanceBehaviorProvider);
    final notes = featureState.behaviorNotes.where(
      (note) {
        if (_filter == 1) return note.type == BehaviorNoteType.positive;
        if (_filter == 2) {
          return note.type == BehaviorNoteType.needsImprovement;
        }
        return true;
      },
    ).toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const FeatureTitleAppBar(
          title: 'قائمة ملاحظات السلوك',
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: FeatureSegmentedControl(
                labels: const ['الكل', 'إيجابي', 'بحاجة إلى تحسين'],
                selectedIndex: _filter,
                onSelected: (index) => setState(() => _filter = index),
              ),
            ),
            Expanded(
              child: featureState.loading && notes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 13),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _BehaviorNoteCard(
                          note: note,
                          onDelete: () => _delete(context, note),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    BehaviorNoteModel note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الملاحظة'),
        content: Text('هل تريد حذف ملاحظة "${note.name}"؟'),
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
    if (confirmed == true) {
      try {
        await ref
            .read(attendanceBehaviorProvider.notifier)
            .deleteBehaviorNote(note.id);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(perseveranceErrorMessage(error))),
        );
      }
    }
  }
}

class _BehaviorNoteCard extends StatelessWidget {
  const _BehaviorNoteCard({
    required this.note,
    required this.onDelete,
  });

  final BehaviorNoteModel note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = behaviorNoteColor(note);
    return Material(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: .18),
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 48,
              alignment: Alignment.center,
              color: color,
              child: Text(
                '${note.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8ED),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                behaviorIcon(note.iconKey),
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${note.points} نقاط',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (note.usageCount > 0)
                      Text(
                        'مستخدمة ${note.usageCount} مرة',
                        style: const TextStyle(fontSize: 11),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'حذف',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: attendanceRed,
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
