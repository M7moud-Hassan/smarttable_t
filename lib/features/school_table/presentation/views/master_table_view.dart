import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/days_list_widget.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_action_button.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_actions_bottom_sheet.dart';

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
                        children: [
                          Expanded(
                            flex: 5,
                            child: AutoSizeText(
                              'اليوم : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              maxLines: 1,
                              minFontSize: 11,
                              stepGranularity: 0.5,
                              style: context.textTheme.titleMedium!.copyWith(
                                color: AppColors.secondryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: TextButton(
                              onPressed: () =>
                                  context.push(const TeacherTableView()),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: AutoSizeText(
                                context.locale.showFullSchedule,
                                maxLines: 1,
                                minFontSize: 11,
                                stepGranularity: 0.5,
                                style: context.textTheme.titleMedium!.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
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
                          return _buildLessonCard(
                              context,
                              ref,
                              lesson,
                              data.masterTable.first.teacherName,
                              data.masterTable.first.teacherImageUrl);
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
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const AutoSizeText(
                    'الحصة الحالية',
                    maxLines: 1,
                    minFontSize: 11,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AutoSizeText(
                  '${data.currentClassLabel} : ${data.currentClass}',
                  maxLines: 2,
                  minFontSize: 11,
                  stepGranularity: 0.5,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Column(
                children: [
                  const AutoSizeText(
                    'متبقي',
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  AutoSizeText(
                    data.remainingTimeForNextLesson,
                    maxLines: 1,
                    minFontSize: 11,
                    stepGranularity: 0.5,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, WidgetRef ref,
      LessonModel lesson, String teacherName, String? teacherImageUrl) {
    const assignedWaitingColor = Color(0xFFC44738);
    const availableWaitingColor = Color(0xFFB7791F);
    final isAssignedWaiting = lesson.isWaiting;
    final isAvailableWaiting = lesson.isWaitingSlot && !lesson.isWaiting;
    final statusColor = isAssignedWaiting
        ? assignedWaitingColor
        : isAvailableWaiting
            ? availableWaitingColor
            : AppColors.primaryColor;
    final backgroundColor = isAssignedWaiting
        ? const Color(0xFFFFECE8)
        : isAvailableWaiting
            ? const Color(0xFFFFF3D6)
            : Colors.white;

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: AutoSizeText(
              lesson.classNumberText,
              maxLines: 2,
              minFontSize: 12,
              stepGranularity: 0.5,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: statusColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: lesson.isWaitingSlot
                ? AutoSizeText(
                    LessonModel.waitingLabel,
                    maxLines: 1,
                    minFontSize: 12,
                    stepGranularity: 0.5,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AutoSizeText(
                        lesson.classroomName,
                        maxLines: 1,
                        minFontSize: 11,
                        stepGranularity: 0.5,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AutoSizeText(
                        lesson.compactTitle,
                        maxLines: 1,
                        minFontSize: 11,
                        stepGranularity: 0.5,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 44,
            child: LessonActionButton(
              lesson: lesson,
              teacherName: teacherName,
              teacherImageUrl: teacherImageUrl,
            ),
          ),
        ],
      ),
    );

    if (!isAssignedWaiting) return card;

    return Semantics(
      button: true,
      label: "تفاصيل حصة الانتظار",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showLessonDetailsBottomSheet(
          context,
          ref,
          lesson,
          teacherName,
          teacherImageUrl: teacherImageUrl,
        ),
        child: card,
      ),
    );
  }
}
