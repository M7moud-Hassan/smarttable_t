import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/download_button.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';
import '../../data/models/class_visits_model.dart';
import '../../providers/class_visits_provider.dart';

class ClassVisitsView extends ConsumerWidget {
  const ClassVisitsView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
      ),
      body: PaginationListView<ClassVisitsModel>(
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
  final ClassVisitsModel visit;

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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(18),
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
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE9F5F5),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.event_note_outlined,
                          color: AppColors.secondryColor, size: 21),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'تاريخ الزيارة : ${widget.visit.dateHijri}',
                        textAlign: TextAlign.start,
                        style: context.textTheme.titleMedium!.copyWith(
                          color: AppColors.secondryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                  const Divider(color: Color(0xFFE4EDEF), height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Column(children: [
                      _buildDataRow('المعلم/ة', widget.visit.teacherName),
                      _buildDataRow(
                          context.locale.visitor, widget.visit.visitorName),
                      _buildDataRow(
                          context.locale.class_, widget.visit.className),
                      _buildDataRow(
                          context.locale.session, widget.visit.session),
                      _buildDataRow('التاريخ الميلادي', widget.visit.date),
                    ]),
                  ),
                  _overallRating(),
                  if (widget.visit.evaluation != null)
                    _EvaluationDetails(evaluation: widget.visit.evaluation!)
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(widget.visit.hasEvaluation
                          ? 'تفاصيل التقييم غير متاحة حاليًا'
                          : 'لم يتم تقييم هذه الزيارة بعد'),
                    ),
                  if (widget.visit.fileUrl?.trim().isNotEmpty == true)
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

  Widget _buildDataRow(String title, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(builder: (context, constraints) {
          final label = Text(title,
              style: const TextStyle(
                  color: Color(0xFF71858B), fontSize: 12, height: 1.6));
          final content = Text(value.trim().isEmpty ? '—' : value,
              style: const TextStyle(
                  color: Color(0xFF263E46),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.6));
          if (MediaQuery.textScalerOf(context).scale(13) > 20 ||
              constraints.maxWidth < 260) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [label, const SizedBox(height: 4), content]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 100, child: label),
            const SizedBox(width: 12),
            Expanded(child: content),
          ]);
        }),
      );

  Widget _overallRating() => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFECF7F6),
            borderRadius: BorderRadius.circular(14)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('التقييم العام',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondryColor)),
          const SizedBox(height: 10),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 10,
              children: [
                Text(widget.visit.rateLabel,
                    style: const TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF263E46))),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final rating = widget.visit.ratingValue;
                          final icon = rating == null
                              ? Icons.star_border_rounded
                              : rating >= index + 1
                                  ? Icons.star_rounded
                                  : rating >= index + .5
                                      ? Icons.star_half_rounded
                                      : Icons.star_border_rounded;
                          return Icon(icon,
                              color: icon == Icons.star_border_rounded
                                  ? const Color(0xFFCCDADD)
                                  : const Color(0xFFD5A340),
                              size: 23);
                        }))),
              ]),
        ]),
      );
}

class _EvaluationDetails extends StatelessWidget {
  const _EvaluationDetails({required this.evaluation});
  final ClassVisitEvaluation evaluation;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final section in evaluation.sections)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFF3FAFA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDCEDEE))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text(section.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondryColor)),
                          Text('${section.score} / 5',
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondryColor)),
                        ]),
                    const SizedBox(height: 10),
                    for (final item in section.items.entries)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(item.key,
                                        style: const TextStyle(
                                            fontSize: 13, height: 1.6))),
                                const SizedBox(width: 12),
                                Text('${item.value} / 5',
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ])),
                    const Divider(color: Color(0xFFDCEDEE)),
                    _note('ملاحظات المحور', section.note),
                  ]),
            ),
          for (final note in evaluation.notes.entries)
            Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FA),
                    borderRadius: BorderRadius.circular(12)),
                child: _note(note.key, note.value)),
        ]),
      );

  Widget _note(String title, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondryColor)),
        const SizedBox(height: 6),
        SelectableText(value.trim().isEmpty ? 'لا توجد ملاحظات' : value,
            style: const TextStyle(fontSize: 13, height: 1.7)),
      ]);
}
