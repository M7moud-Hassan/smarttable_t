import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_grid_view.dart';
import 'package:smart_table_app/features/weekly_plan/presentation/widgets/upload_week_plan_sheet.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/views/pdf_viewer_view.dart';
import '../../providers/weekly_plan_notififer.dart';

class WeeklyPlanView extends HookConsumerWidget {
  const WeeklyPlanView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();

    // Listen to changes in the provider and update the controller if it's cleared
    ref.listen(weeklyPlanSearchQueryProvider, (previous, next) {
      if (next.isEmpty && searchController.text.isNotEmpty) {
        searchController.clear();
      }
    });

    final searchQuery = ref.watch(weeklyPlanSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon:
                          const Icon(Icons.clear, color: Colors.grey, size: 18),
                      onPressed: () {
                        ref.read(weeklyPlanSearchQueryProvider.notifier).state =
                            '';
                        ref
                            .read(weeklyPlanNotififerProvider.notifier)
                            .filterPlans('');
                      },
                    ),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        ref.read(weeklyPlanSearchQueryProvider.notifier).state =
                            value;
                        ref
                            .read(weeklyPlanNotififerProvider.notifier)
                            .filterPlans(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'بحث',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PaginationGridView(
              padding: const EdgeInsets.all(16.0),
              controller: ref.watch(weeklyPlanNotififerProvider.notifier).pagingController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Adjust based on card content
              ),
              getList: (page) => ref.read(weeklyPlanNotififerProvider.notifier).getWeeklyPlanList(),
              itemBuilder: (plans, index) => _buildPlanCard(context, ref, plans),
              noItemWidget: Center(child: Text(context.locale.noData)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                context.push(const UploadWeekPlanSheet());
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'إضافة خطة جديدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.add, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, dynamic plans) {
    return GestureDetector(
      onTap: () => context.push(PdfViwerView(
        title: plans.fileName,
        url: plans.file,
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                  color: Color(0xFFF9F9F9),
                ),
                child: Center(
                  child: Image.asset(
                    PngAssets.pdf,
                    width: 60,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Column(
                children: [
                   Text(
                    plans.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plans.createdAt.toString().split(' ')[0].replaceAll('-', '/'),
                    style: context.textTheme.titleSmall!.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
