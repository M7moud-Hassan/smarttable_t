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
import '../../../performance_evidence/presentation/views/performance_evidence_view.dart';

import 'package:svg_flutter/svg_flutter.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeMenuProvider);
    return homeAsync.when(
        data: (data) {
          final smartScheduleIds = [1, 2, 3, 10]; // Smart schedule items
          final filteredMenus = activeTab == 0
              ? data.menus
                  .where((m) => smartScheduleIds.contains(m.id))
                  .toList()
              : data.menus
                  .where((m) => !smartScheduleIds.contains(m.id))
                  .toList();

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              leading: const Padding(
                padding: EdgeInsets.all(10.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage(PngAssets.teacher),
                  backgroundColor: Colors.white,
                ),
              ),
              title: Text(
                context.locale.home,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 30.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data.welcome.welcomeLabel} ${data.welcome.teacherName}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            data.welcome.schoolName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => activeTab = 0),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: activeTab == 0
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text('الجدول الذكي',
                                style: TextStyle(
                                    color: activeTab == 0
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => activeTab = 1),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: activeTab == 1
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text('المتابع الإداري',
                                style: TextStyle(
                                    color: activeTab == 1
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.45,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                    ),
                    itemCount: filteredMenus.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenus[index];
                      return GestureDetector(
                        onTap: !item.isActive
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor:
                                        context.theme.scaffoldBackgroundColor,
                                    content: Container(
                                      alignment: Alignment.center,
                                      width: 100,
                                      height: 100,
                                      child: Column(
                                        children: [
                                          Text(
                                            context.locale.serviceNotAvailable,
                                            style: context.textTheme.titleLarge!
                                                .copyWith(),
                                          ),
                                          const SizedBox(height: 20),
                                          Expanded(
                                            child: AppButton(
                                              onPressed: () {
                                                context.pop();
                                              },
                                              child: Text(context.locale.back),
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
                                    break;
                                  case 4:
                                    context.push(TeacherNotesView(
                                      title: item.title,
                                    ));
                                    break;
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
                                  case 11:
                                    context.push(
                                      PerformanceEvidenceView(
                                        title: item.title,
                                      ),
                                    );
                                    break;
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 7,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(builder: (_) {
                                String iconPath;
                                Color bgColor;
                                bool isPng = false;

                                switch (item.id) {
                                  case 1:
                                    iconPath = SvgAssets.table;
                                    bgColor = const Color(0xFFFFF2E8);
                                    break;
                                  case 2:
                                    iconPath = SvgAssets.stopwatch02;
                                    bgColor = const Color(0xFFEFF3FE);
                                    break;
                                  case 3:
                                    iconPath = SvgAssets.file06;
                                    bgColor = const Color(0xFFE6FAFA);
                                    break;
                                  case 10:
                                    iconPath = SvgAssets.groupds;
                                    bgColor = const Color(0xFFFFF2E8);
                                    break;
                                  case 4:
                                    iconPath = SvgAssets.group;
                                    bgColor = const Color(0xFFEFF3FE);
                                    break;
                                  case 5:
                                    iconPath = SvgAssets.groupw;
                                    bgColor = const Color(0xFFE6FAFA);
                                    break;
                                  case 6:
                                    iconPath = SvgAssets.group82;
                                    bgColor = const Color(0xFFFFF2E8);
                                    break;
                                  case 7:
                                    iconPath = SvgAssets.groupee;
                                    bgColor = const Color(0xFFF4EBFF);
                                    break;
                                  case 8:
                                    iconPath = SvgAssets.group81;
                                    bgColor = const Color(0xFFFFF2E8);
                                    break;
                                  case 9:
                                    iconPath = SvgAssets.groeup;
                                    bgColor = const Color(0xFFEFF3FE);
                                    break;
                                  case 11:
                                    iconPath = SvgAssets.perform21;
                                    bgColor = const Color(0xFFE6FAFA);
                                    break;
                                  default:
                                    iconPath = SvgAssets.table;
                                    bgColor = AppColors.grayColor;
                                    break;
                                }

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SvgPicture.asset(
                                    iconPath,
                                    width: 30,
                                    height: 30,
                                  ),
                                );
                              }),
                              const Spacer(),
                              Text(
                                item.title,
                                style: context.textTheme.titleMedium!.copyWith(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.description.isNotEmpty)
                                Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: context.textTheme.titleMedium!
                                      .copyWith(
                                          fontSize: 12,
                                          color: AppColors.pinkColor),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
        error: (error, stackTrace) => Scaffold(
              body: CustomErrorWidget(onTap: () {
                ref.invalidate(homeMenuProvider);
              }),
            ),
        loading: () => const Scaffold(body: LoadingWidget()));
  }
}
