import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/circulars/presentation/views/circulars_view.dart';
import 'package:smart_table_app/features/exams/presentation/views/exam_halls_view.dart';
import 'package:smart_table_app/features/health_cases/presentation/views/health_cases_view.dart';
import 'package:smart_table_app/features/school_table/presentation/views/master_table_view.dart';
import 'package:smart_table_app/features/waiting_classes/presentation/views/waiting_classes_view.dart';
import 'package:smart_table_app/features/weekly_plan/presentation/views/weekly_plan_view.dart';

import '../../../class_visits/presentation/views/class_visits_view.dart';
import '../../../scheduled_tasks/presentation/scheduled_tasks_view.dart';
import '../../../social_cases/presentation/views/social_cases_view.dart';
import '../../../teacher_notes/presentation/views/teacher_notes_view.dart';
import '../../providers/home_menu_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeMenuProvider);
    return homeAsync.when(
        data: (data) => Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [3, 3],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.grayColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Image.asset(
                            PngAssets.welcomeHand,
                            width: 50,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    context.locale.wellcome,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 19),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    data.welcome.teacherName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(fontSize: 19),
                                  ),
                                ],
                              ),
                              Text(
                                data.welcome.schoolName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontSize: 15),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                    child: GridView.builder(
                        padding: pgHorizontalPadding18,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10),
                        itemCount: data.menus.length,
                        itemBuilder: (context, index) {
                          final item = data.menus[index];
                          return GestureDetector(
                            onTap: !item.isActive
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: context
                                            .theme.scaffoldBackgroundColor,
                                        content: Container(
                                          alignment: Alignment.center,
                                          width: 100,
                                          height: 100,
                                          child: Column(
                                            children: [
                                              Text(
                                                context
                                                    .locale.serviceNotAvailable,
                                                style: context
                                                    .textTheme.titleLarge!
                                                    .copyWith(),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Expanded(
                                                child: AppButton(
                                                  onPressed: () {
                                                    context.pop();
                                                  },
                                                  child:
                                                      Text(context.locale.back),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                : () {
                                    switch (item.id) {
                                      case 1:
                                        context.push(const MasterTableView());
                                        break;
                                      case 2:
                                        context.push(WaitingClassesView(
                                          title: item.title,
                                        ));
                                        break;
                                      case 3:
                                        context.push(ScheduledTasksView(
                                          title: item.title,
                                        ));
                                      case 4:
                                        context.push(TeacherNotesView(
                                          title: item.title,
                                        ));
                                      case 5:
                                        context.push(CircularsView(
                                          title: item.title,
                                        ));
                                        break;
                                      case 6:
                                        context.push(HealthCasesView(
                                          title: item.title,
                                        ));
                                        break;
                                      case 7:
                                        context.push(ClassVisitsView(
                                          title: item.title,
                                        ));
                                        break;
                                      case 8:
                                        context.push(SocialCaseView(
                                          title: item.title,
                                        ));
                                        break;
                                      case 9:
                                        context.push(
                                          WeeklyPlanView(
                                            title: item.title,
                                          ),
                                        );
                                        break;
                                      case 10:
                                        context.push(
                                          ExamHallsView(
                                            title: item.title,
                                          ),
                                        );
                                        break;
                                      default:
                                    }
                                  },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.grayColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: item.image,
                                    width: 64,
                                    height: 64,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  item.title,
                                  style: context.textTheme.titleMedium!
                                      .copyWith(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                if (item.description.isNotEmpty)
                                  Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: context.textTheme.titleMedium!
                                        .copyWith(
                                            fontSize: 12,
                                            color: AppColors.pinkColor),
                                  )
                              ],
                            ),
                          );
                        }))
              ],
            ),
        error: (error, stackTrace) => CustomErrorWidget(onTap: () {
              ref.invalidate(homeMenuProvider);
            }),
        loading: () => const LoadingWidget());
  }
}
