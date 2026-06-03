import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

import '../../../../core/constants/constants.dart';
import '../../data/models/day_model.dart';
import '../../providers/days_provider.dart';

class DaysListWidget extends ConsumerWidget {
  const DaysListWidget({super.key, required this.days});
  final List<DayModel> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final isSelected = day.dayId == selectedDay;
          return GestureDetector(
            onTap: () {
              ref.read(selectedDayProvider.notifier).state = day.dayId;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day.dayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryColor
                        : const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  day.dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryColor
                        : const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
