import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/keys_enums.dart';
import '../data/models/scheduled_tasks_model.dart';
import '../providers/scheduled_tasks_provider.dart';
import 'widgets/filter_widget.dart';

class ScheduledTasksView extends ConsumerWidget {
  const ScheduledTasksView({
    super.key,
    required this.title,
    this.source = ScheduledTasksSource.dutyRoster,
  });

  final String title;
  final ScheduledTasksSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(scheduledTaskFilterProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          const FilterWidget(),
          Expanded(
            child: PaginationListView(
              key: Key(filter.name),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              sepratedWidget: const SizedBox.shrink(),
              getList: (page) => ref.watch(
                scheduledTasksProvider((page: page, source: source)).future,
              ),
              itemBuilder: (subTasks, index) {
                return Column(
                  children: [
                    for (int i = 0; i < subTasks.tasks.length; i++)
                      _buildTimelineItem(
                        task: subTasks.tasks[i],
                        date: subTasks.date,
                        isFirstDot: index == 0 && i == 0,
                        context: context,
                      )
                  ],
                );
              },
              noItemWidget: Center(
                child: Text(
                  context.locale.noTasks,
                  style: context.textTheme.titleLarge!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required Task task,
    required String date,
    required bool isFirstDot,
    required BuildContext context,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 10,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: isFirstDot ? 30 : 0,
                  bottom: 0,
                  child: Container(
                    width: 1.5,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  top: 30, // Alignment matches midway of card
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                      color: Colors.white,
                    ),
                    child: isFirstDot
                        ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.title,
                          style: context.textTheme.titleMedium!.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          task.details,
                          style: context.textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF001C3F),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.locale.date,
                          style: context.textTheme.titleSmall!.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          date,
                          style: context.textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF001C3F),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
}
