import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';

import '../../../../core/constants/constants.dart';
import '../../providers/scheduled_tasks_provider.dart';

class FilterWidget extends ConsumerWidget {
  const FilterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(scheduledTaskFilterProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 20, right: 20),
      child: Row(
          children: [
        (context.locale.currentFilter, ScheduledTasksFilter.current),
        (context.locale.expiredFilter, ScheduledTasksFilter.expired),
        (context.locale.upcomingFilter, ScheduledTasksFilter.upcoming)
      ]
              .map((filter) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(scheduledTaskFilterProvider.notifier).state =
                            filter.$2;
                      },
                      child: Column(
                        children: [
                          Text(
                            filter.$1,
                            style: context.textTheme.titleLarge!.copyWith(
                                fontSize: 17,
                                fontWeight: filter.$2 == currentFilter
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: filter.$2 == currentFilter
                                    ? AppColors.primaryColor
                                    : Colors.grey),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: filter.$2 == currentFilter
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                            ),
                          )
                        ],
                      ),
                    ),
                  ))
              .toList()),
    );
  }
}
