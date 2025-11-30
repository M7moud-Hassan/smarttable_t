import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

import '../../../../core/constants/constants.dart';
import '../../../school_table/data/models/lesson_model.dart';
import '../../../school_table/presentation/widgets/teacher_table_widget.dart';
import '../../providers/waiting_class_notifier.dart';

class WaitingClassesTable extends ConsumerWidget {
  const WaitingClassesTable({
    super.key,
    required this.headerClasess,
    required this.lessons,
  });
  final List<String> headerClasess;
  final List<LessonModel> lessons;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 16.0, top: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 95,
              ),
              for (int index = 0; index < lessons.length; index++)
                Container(
                  height: 94,
                  width: 20,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.yellowColor,
                      borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(10),
                        bottomStart: Radius.circular(10),
                      ),
                      border: Border.all(color: AppColors.grayBordredColor)),
                  child: Text(
                    '${index + 1}',
                    style: context.textTheme.titleLarge!
                        .copyWith(fontSize: 20, color: Colors.black),
                  ),
                )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(
                    150.0), // Adjust column width as needed
                children: [
                  _buildTableRow(
                    [
                      for (int row = 0; row < headerClasess.length; row++)
                        (headerClasess[row], null),
                    ],
                    ref,
                    isHeader: true,
                  ),
                  for (int row = 0; row < lessons.length; row++)
                    _buildTableRow([
                      (lessons[row].cellText.subject, lessons[row]),
                      (
                        lessons[row].classNumberText,
                        lessons[row]
                            .copyWith(isWaiting: false, confirmed: false)
                      ),
                    ], ref)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<(String, LessonModel?)> cells, WidgetRef ref,
      {bool isHeader = false, bool isHighlighted = false}) {
    return TableRow(
      children: cells.map((cell) {
        final waitingClass = cell.$2?.isWaiting ?? false;
        final acceptedWaiting = waitingClass && (cell.$2?.confirmed ?? false);
        final clickable =
            waitingClass && ((cell.$2?.confirmed == false) ?? false ?? false);
        return CustomPaint(
          painter: isHeader ? null : DashedBorderPainter(),
          child: GestureDetector(
            onTap: clickable
                ? () {
                    ref
                        .read(waitingClassNotifierProvider.notifier)
                        .acceptWaitingClass(cell.$2!.confirmLink);
                  }
                : null,
            child: Container(
              height: 96,
              color: acceptedWaiting
                  ? AppColors.greenColor.withOpacity(0.4)
                  : waitingClass
                      ? AppColors.pinkColor.withOpacity(0.4)
                      : isHighlighted
                          ? AppColors.yellowColor
                          : Colors.white,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                cell.$1,
                style: TextStyle(
                  fontSize: isHeader ? 19 : 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
