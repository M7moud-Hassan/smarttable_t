import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_expansion_widget.dart';
import '../providers/scheduled_tasks_provider.dart';
import 'widgets/filter_widget.dart';

class ScheduledTasksView extends ConsumerWidget {
  const ScheduledTasksView({super.key, required this.title});
  final String title;
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
          const Divider(
            height: 0,
          ),
          Expanded(
            child: PaginationListView(
              key: Key(filter.name),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              getList: (page) => ref.watch(scheduledTasksProvider(page).future),
              itemBuilder: (subTasks, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subTasks.date,
                      style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    for (final task in subTasks.tasks)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: CustomExpansionWidget(
                          titleWidget: Row(
                            children: [
                              Text(
                                task.title,
                                style: context.textTheme.titleLarge!.copyWith(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          contentWidget: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              task.details,
                              style: context.textTheme.titleLarge!.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
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
}
