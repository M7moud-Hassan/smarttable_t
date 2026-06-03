import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_actions_bottom_sheet.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_notifier.dart';
import '../../../../core/constants/constants.dart';

class LessonActionButton extends ConsumerWidget {
  final LessonModel lesson;
  final String teacherName;

  const LessonActionButton({
    super.key,
    required this.lesson,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.primaryColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      color: Colors.white,
      offset: const Offset(0, 45),

      onSelected: (value) {
        if (value == 'secure') {
          ref
              .read(waitingClassNotifierProvider.notifier)
              .acceptWaitingClass(lesson.confirmLink);
        } else if (value == 'details') {
          showLessonDetailsBottomSheet(context, ref, lesson, teacherName);
        }
      },
      itemBuilder: (context) => [
        if (lesson.isWaiting && !lesson.confirmed) ...[
          PopupMenuItem<String>(
            value: 'secure',
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "تأمين الحصة",
                style: context.textTheme.titleMedium!.copyWith(
                  color: AppColors.secondryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const PopupMenuDivider(height: 1),
        ],
        PopupMenuItem<String>(
          value: 'details',
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              "تفاصيل الحصة",
              style: context.textTheme.titleMedium!.copyWith(
                color: AppColors.secondryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
