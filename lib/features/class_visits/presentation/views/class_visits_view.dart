import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/download_button.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';
import '../../providers/class_visits_provider.dart';

class ClassVisitsView extends ConsumerWidget {
  const ClassVisitsView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PaginationListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        getList: (page) => ref.read(classVisitsProvider(page).future),
        itemBuilder: (visit, index) => _ClassVisitCard(visit: visit),
        noItemWidget: Center(
          child: Text(
            context.locale.noData,
            style: context.textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}

class _ClassVisitCard extends StatefulWidget {
  final dynamic visit;

  const _ClassVisitCard({required this.visit});

  @override
  State<_ClassVisitCard> createState() => _ClassVisitCardState();
}

class _ClassVisitCardState extends State<_ClassVisitCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: const SizedBox(),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'تاريخ الزيارة : ${widget.visit.dateHijri}',
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium!.copyWith(
                          color: AppColors.secondryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primaryColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0, width: double.infinity),
              secondChild: Column(
                children: [
                  const Divider(
                      color: AppColors.primaryColor, height: 1, thickness: 1.2),
                  _buildDataRow(
                      context.locale.visitor, widget.visit.visitorName,
                      isRating: false),
                  const Divider(
                      color: AppColors.primaryColor, height: 1, thickness: 1.2),
                  _buildDataRow(context.locale.class_, widget.visit.className,
                      isRating: false),
                  const Divider(
                      color: AppColors.primaryColor, height: 1, thickness: 1.2),
                  _buildDataRow(context.locale.session, widget.visit.session,
                      isRating: false),
                  const Divider(
                      color: AppColors.primaryColor, height: 1, thickness: 1.2),
                  // Rating Row
                  _buildDataRow('التقيم العام', widget.visit.rate ?? 'ممتاز',
                      isRating: true),
                  const Divider(
                      color: AppColors.primaryColor, height: 1, thickness: 1.2),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DownloadButtonWidget(
                      link: widget.visit.fileUrl,
                      fileName: 'visit_${widget.visit.id}.pdf',
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حفظ PDF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String title, String value, {required bool isRating}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.secondryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: isRating
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFE88A60),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
