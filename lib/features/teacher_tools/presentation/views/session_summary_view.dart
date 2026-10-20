import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_api_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/repositories/teacher_tools_repository.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class SessionSummaryView extends ConsumerStatefulWidget {
  const SessionSummaryView({
    super.key,
    required this.lessonContext,
  });

  final TeacherToolsContext lessonContext;

  @override
  ConsumerState<SessionSummaryView> createState() => _SessionSummaryViewState();
}

class _SessionSummaryViewState extends ConsumerState<SessionSummaryView> {
  final Set<String> _selectedElements = {};
  SessionSummaryData? _summary;
  List<TeacherToolEvidenceCategory> _categories = const [];
  int? _categoryId;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final classId = widget.lessonContext.classId;
    if (classId == null) {
      setState(() {
        _loading = false;
        _errorMessage = 'تعذر تحديد الفصل لهذه الحصة';
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(teacherToolsRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repository.getSessionSummary(
          classId: classId,
          session: widget.lessonContext.session,
          date: widget.lessonContext.apiDate,
        ),
        repository.getEvidenceCategories(),
      ]);
      final summary = results[0] as SessionSummaryData;
      final categories = results[1] as List<TeacherToolEvidenceCategory>;
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _categories = categories;
        _selectedElements
          ..clear()
          ..addAll(
            summary.selectedElements.isNotEmpty
                ? summary.selectedElements
                : summary.suggestedElements.map((element) => element.key),
          );
        _categoryId = categories.any(
          (category) => category.id == summary.evidenceCategoryId,
        )
            ? summary.evidenceCategoryId
            : categories.firstOrNull?.id;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = perseveranceErrorMessage(error);
      });
    }
  }

  Future<void> _save() async {
    final classId = widget.lessonContext.classId;
    final categoryId = _categoryId;
    if (classId == null || categoryId == null || _saving) return;
    setState(() => _saving = true);
    try {
      final summary =
          await ref.read(teacherToolsRepositoryProvider).saveSessionSummary(
                classId: classId,
                session: widget.lessonContext.session,
                date: widget.lessonContext.apiDate,
                selectedElements: _selectedElements.toList(growable: false),
                evidenceCategoryId: categoryId,
              );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _saving = false;
      });
      context.showSnackbarSuccess('تم حفظ ملخص الحصة في شواهد الأداء');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }

  void _toggleElement(String key) {
    setState(() {
      if (!_selectedElements.remove(key)) {
        _selectedElements.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const TeacherToolsAppBar(title: 'ملخص الحصة'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null || summary == null
                ? TeacherToolsLoadError(
                    message: _errorMessage ?? 'تعذر تحميل ملخص الحصة',
                    onRetry: _load,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    children: [
                      TeacherToolsContextCard(
                        lessonContext: widget.lessonContext,
                        compact: true,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: teacherToolsGreen.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_graph_rounded,
                              color: teacherToolsGreen,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'يتحدّث هذا الملخص تلقائيًا من بيانات المواظبة والسلوك والسؤال السريع.',
                                style: TextStyle(
                                  color: Color(0xFF267E4B),
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TeacherToolSectionTitle(
                        title: 'بيانات الحصة',
                        subtitle:
                            'حدّد الأقسام التي تريد إبرازها في ملف شاهد الأداء',
                      ),
                      const SizedBox(height: 11),
                      _SummarySectionCard(
                        title: 'المواظبة',
                        subtitle:
                            'تم تسجيل ${summary.attendance.recordedCount} طالبًا',
                        icon: Icons.fact_check_outlined,
                        color: teacherToolsGreen,
                        selected: true,
                        selectable: false,
                        onTap: () {},
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryMetric(
                                value: '${summary.attendance.present}',
                                label: 'حاضر',
                                color: teacherToolsGreen,
                              ),
                            ),
                            Expanded(
                              child: _SummaryMetric(
                                value: '${summary.attendance.absent}',
                                label: 'غائب',
                                color: teacherToolsRed,
                              ),
                            ),
                            Expanded(
                              child: _SummaryMetric(
                                value: '${summary.attendance.late}',
                                label: 'متأخر',
                                color: teacherToolsAmber,
                              ),
                            ),
                            Expanded(
                              child: _SummaryMetric(
                                value: '${summary.attendance.permission}',
                                label: 'مستأذن',
                                color: teacherToolsBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _SummarySectionCard(
                        title: 'السلوك',
                        subtitle:
                            '${summary.behavior.recordsCount} ملاحظات مسجلة',
                        icon: Icons.emoji_emotions_outlined,
                        color: teacherToolsAmber,
                        selected: true,
                        selectable: false,
                        onTap: () {},
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryMetric(
                                value: '${summary.behavior.positiveCount}',
                                label: 'إيجابي',
                                color: teacherToolsGreen,
                              ),
                            ),
                            Expanded(
                              child: _SummaryMetric(
                                value: '${summary.behavior.negativeCount}',
                                label: 'بحاجة لتحسين',
                                color: teacherToolsRed,
                              ),
                            ),
                            Expanded(
                              child: _SummaryMetric(
                                value: summary.behavior.totalPoints > 0
                                    ? '+${summary.behavior.totalPoints}'
                                    : '${summary.behavior.totalPoints}',
                                label: 'مجموع النقاط',
                                color: teacherToolsBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _SummarySectionCard(
                        title: 'السؤال السريع',
                        subtitle: summary.quickQuestion.asked
                            ? 'تم تقييم السؤال السريع'
                            : 'لم يُطرح سؤال سريع بعد',
                        icon: Icons.quiz_outlined,
                        color: AppColors.primaryColor,
                        selected: summary.quickQuestion.asked,
                        selectable: false,
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                summary.quickQuestion.question.isEmpty
                                    ? 'لم يُضف نص للسؤال'
                                    : summary.quickQuestion.question,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryMetric(
                                    value:
                                        '${summary.quickQuestion.understoodCount}',
                                    label: 'فهم',
                                    color: teacherToolsGreen,
                                  ),
                                ),
                                Expanded(
                                  child: _SummaryMetric(
                                    value:
                                        '${summary.quickQuestion.partialCount}',
                                    label: 'فهم جزئي',
                                    color: teacherToolsAmber,
                                  ),
                                ),
                                Expanded(
                                  child: _SummaryMetric(
                                    value:
                                        '${summary.quickQuestion.notUnderstoodCount}',
                                    label: 'لم يفهم',
                                    color: teacherToolsRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const TeacherToolSectionTitle(
                        title: 'حفظ شاهد الأداء',
                        subtitle: 'سيُنشأ ملف PDF ويظهر داخل شواهد الأداء',
                      ),
                      const SizedBox(height: 11),
                      if (summary.suggestedElements.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FCFC),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color:
                                  AppColors.primaryColor.withValues(alpha: .35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'عناصر الأداء المقترحة',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              ...summary.suggestedElements.map(
                                (element) => Material(
                                  color: Colors.transparent,
                                  child: CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    value:
                                        _selectedElements.contains(element.key),
                                    title: Text(
                                      element.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    onChanged: (_) =>
                                        _toggleElement(element.key),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (summary.alreadySaved) ...[
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: teacherToolsGreen.withValues(alpha: .09),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: teacherToolsGreen),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'تم حفظ ملخص سابق لهذه الحصة. الحفظ الآن سينشئ شاهدًا جديدًا.',
                                  style: TextStyle(
                                    color: Color(0xFF267E4B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        itemHeight: null,
                        selectedItemBuilder: (context) => _categories
                            .map(
                              (category) => Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                            .toList(growable: false),
                        decoration: InputDecoration(
                          labelText: 'تصنيف شاهد الأداء',
                          prefixIcon: const Icon(Icons.folder_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(category.name),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _categoryId = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_outlined,
                              color: teacherToolsRed,
                              size: 27,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تقرير ملخص الحصة.pdf',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'يُنشأ تلقائيًا عند الحفظ',
                                    style: TextStyle(
                                      color: Color(0xFF777777),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_selectedElements.length} أقسام',
                              style: const TextStyle(
                                color: AppColors.secondryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: TeacherToolsPrimaryButton(
            label: 'حفظ في شواهد الأداء',
            icon: Icons.cloud_upload_outlined,
            onPressed: _loading ||
                    _errorMessage != null ||
                    _saving ||
                    _categoryId == null
                ? null
                : _save,
          ),
        ),
      ),
    );
  }
}

class _SummarySectionCard extends StatelessWidget {
  const _SummarySectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.child,
    this.selectable = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: .045) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: selectable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : const Color(0xFFE3E3E3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF747474),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectable)
                    Checkbox(
                      value: selected,
                      onChanged: (_) => onTap(),
                    ),
                ],
              ),
              const SizedBox(height: 13),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF747474), fontSize: 10),
        ),
      ],
    );
  }
}
