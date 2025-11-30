import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/waiting_classes/presentation/widgets/waiting_class_table.dart';

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
      appBar: AppBar(
        title: Text(title),
      ),
      body: daysAsync.when(
        data: (days) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                DaysListWidget(days: days),
                const SizedBox(height: 30),
                waitingClassesAsync.when(
                  data: (data) {
                    final waitingClasses = getWaitingClassesList(data, ref);
                    return waitingClasses.isEmpty
                        ? Center(
                            child: Text(context.locale.noWaitingClasses),
                          )
                        : WaitingClassesTable(
                            headerClasess: [
                              context.locale.class_,
                              context.locale.session
                            ],
                            lessons: waitingClasses,
                          );
                  },
                  error: (error, stackTrace) => Center(
                    child: CustomErrorWidget(
                      error: error.toString(),
                      onTap: () {
                        ref.invalidate(waitingClassProvider);
                      },
                    ),
                  ),
                  loading: () => const Center(child: LoadingWidget()),
                )
              ],
            ),
          );
        },
        error: (error, stackTrace) => Center(
            child:
                CustomErrorWidget(onTap: () => ref.invalidate(daysProvider))),
        loading: () => const Center(
          child: LoadingWidget(),
        ),
      ),
    );
  }

  List<LessonModel> getWaitingClassesList(
      List<LessonModel> data, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final waitingClasses = <LessonModel>[];
    waitingClasses.addAll(
      data.where(
        (element) => element.dayId == selectedDay,
      ),
    );
    return waitingClasses;
  }
}
