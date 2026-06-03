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
          centerTitle: true,
        ),
        body: PaginationListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          getList: (page) => ref.read(healthCasesListProvider(page).future),
          itemBuilder: (item, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: context.textTheme.titleMedium!.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                        ),
                        Text(
                          item.healthConditionsCount > 0
                              ? '${item.healthConditionsCount} ${context.locale.cases}'
                              : '${item.healthConditionsCount} ${context.locale.case_}',
                          style: TextStyle(
                              color: item.healthConditionsCount > 0
                                  ? const Color(
                                      0xFFC25B49) // Pink/Orange color from design
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primaryColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                ),
              ],
            );
          },
          sepratedWidget: const SizedBox.shrink(),
          noItemWidget: Center(
            child: Text(context.locale.noData),
          ),
        ));
  }
}
