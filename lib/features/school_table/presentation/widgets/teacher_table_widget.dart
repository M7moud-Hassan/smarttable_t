import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_notifier.dart';

import '../../../../core/constants/constants.dart';
import '../../data/models/day_model.dart';

class DashedBorderTable extends ConsumerWidget {
  const DashedBorderTable({
    super.key,
    required this.headerClasess,
    required this.daysOfWeek,
    required this.lessonsData,
    this.isLandscape = false,
  });
  final List<String> headerClasess;
  final List<DaysOfWeekModel> daysOfWeek;
  final Map<int, List<LessonModel>> lessonsData;
  final bool isLandscape;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highLightedDay = daysOfWeek.firstWhere(
      (element) => (element.highlighted),
      orElse: () => DaysOfWeekModel(id: -1, name: '', highlighted: false),
    );
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 16.0, top: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                height: isLandscape ? context.screenSize.height * 0.1 : 65,
              ),
              for (int index = 0; index < daysOfWeek.length; index++)
                Container(
                  height: isLandscape ? context.screenSize.height * 0.115 : 60,
                  width: isLandscape ? context.screenSize.width * 0.12 : 80,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: daysOfWeek[index].highlighted
                        ? AppColors.primaryColor
                        : AppColors.secondryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AutoSizeText(
                    daysOfWeek[index].name,
                    maxFontSize: 18,
                    style: context.textTheme.titleLarge!.copyWith(
                        fontSize: isLandscape ? null : 20,
                        color: daysOfWeek[index].highlighted
                            ? Colors.white
                            : Colors.black),
                  ),
                )
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: FixedColumnWidth(isLandscape
                    ? context.screenSize.width * 0.111
                    : 120), // Adjust column width as needed
                children: [
                  _buildTableRow(
                    [
                      for (int row = 0; row < headerClasess.length; row++)
                        (headerClasess[row], null),
                    ],
                    ref,
                    context,
                    isHeader: true,
                  ),
                  for (int row = 0; row < lessonsData.length; row++)
                    _buildTableRow([
                      for (int col = 0; col < lessonsData[row]!.length; col++)
                        (
                          lessonsData[row]![col].cellText.subject,
                          lessonsData[row]![col]
                        ),
                    ], ref, context,
                        isHighlighted: highLightedDay.id ==
                            lessonsData.entries.toList()[row].key),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
      List<(String, LessonModel?)> cells, WidgetRef ref, BuildContext context,
      {bool isHeader = false, bool isHighlighted = false}) {
    return TableRow(
      children: cells.map((cell) {
        final waitingClass = cell.$2?.isWaiting ?? false;
        final clickable =
            waitingClass && ((cell.$2?.confirmed == false) ?? false ?? false);
        final acceptedWaiting = waitingClass && (cell.$2?.confirmed ?? false);

        return CustomPaint(
          painter: isHeader ? null : DashedBorderPainter(),
          child: GestureDetector(
            onTap: clickable
                ? () {
                    ref
                        .read(waitingClassNotifierProvider.notifier)
                        .acceptWaitingClass(cell.$2!.confirmLink,
                            fromTeacherTable: true);
                  }
                : null,
            child: Container(
              height: isLandscape ? context.screenSize.height * 0.12 : 65,
              color: acceptedWaiting
                  ? AppColors.greenColor.withOpacity(0.4)
                  : waitingClass
                      ? AppColors.pinkColor.withOpacity(0.4)
                      : isHighlighted
                          ? AppColors.yellowColor
                          : Colors.white,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: AutoSizeText(
                cell.$1,
                minFontSize: isLandscape ? 8 : 10,
                style: TextStyle(
                  fontSize: isLandscape
                      ? null
                      : isHeader
                          ? 13
                          : 18,
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

class DashedBorderPainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;

  DashedBorderPainter({
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.color = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw top border
    _drawDashedLine(canvas, const Offset(0, 0), Offset(size.width, 0), paint);
    // Draw bottom border
    _drawDashedLine(
        canvas, Offset(0, size.height), Offset(size.width, size.height), paint);
    // Draw left border
    _drawDashedLine(canvas, const Offset(0, 0), Offset(0, size.height), paint);
    // Draw right border
    _drawDashedLine(
        canvas, Offset(size.width, 0), Offset(size.width, size.height), paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = sqrt(dx * dx + dy * dy); // Use sqrt from dart:math

    double dashCount = (distance / (dashWidth + dashSpace)).floor().toDouble();
    for (int i = 0; i < dashCount; i++) {
      double x = start.dx + (dx / dashCount) * i;
      double y = start.dy + (dy / dashCount) * i;
      canvas.drawLine(
        Offset(x, y),
        Offset(
          x + dx / dashCount * (dashWidth / (dashWidth + dashSpace)),
          y + dy / dashCount * (dashWidth / (dashWidth + dashSpace)),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
