import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_actions_bottom_sheet.dart';

import '../../../../core/constants/constants.dart';
import '../../data/models/day_model.dart';

class DashedBorderTable extends ConsumerWidget {
  const DashedBorderTable({
    super.key,
    required this.headerClasess,
    this.headerClassTimes = const {},
    required this.daysOfWeek,
    required this.lessonsData,
    required this.teacherName,
    this.teacherImageUrl,
    this.isLandscape = false,
  });
  final List<String> headerClasess;
  final Map<String, String> headerClassTimes;
  final List<DaysOfWeekModel> daysOfWeek;
  final Map<int, List<LessonModel>> lessonsData;
  final String teacherName;
  final String? teacherImageUrl;
  final bool isLandscape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        final canFitHeight = isLandscape &&
            constraints.maxHeight.isFinite &&
            daysOfWeek.isNotEmpty;
        final rowHeight = canFitHeight
            ? ((constraints.maxHeight - (padding * 2)) /
                    (daysOfWeek.length + 1))
                .clamp(40.0, 80.0)
                .toDouble()
            : 80.0;

        final sessionsTable = Table(
          defaultColumnWidth: isLandscape
              ? const FlexColumnWidth()
              : const FixedColumnWidth(120),
          children: [
            TableRow(
              children: [
                for (final title in headerClasess)
                  _buildPeriodHeader(
                    title,
                    headerClassTimes[title] ?? '',
                    rowHeight,
                  ),
              ],
            ),
            for (int row = 0; row < daysOfWeek.length; row++)
              TableRow(
                children: [
                  for (final lesson in lessonsData[daysOfWeek[row].id] ??
                      const <LessonModel>[])
                    _buildDataCell(
                      context,
                      ref,
                      lesson,
                      daysOfWeek[row].highlighted,
                      height: rowHeight,
                    ),
                ],
              ),
          ],
        );

        final daysColumn = Column(
          children: [
            _buildDiagonalHeader(
              context,
              width: double.infinity,
              height: rowHeight,
            ),
            for (int index = 0; index < daysOfWeek.length; index++)
              _buildDayCell(
                context,
                daysOfWeek[index],
                index == daysOfWeek.length - 1,
                width: double.infinity,
                height: rowHeight,
              ),
          ],
        );

        final tableContent = Padding(
          padding: const EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLandscape)
                Expanded(child: daysColumn)
              else
                SizedBox(width: 100, child: daysColumn),
              Expanded(
                flex: isLandscape ? max(1, headerClasess.length) : 1,
                child: isLandscape
                    ? sessionsTable
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: sessionsTable,
                      ),
              ),
            ],
          ),
        );

        final contentHeight =
            rowHeight * (daysOfWeek.length + 1) + (padding * 2);
        if (constraints.maxHeight.isFinite &&
            contentHeight > constraints.maxHeight) {
          return SingleChildScrollView(child: tableContent);
        }
        return tableContent;
      },
    );
  }

  Widget _buildPeriodHeader(String title, String time, double height) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: height < 56 ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: AutoSizeText(
              title,
              maxLines: 2,
              minFontSize: 7,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: AutoSizeText(
              time,
              maxLines: 1,
              minFontSize: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DaysOfWeekModel day,
    bool isLast, {
    required double width,
    required double height,
  }) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: day.highlighted ? AppColors.primaryColor : Colors.white,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
        borderRadius: isLast
            ? const BorderRadius.only(bottomRight: Radius.circular(10))
            : null,
      ),
      child: AutoSizeText(
        day.name,
        maxLines: 1,
        minFontSize: 9,
        style: context.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: day.highlighted ? Colors.white : AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDiagonalHeader(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(10)),
      ),
      child: CustomPaint(
        painter: DiagonalLinePainter(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
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

  Widget _buildDataCell(
    BuildContext context,
    WidgetRef ref,
    LessonModel lesson,
    bool isHighlighted, {
    required double height,
  }) {
    const assignedWaitingColor = Color(0xFFC44738);
    const availableWaitingColor = Color(0xFFB7791F);
    final isAssignedWaiting = lesson.isWaiting;
    final isAvailableWaiting = lesson.isWaitingSlot && !lesson.isWaiting;
    final foregroundColor = isAssignedWaiting
        ? assignedWaitingColor
        : isAvailableWaiting
            ? availableWaitingColor
            : Colors.black;
    final backgroundColor = isAssignedWaiting
        ? const Color(0xFFFFECE8)
        : isAvailableWaiting
            ? const Color(0xFFFFF3D6)
            : isHighlighted
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : Colors.white;
    final classroom = lesson.classroomName;
    final displayText = lesson.isWaitingSlot
        ? LessonModel.waitingLabel
        : [if (classroom.isNotEmpty) classroom, lesson.compactTitle].join('\n');

    final cell = Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: AutoSizeText(
        displayText,
        maxLines: 2,
        minFontSize: 8,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: foregroundColor,
        ),
      ),
    );

    if (!isAssignedWaiting) return cell;

    return Semantics(
      button: true,
      label: "تفاصيل حصة الانتظار",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showLessonDetailsBottomSheet(
            context,
            ref,
            lesson,
            teacherName,
            teacherImageUrl: teacherImageUrl,
          ),
          child: cell,
        ),
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
