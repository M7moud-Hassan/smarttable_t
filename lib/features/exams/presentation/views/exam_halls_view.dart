import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';
import 'package:smart_table_app/features/exams/providers/exam_halls_groups_provider.dart';
import 'package:smart_table_app/features/exams/providers/exam_halls_provider.dart';

import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/custom_expansion_widget.dart';

class ExamHallsView extends ConsumerWidget {
  const ExamHallsView({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PaginationListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            getList: (page) => ref.read(examHallsGroupsProvider(page).future),
            itemBuilder: (examHall, index) => CustomExpansionWidget(
                  titleWidget: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${examHall.name} ',
                          style: context.textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  contentWidget: [
                    // Text(
                    //   '${examHall.startDate} - ${examHall.endDate}',
                    //   style: context.textTheme.titleLarge!
                    //       .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                    // ),
                    // const Divider(
                    //   thickness: 0.5,
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    ref.watch(examHallsProvider(examHall.id)).when(
                          data: (data) {
                            return data.isEmpty
                                ? Center(
                                    child: Text(
                                      context.locale.noData,
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: data.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                      thickness: 0.5,
                                    ),
                                    itemBuilder: (context, index) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[index].name,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time_filled,
                                                color: AppColors.primaryColor,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${data[index].period} ( ${data[index].startTime} - ${data[index].endTime} )',
                                                  style: context
                                                      .textTheme.titleLarge!
                                                      .copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (data[index].courses.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.library_books,
                                                color: AppColors.primaryColor,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  data[index]
                                                      .courses
                                                      .join(' , '),
                                                  style: context
                                                      .textTheme.titleLarge!
                                                      .copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.today,
                                                color: AppColors.primaryColor,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${data[index].day} ( ${data[index].date} )',
                                                  style: context
                                                      .textTheme.titleLarge!
                                                      .copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                          error: (error, stackTrace) => CustomErrorWidget(
                            onTap: () => ref.invalidate(examHallsProvider),
                          ),
                          loading: () => const Center(child: LoadingWidget()),
                        )
                  ],
                ),
            noItemWidget: Center(
              child: Text(context.locale.noData),
            )));
  }
}
