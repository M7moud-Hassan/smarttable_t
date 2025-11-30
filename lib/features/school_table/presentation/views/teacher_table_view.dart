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
          title: Text(context.locale.showFullScheduleAppBar),
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
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: pgHorizontalPadding18,
                    child: Row(
                      children: [
                        Text(
                          data.currentLesson,
                          style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondryColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          data.remainingTimeForNextLesson,
                          style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DashedBorderTable(
                    headerClasess: headerClasess,
                    daysOfWeek: data.tableInfo.first.daysOfWeek,
                    lessonsData: lessonsData,
                  ),
                  if (!teacherTableAsyncValue.isReloading) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: TextButton(
                            onPressed: () {
                              context.push(const LandscabeTeacherTableView());
                            },
                            child: Text(
                              context.locale.showFullScheduleVertical,
                              style: context.textTheme.titleLarge!.copyWith(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            )),
                      ),
                    )
                  ]
                ],
              ),
            );
          },
          loading: () {
            return const LoadingWidget();
          },
          error: (error, stackTrace) {
            return CustomErrorWidget(
              onTap: () => ref.invalidate(teacherTableProvider),
            );
          },
        ));
  }
}
