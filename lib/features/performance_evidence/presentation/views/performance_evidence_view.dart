import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/confirm_dialog_widget.dart';
import 'package:smart_table_app/core/widgets/pagination_grid_view.dart';
import 'package:smart_table_app/features/performance_evidence/data/models/performance_evidence_model.dart';
import 'package:smart_table_app/features/performance_evidence/presentation/views/add_performance_evidence_view.dart';
import 'package:smart_table_app/features/performance_evidence/providers/performance_evidence_provider.dart';

class PerformanceEvidenceView extends HookConsumerWidget {
  final String title;
  const PerformanceEvidenceView({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();

    // Listen to changes in the provider and update the controller if it's cleared
    ref.listen(performanceEvidenceSearchQueryProvider, (previous, next) {
      if (next.isEmpty && searchController.text.isNotEmpty) {
        searchController.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(
                color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              backgroundImage: AssetImage(PngAssets.teacher),
              radius: 18,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context, ref, searchController),
          Expanded(
            child: PaginationGridView<PerformanceEvidenceModel>(
              padding: const EdgeInsets.all(16),
              controller: ref
                  .watch(performanceEvidenceProvider.notifier)
                  .pagingController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.60,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              getList: (page) => ref
                  .read(performanceEvidenceProvider.notifier)
                  .getEvidences(page),
              itemBuilder: (items, index) {
                final item = items;
                return _buildEvidenceCard(context, item, ref);
              },
              noItemWidget: const Center(child: Text('لا يوجد شواهد أداء')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            onPressed: () {
              context.push(const AddPerformanceEvidenceView());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'إضافة ملف جديد',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.add, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(
      BuildContext context, WidgetRef ref, TextEditingController controller) {
    final searchQuery = ref.watch(performanceEvidenceSearchQueryProvider);

    return Padding(
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
                icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                onPressed: () {
                  ref
                      .read(performanceEvidenceSearchQueryProvider.notifier)
                      .state = '';
                  ref
                      .read(performanceEvidenceProvider.notifier)
                      .filterEvidences('');
                },
              ),
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                onChanged: (value) {
                  ref
                      .read(performanceEvidenceSearchQueryProvider.notifier)
                      .state = value;
                  ref
                      .read(performanceEvidenceProvider.notifier)
                      .filterEvidences(value);
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
    );
  }

  Widget _buildEvidenceCard(
      BuildContext context, PerformanceEvidenceModel item, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      item.typeFile == 'p'
                          ? PngAssets.pdf
                          : PngAssets.pdf, // Use PDF placeholder for now
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmDialogWidget(
                            title: 'هل أنت متأكد من حذف هذا الشاهد؟',
                            onConfirm: () {
                              ref
                                  .read(performanceEvidenceProvider.notifier)
                                  .deleteEvidence(item.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.title ?? 'بدون عنوان',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.titleSmall!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          item.category?.name ?? 'بدون تصنيف',
          style: context.textTheme.bodySmall!.copyWith(
            color: AppColors.primaryColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
