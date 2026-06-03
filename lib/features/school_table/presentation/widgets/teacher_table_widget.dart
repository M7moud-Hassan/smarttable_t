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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Days Column
              Column(
                children: [
                  // Diagonal Header Cell
                  _buildDiagonalHeader(context),
                  for (int index = 0; index < daysOfWeek.length; index++)
                    Container(
                      height:
                          isLandscape ? context.screenSize.height * 0.145 : 80,
                      width:
                          isLandscape ? context.screenSize.width * 0.12 : 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: daysOfWeek[index].highlighted
                            ? AppColors.primaryColor
                            : Colors.white,
                        border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3)),
                        borderRadius: index == daysOfWeek.length - 1
                            ? const BorderRadius.only(
                                bottomRight: Radius.circular(10))
                            : null,
                      ),
                      child: Text(
                        daysOfWeek[index].name,
                        style: context.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: daysOfWeek[index].highlighted
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    )
                ],
              ),
              // Sessions Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultColumnWidth: FixedColumnWidth(
                        isLandscape ? context.screenSize.width * 0.120 : 120),
                    children: [
                      // Header Row (Sessions)
                      TableRow(
                        children: headerClasess.map((title) {
                          return Container(
                            height: 80,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  "8:15 ص - 9:00 ص", // Generic example or from model if available
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      // Data Rows
                      for (int row = 0; row < daysOfWeek.length; row++)
                        TableRow(
                          children: [
                            for (int col = 0;
                                col <
                                    (lessonsData[daysOfWeek[row].id]?.length ??
                                        0);
                                col++)
                              _buildDataCell(
                                  context,
                                  ref,
                                  lessonsData[daysOfWeek[row].id]![col],
                                  daysOfWeek[row].highlighted,
                                  isLandscape: isLandscape),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiagonalHeader(BuildContext context) {
    return Container(
      height: 80,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(10)),
      ),
      child: CustomPaint(
        painter:
            DiagonalLinePainter(color: AppColors.primaryColor.withOpacity(0.3)),
        child: const Stack(
          children: [
            Positioned(
              right: 10,
              bottom: 10,
              child: Text(
                "الحصة",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Text(
                "اليوم",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(BuildContext context, WidgetRef ref, LessonModel lesson,
      bool isHighlighted,
      {bool isLandscape = false}) {
    final bool isWaiting = lesson.isWaiting;
    final bool isConfirmed = lesson.confirmed;
    // Split subject by newline to handle cases where class name is appended
    final subjectParts = lesson.cellText.subject.split('\n');
    final String subjectText = subjectParts.first;
    final String classText =
        subjectParts.length > 2 ? subjectParts[1] : subjectParts.last;

    return Container(
      height: isLandscape ? context.screenSize.height * 0.145 : 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.white,
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            '$classText \n $subjectText',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isWaiting && !isConfirmed
                  ? const Color(0xFFC25B49)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  final Color color;
  DiagonalLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
