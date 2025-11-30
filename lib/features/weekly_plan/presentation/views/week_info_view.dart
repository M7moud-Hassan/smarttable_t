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
import '../../providers/week_info_provider.dart';
import '../../providers/weekly_plan_notififer.dart';

class WeeklyInfoView extends ConsumerWidget {
  const WeeklyInfoView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.weeks),
      ),
      body: PaginationListView(
        padding: const EdgeInsets.all(16),
        getList: (page) => ref.read(weekInfoProvider(page).future),
        itemBuilder: (week, index) => GestureDetector(
          onTap: () {
            ref.read(selectedWeekProvider.notifier).update((state) => week);
            context.pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  week.weekNumberText,
                  style: context.textTheme.titleLarge!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                )
              ],
            ),
          ),
        ),
        noItemWidget: Center(child: Text(context.locale.noData)),
      ),
    );
  }
}
