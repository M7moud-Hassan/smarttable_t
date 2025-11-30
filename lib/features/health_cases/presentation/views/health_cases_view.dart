import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/health_cases/presentation/views/healt_case_details_view.dart';
import 'package:smart_table_app/features/health_cases/providers/health_cases_provider.dart';

import '../../../../core/widgets/pagination_list_view.dart';

class HealthCasesView extends ConsumerWidget {
  const HealthCasesView({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PaginationListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          getList: (page) => ref.read(healthCasesListProvider(page).future),
          itemBuilder: (item, index) {
            return Column(
              children: [
                const Divider(
                  height: 0,
                  color: Color(0XFFCBD4D9),
                ),
                ListTile(
                  onTap: () {
                    if (item.healthConditionsCount > 0) {
                      context.push(ProviderScope(
                        overrides: [
                          currentHealthCaseProvider.overrideWithValue(item),
                        ],
                        child: const HealthCaseDetailsView(),
                      ));
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Text(
                        item.name,
                        style: context.textTheme.titleMedium!.copyWith(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      const Spacer(),
                      Text(
                        item.healthConditionsCount > 0
                            ? '${item.healthConditionsCount} ${context.locale.cases}'
                            : '${item.healthConditionsCount} ${context.locale.case_}',
                        style: TextStyle(
                            color: item.healthConditionsCount > 0
                                ? AppColors.pinkColor
                                : Colors.grey,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                ),
                const Divider(
                  height: 0,
                  color: Color(0XFFCBD4D9),
                ),
              ],
            );
          },
          noItemWidget: Center(
            child: Text(context.locale.noData),
          ),
        ));
  }
}
