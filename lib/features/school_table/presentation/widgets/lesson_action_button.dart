import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_view.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/presentation/views/lesson_achievement_view.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_actions_bottom_sheet.dart';
import 'package:smart_table_app/features/school_table/providers/teacher_table_provider.dart';
import 'package:smart_table_app/features/waiting_classes/presentation/views/secure_class_view.dart';
import '../../../../core/constants/constants.dart';

class LessonActionButton extends ConsumerWidget {
  final LessonModel lesson;
  final String teacherName;
  final String? teacherImageUrl;

  const LessonActionButton({
    super.key,
    required this.lesson,
    required this.teacherName,
    this.teacherImageUrl,
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
      onSelected: (value) async {
        if (value == 'secure') {
          context.push(SecureClassView(
            lesson: lesson,
            fromTeacherTable: true,
          ));
        } else if (value == 'details') {
          showLessonDetailsBottomSheet(
            context,
            ref,
            lesson,
            teacherName,
            teacherImageUrl: teacherImageUrl,
          );
        } else if (value == 'manage') {
          context.push(
            AttendanceBehaviorView(
              initialClassId: lesson.classroomId,
              initialClassName: lesson.classroomName,
              initialSession: lesson.classNumber,
              initialSessionLabel: lesson.classNumberText,
            ),
          );
        } else if (value == 'achievement') {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => LessonAchievementView(lesson: lesson),
            ),
          );
          if (saved == true && context.mounted) {
            ref.invalidate(teacherTableProvider);
            context.showSnackbarSuccess('تم حفظ إنجاز الحصة بنجاح');
          }
        }
      },
      itemBuilder: (context) => [
        if (lesson.canBeSecured) ...[
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
        if (lesson.canManageClass) ...[
          PopupMenuItem<String>(
            value: 'manage',
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "إدارة الحصة",
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
        if (lesson.canRecordAchievement) ...[
          PopupMenuItem<String>(
            value: 'achievement',
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "إنجاز الحصة",
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
