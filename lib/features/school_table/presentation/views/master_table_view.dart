import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/school_table/presentation/widgets/days_list_widget.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../providers/days_provider.dart';
import '../../providers/master_table_provider.dart';
import 'teacher_table_view.dart';

class MasterTableView extends ConsumerWidget {
  const MasterTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(daysProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text(context.locale.schoolSchedule),
        ),
        body: daysAsync.when(
          data: (days) {
            final masterTableASync = ref.watch(masterTableProvider);
            return masterTableASync.when(
              skipLoadingOnReload: true,
              data: (data) {
                return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: pgHorizontalPadding18,
                              child: Row(
                                children: [
                                  Text(
                                    data.currentClassLabel,
                                    style: context.textTheme.titleLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondryColor),
                                  ),
                                  if (data.currentClass.isNotEmpty)
                                    Text(
                                      ':',
                                      style: context.textTheme.titleLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondryColor),
                                    ),
                                  Text(
                                    data.currentClass,
                                    style: context.textTheme.titleLarge!
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: pgHorizontalPadding18,
                              child: Text(
                                data.remainingTimeForNextLesson,
                                style: context.textTheme.titleMedium!,
                              ),
                            ),
                            const SizedBox(height: 30),
                            DaysListWidget(days: days),
                            const SizedBox(height: 30),
                            masterTableASync.isReloading
                                ? const Center(
                                    child: LoadingWidget(),
                                  )
                                : Padding(
                                    padding: pgHorizontalPadding18,
                                    child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(10),
                                        dashPattern: const [3, 3],
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${data.masterTable.first.teacherNameLabel} : ${data.masterTable.first.teacherName}',
                                                style: context
                                                    .textTheme.titleMedium!
                                                    .copyWith(
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontSize: 20),
                                              ),
                                              ...data.masterTable.first.lessons
                                                  .map((lesson) {
                                                final waitingClass =
                                                    lesson.isWaiting;

                                                final acceptedWaiting =
                                                    waitingClass &&
                                                        (lesson.confirmed);
                                                return Container(
                                                  color: acceptedWaiting
                                                      ? AppColors.greenColor
                                                          .withOpacity(0.3)
                                                      : waitingClass
                                                          ? AppColors.pinkColor
                                                              .withOpacity(0.3)
                                                          : Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 20),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '${lesson.classNumberText} :',
                                                        style: context.textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 18,
                                                                color: AppColors
                                                                    .textGrayColor),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            if (waitingClass &&
                                                                !acceptedWaiting) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) =>
                                                                    AlertDialog(
                                                                  backgroundColor:
                                                                      context
                                                                          .theme
                                                                          .scaffoldBackgroundColor,
                                                                  content:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    width: 100,
                                                                    height: 100,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          context
                                                                              .locale
                                                                              .waitingClass,
                                                                          style: context
                                                                              .textTheme
                                                                              .titleLarge!
                                                                              .copyWith(),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Text(
                                                                          (lesson.cellText.subject).replaceAll(
                                                                              '\n',
                                                                              '  '),
                                                                          style: context
                                                                              .textTheme
                                                                              .titleMedium!
                                                                              .copyWith(),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            (waitingClass &&
                                                                    !acceptedWaiting)
                                                                ? context.locale
                                                                    .waitingClass
                                                                : (lesson
                                                                        .cellText
                                                                        .subject)
                                                                    .replaceAll(
                                                                        '\n',
                                                                        '  '),
                                                            style: context
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        )),
                                  ),
                            const SizedBox(height: 30),
                            if (!masterTableASync.isReloading)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: TextButton(
                                      onPressed: () {
                                        context.push(const TeacherTableView());
                                      },
                                      child: Text(
                                        context.locale.showFullSchedule,
                                        style: context.textTheme.titleLarge!
                                            .copyWith(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                        ),
                                      )),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              error: (error, stackTrace) => CustomErrorWidget(
                onTap: () {
                  ref.invalidate(masterTableProvider);
                },
              ),
              loading: () => const Center(child: LoadingWidget()),
            );
          },
          error: (error, stackTrace) => CustomErrorWidget(
            onTap: () {
              ref.invalidate(daysProvider);
            },
          ),
          loading: () => const Center(child: LoadingWidget()),
        ));
  }
}
