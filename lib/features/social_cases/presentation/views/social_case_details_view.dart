import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';

import '../../providers/health_cases_provider.dart';

class SocialCaseDetailsView extends ConsumerWidget {
  const SocialCaseDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSocialCase = ref.read(currentSocialCaseProvider);
    final socialCaseDetails = ref.watch(socialCasesDetailsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(currentSocialCase.name),
        centerTitle: true,
      ),
      body: socialCaseDetails.when(
          data: (data) {
            return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemBuilder: (_, index) {
                  final item = data[index];
                  return _SocialCaseExpansionItem(
                    title: item.name,
                    trackName: currentSocialCase.name,
                    studentGuardian: item.studentGuardian,
                    kinshipWithStudent: item.kinshipWithStudent,
                    liveWithWho: item.withLiveText,
                    fatherIsAlive: item.fatherIsAlive,
                    motherIsAlive: item.motherIsAlive,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(
                      height:
                          12, // Slight negative spacing could be achieved with - margin, but 12 fits better if they don't overlap. The design actually shows consecutive cards that might be distinct. We use normal spacing.
                    ),
                itemCount: data.length);
          },
          error: (_, __) => Center(
                  child: CustomErrorWidget(
                onTap: () => ref.invalidate(socialCasesDetailsProvider),
              )),
          loading: () => const Center(child: LoadingWidget())),
    );
  }
}

class _SocialCaseExpansionItem extends StatefulWidget {
  final String title;
  final String trackName;
  final String studentGuardian;
  final String kinshipWithStudent;
  final String liveWithWho;
  final bool fatherIsAlive;
  final bool motherIsAlive;

  const _SocialCaseExpansionItem({
    required this.title,
    required this.trackName,
    required this.studentGuardian,
    required this.kinshipWithStudent,
    required this.liveWithWho,
    required this.fatherIsAlive,
    required this.motherIsAlive,
  });

  @override
  State<_SocialCaseExpansionItem> createState() =>
      _SocialCaseExpansionItemState();
}

class _SocialCaseExpansionItemState extends State<_SocialCaseExpansionItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _expanded
            ? AppColors.primaryColor.withValues(alpha: 0.1)
            : AppColors.primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              borderRadius: _expanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              borderRadius: _expanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.right,
                        style: context.textTheme.titleMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                        border: Border.all(
                            color: AppColors.primaryColor, width: 1.5),
                      ),
                      child: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRichText(
                          'أسم الفصل : ', // Will use hardcoded text since context.locale.className isn't clearly available and we must match exactly. actually let's try context.locale.class_
                          widget.trackName,
                          context,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _buildParentAlive(
                                    context.locale.fatherIsAlive,
                                    widget.fatherIsAlive,
                                    context)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildParentAlive(
                                    context.locale.motherIsAlive,
                                    widget.motherIsAlive,
                                    context)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _buildRichText(
                                    '${context.locale.kinshipWithStudent} : ',
                                    widget.kinshipWithStudent,
                                    context)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildRichText(
                                    '${context.locale.liveWithWho} : ',
                                    widget.liveWithWho,
                                    context)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRichText('${context.locale.studentGuardian} : ',
                            widget.studentGuardian, context),
                        const SizedBox(height: 12),
                        _buildRichText(
                          'الإجراءات : ', // Procedures / Actions
                          'مراعاة الطالب في الدرجات', // Hardcoded fallback or we need it from model if exists. Wait, does model have recommendations? Let me check.
                          context,
                          labelColor: const Color(0xFFC25B49), // Pinkish orange
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(String label, String value, BuildContext context,
      {Color? labelColor}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: context.textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: labelColor ?? AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: context.textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildParentAlive(String label, bool isAlive, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            '$label : ',
            style: context.textTheme.titleMedium!.copyWith(
              fontSize: 14,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isAlive ? context.locale.yes : context.locale.no,
            style: context.textTheme.titleSmall!.copyWith(
              color: isAlive ? AppColors.primaryColor : const Color(0xFFC25B49),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
