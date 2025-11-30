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
    return SizedBox(
      height: 125,
      child: ListView.separated(
          padding: pgHorizontalPadding18,
          separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
          itemCount: days.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = day.dayId == selectedDay;
            return GestureDetector(
              onTap: () {
                ref.read(selectedDayProvider.notifier).state = day.dayId;
              },
              child: Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      day.isCurrent ? AppColors.pinkColor : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.secondryColor,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          day.dayName,
                          style: TextStyle(
                              fontSize: 15,
                              color: isSelected ? Colors.white : Colors.black),
                        ),
                        Text(day.dayNumber.toString(),
                            style: TextStyle(
                                fontSize: 28,
                                color:
                                    isSelected ? Colors.white : Colors.black))
                      ]),
                    ),
                    if (day.isCurrent)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          context.locale.today,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
