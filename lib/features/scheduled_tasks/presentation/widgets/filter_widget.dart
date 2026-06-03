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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
            children: [
          (context.locale.currentFilter, ScheduledTasksFilter.current),
          (context.locale.upcomingFilter, ScheduledTasksFilter.upcoming),
          (context.locale.expiredFilter, ScheduledTasksFilter.expired),
        ]
                .map((filter) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(scheduledTaskFilterProvider.notifier).state =
                              filter.$2;
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: filter.$2 == currentFilter
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: filter.$2 == currentFilter
                                ? [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              filter.$1,
                              style: context.textTheme.titleMedium!.copyWith(
                                fontSize: 16,
                                fontWeight: filter.$2 == currentFilter
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: const Color(0xFF001C3F), // Dark blue
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList()),
      ),
    );
  }
}

