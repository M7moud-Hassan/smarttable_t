import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/school_table/presentation/views/landscabe_teacher_table_view.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/models/day_model.dart';
import '../../data/models/lesson_model.dart';
import '../../providers/teacher_table_provider.dart';
import '../widgets/teacher_table_widget.dart';

class TeacherTableView extends ConsumerWidget {
  const TeacherTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherTableAsyncValue = ref.watch(teacherTableProvider);
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
      body: teacherTableAsyncValue.when(
        data: (data) {
          final headerClasess =
              getHeaderClassesList(data.tableInfo.first.lessons);
          final lessonsData = prepareLessonsData(data.tableInfo.first.lessons,
              data.tableInfo.first.daysOfWeek, headerClasess.length);
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!teacherTableAsyncValue.isReloading) ...[
                          Center(
                            child: GestureDetector(
                              onTap: () => context
                                  .push(const LandscabeTeacherTableView()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: Text(
                                  context.locale.showFullScheduleAppBar,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'المعلم : ${data.tableInfo.first.teacherName}',
                          style: const TextStyle(
                            color: AppColors.secondryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DashedBorderTable(
                  headerClasess: headerClasess,
                  daysOfWeek: data.tableInfo.first.daysOfWeek,
                  lessonsData: lessonsData,
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) => CustomErrorWidget(
          onTap: () => ref.invalidate(teacherTableProvider),
        ),
      ),
    );
  }
}
