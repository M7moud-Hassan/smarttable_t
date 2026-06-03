import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/days_list_widget.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_action_button.dart';




import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../providers/days_provider.dart';
import '../../providers/master_table_provider.dart';
import 'teacher_table_view.dart';

class MasterTableView extends ConsumerWidget {
  const MasterTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(daysProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.locale.schoolSchedule,
          style: context.textTheme.titleLarge!.copyWith(
            color: AppColors.secondryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: daysAsync.when(
        data: (days) {
          final masterTableASync = ref.watch(masterTableProvider);
          return masterTableASync.when(
            skipLoadingOnReload: true,
            data: (data) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Featured Card: Current Lesson
                      _buildCurrentLessonCard(context, data),
                      const SizedBox(height: 24),
                      // Date and Full Schedule Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'اليوم : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: context.textTheme.titleMedium!.copyWith(
                              color: AppColors.secondryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(const TeacherTableView()),
                            child: Text(
                              context.locale.showFullSchedule,
                              style: context.textTheme.titleMedium!.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Horizontal Days List
                      DaysListWidget(days: days),
                      const SizedBox(height: 24),
                      // Lessons List
                      if (masterTableASync.isReloading)
                        const Center(child: LoadingWidget())
                      else
                        ...data.masterTable.first.lessons.map((lesson) {
                          return _buildLessonCard(context, ref, lesson,
                              data.masterTable.first.teacherName);
                        }),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
            error: (error, stackTrace) => CustomErrorWidget(
              onTap: () => ref.invalidate(masterTableProvider),
            ),
            loading: () => const Center(child: LoadingWidget()),
          );
        },
        error: (error, stackTrace) => CustomErrorWidget(
          onTap: () => ref.invalidate(daysProvider),
        ),
        loading: () => const Center(child: LoadingWidget()),
      ),
    );
  }

  Widget _buildCurrentLessonCard(BuildContext context, dynamic data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remaining Time

          // Current Class Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Text(
                  'الحصة الحالية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${data.currentClassLabel} : ${data.currentClass}',
                style: const TextStyle(
                  color: AppColors.secondryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Column(
              children: [
                const Text(
                  'متبقي',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  data.remainingTimeForNextLesson,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, WidgetRef ref,
      LessonModel lesson, String teacherName) {
    final bool isWaiting = lesson.isWaiting;
    final bool isConfirmed = lesson.confirmed;
    final Color statusColor = isWaiting && !isConfirmed
        ? const Color(0xFFC25B49) // Orange/Coral from design
        : AppColors.primaryColor;

    // Split subject logic
    final subjectParts = lesson.cellText.subject.split('\n');
    final String subjectText = subjectParts.first;
    final String? classText =
        subjectParts.length > 1 ? subjectParts.last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          // Lesson Name
          Text(
            lesson.classNumberText,
            style: TextStyle(
              color: statusColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 24),

          // Status
          if (isWaiting && !isConfirmed)
            Text(
              context.locale.waitingClass,
              style: const TextStyle(
                color: Color(0xFFC25B49),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 20),
          // Subject and Class
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                subjectText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (classText != null)
                Text(
                  classText,
                  style: const TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),

          const Spacer(),
          LessonActionButton(
            lesson: lesson,
            teacherName: teacherName,
          ),

        ],
      ),
    );
  }

}

