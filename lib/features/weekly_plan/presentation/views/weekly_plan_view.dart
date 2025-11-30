import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';
import 'package:smart_table_app/features/weekly_plan/presentation/widgets/upload_week_plan_sheet.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/views/pdf_viewer_view.dart';
import '../../../../core/widgets/confirm_dialog_widget.dart';
import '../../../../core/widgets/custom_expansion_widget.dart';
import '../../../../core/widgets/download_button.dart';
import '../../providers/weekly_plan_notififer.dart';

class WeeklyPlanView extends ConsumerWidget {
  const WeeklyPlanView({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PaginationListView(
        controller:
            ref.watch(weeklyPlanNotififerProvider.notifier).pagingController,
        getList: (page) =>
            ref.read(weeklyPlanNotififerProvider.notifier).getWeeklyPlanList(),
        itemBuilder: (plans, index) => CustomExpansionWidget(
          titleWidget: Row(
            children: [
              Image.asset(
                PngAssets.pdf,
                width: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                plans.teacherName,
                style: context.textTheme.titleLarge!.copyWith(fontSize: 18),
              ),
            ],
          ),
          contentWidget: [
            const SizedBox(
              height: 20,
            ),
            Text(
              plans.weekInfo,
              style: context.textTheme.titleLarge!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '${context.locale.date} : ${plans.createdAt.toString().split(' ')[0]}',
              style: context.textTheme.titleLarge!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0XFFF4C8A9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => context.push(PdfViwerView(
                      title: plans.fileName,
                      url: plans.file,
                    )),
                    child: Text(
                      context.locale.show,
                      style: context.textTheme.titleLarge!
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DownloadButtonWidget(
                    link: plans.file,
                    fileName: plans.fileName,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmDialogWidget(
                                title: context.locale.deleteFileConfirmation,
                                onConfirm: () {
                                  ref
                                      .read(
                                          weeklyPlanNotififerProvider.notifier)
                                      .deleteWeeklyPlan(plans.id);
                                });
                          });
                    },
                    child: Text(
                      context.locale.delete,
                      style: context.textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        noItemWidget: Center(child: Text(context.locale.noData)),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(
          Icons.upload_file_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (context) {
                return const UploadWeekPlanSheet();
              });
        },
      ),
    );
  }
}
