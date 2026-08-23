import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/circulars/presentation/views/circulars_view.dart';
import 'package:smart_table_app/features/administrative_actions/presentation/views/administrative_actions_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_view.dart';
import 'package:smart_table_app/features/exams/presentation/views/exam_halls_view.dart';
import 'package:smart_table_app/features/health_cases/presentation/views/health_cases_view.dart';
import 'package:smart_table_app/features/school_table/presentation/views/master_table_view.dart';
import 'package:smart_table_app/features/teacher_preferences/presentation/views/teacher_preferences_view.dart';
import 'package:smart_table_app/features/waiting_classes/presentation/views/waiting_classes_view.dart';
import 'package:smart_table_app/features/weekly_plan/presentation/views/weekly_plan_view.dart';

import '../../../class_visits/presentation/views/class_visits_view.dart';
import '../../../scheduled_tasks/presentation/scheduled_tasks_view.dart';
import '../../../social_cases/presentation/views/social_cases_view.dart';
import '../../../teacher_notes/presentation/views/teacher_notes_view.dart';
import '../../data/models/menu_data_model.dart';
import '../../providers/home_menu_provider.dart';
import '../../../performance_evidence/presentation/views/performance_evidence_view.dart';
import '../../../profile/presentation/widgets/profile_photo_avatar.dart';

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
          final smartScheduleIds = [1, 2, 3, 10, 12]; // Smart schedule items
          final filteredMenus = activeTab == 0
              ? data.menus
                  .where((m) => smartScheduleIds.contains(m.id))
                  .toList()
              : data.menus
                  .where((m) => !smartScheduleIds.contains(m.id))
                  .toList();
          final hasAttendanceBehaviorMenu =
              data.menus.any(_isAttendanceBehaviorMenu);
          final showAttendanceBehaviorPreview =
              activeTab == 1 && !hasAttendanceBehaviorMenu;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ProfilePhotoAvatar(
                  radius: 20,
                  fallback: Image.asset(
                    PngAssets.teacher,
                    fit: BoxFit.cover,
                  ),
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
                    itemCount: filteredMenus.length +
                        (showAttendanceBehaviorPreview ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredMenus.length) {
                        return _AttendanceBehaviorHomeCard(
                          onTap: () => context.push(
                            const AttendanceBehaviorView(),
                          ),
                        );
                      }
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
                                if (_isAttendanceBehaviorMenu(item)) {
                                  context.push(
                                    const AttendanceBehaviorView(),
                                  );
                                  return;
                                }
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
                                  case 12:
                                    context.push(
                                      const TeacherPreferencesView(),
                                    );
                                    break;
                                  case 13:
                                    context.push(
                                      const AdministrativeActionsView(),
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
                                if (_isAttendanceBehaviorMenu(item)) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6FAFA),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.fact_check_outlined,
                                      color: AppColors.secondryColor,
                                      size: 30,
                                    ),
                                  );
                                }
                                String iconPath;
                                Color bgColor;

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
                                    iconPath = SvgAssets.dutyRoster;
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
                                  case 12:
                                    iconPath = SvgAssets.teacherPreferences;
                                    bgColor = const Color(0xFFFFF8CF);
                                    break;
                                  case 13:
                                    iconPath = SvgAssets.administrativeActions;
                                    bgColor = const Color(0xFFFFF4E8);
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

  bool _isAttendanceBehaviorMenu(MenuDataModel item) {
    final key = item.key.toLowerCase();
    return key == 'attendance_behavior' ||
        key == 'attendance-and-behavior' ||
        (item.title.contains('المواظبة') && item.title.contains('السلوك'));
  }
}

class _AttendanceBehaviorHomeCard extends StatelessWidget {
  const _AttendanceBehaviorHomeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('attendance-behavior-home-card'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 7,
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFE6FAFA),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.secondryColor,
                  size: 30,
                ),
              ),
            ),
            Spacer(),
            Text(
              'المواظبة والسلوك',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'متابعة الطلاب',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.pinkColor),
            ),
          ],
        ),
      ),
    );
  }
}
