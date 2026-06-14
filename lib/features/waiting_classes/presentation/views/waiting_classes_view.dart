import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/lesson_actions_bottom_sheet.dart';
import 'package:smart_table_app/features/home/providers/home_menu_provider.dart';

import 'package:smart_table_app/features/waiting_classes/presentation/views/secure_class_view.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../school_table/presentation/widgets/days_list_widget.dart';
import '../../../school_table/providers/days_provider.dart';
import '../../providers/waiting_class_provider.dart';

class WaitingClassesView extends ConsumerWidget {
  const WaitingClassesView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitingClassesAsync = ref.watch(waitingClassProvider);
    final daysAsync = ref.watch(daysProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryColor),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: daysAsync.when(
        data: (days) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  DaysListWidget(days: days),
                  const SizedBox(height: 30),
                  waitingClassesAsync.when(
                    data: (data) {
                      final waitingClasses = getWaitingClassesList(data, ref);
                      if (waitingClasses.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      return _buildPopulatedState(context, ref, waitingClasses);
                    },
                    error: (error, stackTrace) => Center(
                      child: CustomErrorWidget(
                        error: error.toString(),
                        onTap: () => ref.invalidate(waitingClassProvider),
                      ),
                    ),
                    loading: () => const Center(child: LoadingWidget()),
                  )
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(
          child: CustomErrorWidget(onTap: () => ref.invalidate(daysProvider)),
        ),
        loading: () => const Center(child: LoadingWidget()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            context.locale.noWaitingClasses,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 60),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFFCF7F0), // Light cream/orange background
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE87E98), // Pinkish color from design
              size: 60,
            ),
          ),
        ),
        const SizedBox(height: 120),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "سيتم إشعارك إذا تم إضافة حصص إنتظار لجدولك",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1E2F38), // Dark color from design
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopulatedState(
      BuildContext context, WidgetRef ref, List<LessonModel> waitingClasses) {
    final String teacherName =
        ref.watch(homeMenuProvider).value?.welcome.teacherName ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "حصص الانتظار",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "عدد الحصص : ${waitingClasses.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: waitingClasses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final lesson = waitingClasses[index];
            return WaitingClassCard(
              lesson: lesson,
              index: index,
              teacherName: teacherName,
            );
          },
        ),
      ],
    );
  }

  List<LessonModel> getWaitingClassesList(
      List<LessonModel> data, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    return data.where((element) => element.dayId == selectedDay).toList();
  }
}

class WaitingClassCard extends ConsumerWidget {
  final LessonModel lesson;
  final int index;
  final String teacherName;

  const WaitingClassCard({
    super.key,
    required this.lesson,
    required this.index,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isConfirmed = lesson.confirmed;
    final Color mainColor =
        !isConfirmed ? const Color(0xFFE7581F) : AppColors.primaryColor;
    final Color bgColor = mainColor.withValues(alpha: 0.1);

    final subjectParts = lesson.cellText.subject.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                showLessonDetailsBottomSheet(context, ref, lesson, teacherName),
            child: SizedBox(
              height: 95,
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subjectParts
                              .toString()
                              .replaceAll(",", " ")
                              .replaceAll("[", "")
                              .replaceAll("]", ""),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isConfirmed
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFE7581F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 18, color: mainColor),
                            const SizedBox(width: 6),
                            Text(
                              lesson.classNumberText,
                              style: TextStyle(
                                  fontSize: 14,
                                color: mainColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(
                      isConfirmed
                          ? Icons.visibility
                          : Icons.visibility_off_outlined,
                      color: isConfirmed
                          ? AppColors.primaryColor
                          : Colors.grey[400],
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isConfirmed) ...[
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => showLessonDetailsBottomSheet(
                          context, ref, lesson, teacherName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "التفاصيل",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(SecureClassView(
                          lesson: lesson,
                          fromTeacherTable: false,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "تأكيد",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
