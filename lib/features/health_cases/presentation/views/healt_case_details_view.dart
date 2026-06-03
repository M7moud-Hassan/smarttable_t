import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';

import '../../providers/health_cases_provider.dart';

class HealthCaseDetailsView extends ConsumerWidget {
  const HealthCaseDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHealthCase = ref.read(currentHealthCaseProvider);
    final healthDetails = ref.watch(healthCasesDetailsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(currentHealthCase.name),
        centerTitle: true,
      ),
      body: healthDetails.when(
          data: (data) {
            return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemBuilder: (_, index) {
                  final item = data[index];
                  return _HealthCaseExpansionItem(
                    title: item.nameStudent,
                    trackName: currentHealthCase.name,
                    healthStatus: item.name,
                    dealingWithSituation: item.dealingWithSituation,
                    recommendations: item.recommendations,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(
                      height: 12,
                    ),
                itemCount: data.length);
          },
          error: (_, __) => Center(
                  child: CustomErrorWidget(
                onTap: () => ref.invalidate(healthCasesDetailsProvider),
              )),
          loading: () => const Center(child: LoadingWidget())),
    );
  }
}

class _HealthCaseExpansionItem extends StatefulWidget {
  final String title;
  final String trackName;
  final String healthStatus;
  final String dealingWithSituation;
  final String recommendations;

  const _HealthCaseExpansionItem({
    required this.title,
    required this.trackName,
    required this.healthStatus,
    required this.dealingWithSituation,
    required this.recommendations,
  });

  @override
  State<_HealthCaseExpansionItem> createState() =>
      _HealthCaseExpansionItemState();
}

class _HealthCaseExpansionItemState extends State<_HealthCaseExpansionItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.right,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.primaryColor, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    children: [
                      const Divider(
                        height: 0,
                        thickness: 1,
                        color: AppColors.primaryColor,
                      ),
                      _buildRow(context.locale.class_, widget.trackName),
                      const Divider(
                        height: 0,
                        thickness: 1,
                        color: AppColors.primaryColor,
                      ),
                      _buildRow(
                          context.locale.healthStatus, widget.healthStatus),
                      const Divider(
                        height: 0,
                        thickness: 1,
                        color: AppColors.primaryColor,
                      ),
                      _buildRow(context.locale.howToTreat,
                          widget.dealingWithSituation),
                      const Divider(
                        height: 0,
                        thickness: 1,
                        color: AppColors.primaryColor,
                      ),
                      _buildRow(
                          context.locale.suggestions, widget.recommendations),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                label,
                style: context.textTheme.titleMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                value,
                style: context.textTheme.titleMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
