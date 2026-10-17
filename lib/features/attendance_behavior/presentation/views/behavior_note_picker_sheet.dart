import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';

Future<BehaviorNoteModel?> showBehaviorNotePickerSheet(
  BuildContext context, {
  required String studentName,
  required List<BehaviorNoteModel> notes,
}) {
  return showModalBottomSheet<BehaviorNoteModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BehaviorNotePickerSheet(
      studentName: studentName,
      notes: notes,
    ),
  );
}

class _BehaviorNotePickerSheet extends StatefulWidget {
  const _BehaviorNotePickerSheet({
    required this.studentName,
    required this.notes,
  });

  final String studentName;
  final List<BehaviorNoteModel> notes;

  @override
  State<_BehaviorNotePickerSheet> createState() =>
      _BehaviorNotePickerSheetState();
}

class _BehaviorNotePickerSheetState extends State<_BehaviorNotePickerSheet> {
  BehaviorNoteType _type = BehaviorNoteType.positive;

  @override
  Widget build(BuildContext context) {
    final filteredNotes = widget.notes
        .where((note) => note.type == _type)
        .toList(growable: false);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.sizeOf(context).height * .82,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                StudentAvatar(name: widget.studentName, radius: 29),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'اختر الملاحظة التي تريد منحها',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 48,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'إيجابية',
                      selected: _type == BehaviorNoteType.positive,
                      color: attendanceGreen,
                      onTap: () => setState(
                        () => _type = BehaviorNoteType.positive,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      label: 'تحتاج تحسين',
                      selected: _type == BehaviorNoteType.needsImprovement,
                      color: attendanceRed,
                      onTap: () => setState(
                        () => _type = BehaviorNoteType.needsImprovement,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredNotes.isEmpty
                  ? const Center(child: Text('لا توجد ملاحظات في هذا القسم'))
                  : GridView.builder(
                      itemCount: filteredNotes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 11,
                        mainAxisSpacing: 11,
                        mainAxisExtent: 148,
                      ),
                      itemBuilder: (_, index) {
                        final note = filteredNotes[index];
                        final color = behaviorNoteColor(note);
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.of(context).pop(note),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: color.withValues(alpha: .25),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Align(
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: .1),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Icon(
                                            behaviorIcon(note.iconKey),
                                            color: color,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.25,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  PositionedDirectional(
                                    top: 0,
                                    start: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        note.signedPoints > 0
                                            ? '+${note.signedPoints}'
                                            : '${note.signedPoints}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.secondryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
