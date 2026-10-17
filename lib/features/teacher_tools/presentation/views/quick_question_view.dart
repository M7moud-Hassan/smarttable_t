import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/utils/student_name_formatter.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_api_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/repositories/teacher_tools_repository.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class QuickQuestionView extends ConsumerStatefulWidget {
  const QuickQuestionView({
    super.key,
    required this.lessonContext,
  });

  final TeacherToolsContext lessonContext;

  @override
  ConsumerState<QuickQuestionView> createState() => _QuickQuestionViewState();
}

class _QuickQuestionViewState extends ConsumerState<QuickQuestionView> {
  final _questionController = TextEditingController();
  final _noteController = TextEditingController();
  final Set<int> _selectedIds = {};
  final Map<int, QuickQuestionRating> _ratings = {};
  List<TeacherToolStudent> _students = const [];
  int _step = 0;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  List<TeacherToolStudent> get _selectedStudents => _students
      .where((student) => _selectedIds.contains(student.id))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _students = widget.lessonContext.availableStudents;
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _toggleStudent(int studentId) {
    setState(() {
      if (_selectedIds.remove(studentId)) {
        _ratings.remove(studentId);
        return;
      }
      if (_selectedIds.length >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يمكن اختيار ٦ طلاب كحد أقصى')),
        );
        return;
      }
      _selectedIds.add(studentId);
    });
  }

  void _selectRandomStudents() {
    final shuffled = [..._students]..shuffle();
    final count = shuffled.length < 4 ? shuffled.length : 4;
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(shuffled.take(count).map((student) => student.id));
      _ratings.clear();
    });
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
        repository.getPresentStudents(
          classId: classId,
          session: widget.lessonContext.session,
          date: widget.lessonContext.apiDate,
        ),
        repository.getQuickQuestion(
          classId: classId,
          session: widget.lessonContext.session,
          date: widget.lessonContext.apiDate,
        ),
      ]);
      final roster = results[0] as PresentStudentsData;
      final question = results[1] as QuickQuestionData;
      if (!mounted) return;
      setState(() {
        _students = roster.students;
        _selectedIds
          ..clear()
          ..addAll(question.students.map((item) => item.student.id));
        _ratings
          ..clear()
          ..addEntries(
            question.students
                .where((item) => item.rating != null)
                .map((item) => MapEntry(item.student.id, item.rating!)),
          );
        _questionController.text = question.question;
        _noteController.text = question.note;
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

  Future<void> _saveSelection() async {
    final classId = widget.lessonContext.classId;
    if (classId == null || _selectedIds.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(teacherToolsRepositoryProvider)
          .selectQuickQuestionStudents(
            classId: classId,
            session: widget.lessonContext.session,
            date: widget.lessonContext.apiDate,
            studentIds: _selectedIds.toList(growable: false),
            question: _questionController.text,
            note: _noteController.text,
          );
      if (!mounted) return;
      setState(() {
        _ratings
          ..clear()
          ..addEntries(
            result.students
                .where((item) => item.rating != null)
                .map((item) => MapEntry(item.student.id, item.rating!)),
          );
        _saving = false;
        _step = 1;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }

  Future<void> _saveRatings() async {
    final classId = widget.lessonContext.classId;
    if (classId == null || _ratings.length != _selectedIds.length || _saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(teacherToolsRepositoryProvider).rateQuickQuestion(
            classId: classId,
            session: widget.lessonContext.session,
            date: widget.lessonContext.apiDate,
            ratings: _ratings,
          );
      if (!mounted) return;
      setState(() => _saving = false);
      context.showSnackbarSuccess('تم اعتماد تقييم الفهم بنجاح');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: TeacherToolsAppBar(
          title: 'السؤال السريع',
          action: _step == 1
              ? TextButton(
                  onPressed: () => setState(() => _step = 0),
                  child: const Text(
                    'تعديل الاختيار',
                    style: TextStyle(
                      color: AppColors.secondryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : null,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? TeacherToolsLoadError(
                    message: _errorMessage!,
                    onRetry: _load,
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
                        child: Column(
                          children: [
                            TeacherToolsContextCard(
                              lessonContext: widget.lessonContext,
                              compact: true,
                            ),
                            const SizedBox(height: 14),
                            _QuestionProgress(currentStep: _step),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _step == 0
                              ? _StudentSelectionStep(
                                  key: const ValueKey('select-students'),
                                  selectedIds: _selectedIds,
                                  students: _students,
                                  questionController: _questionController,
                                  noteController: _noteController,
                                  onToggle: _toggleStudent,
                                  onRandomSelect: _selectRandomStudents,
                                )
                              : _RatingStep(
                                  key: const ValueKey('rate-students'),
                                  students: _selectedStudents,
                                  ratings: _ratings,
                                  onRated: (studentId, rating) => setState(
                                    () => _ratings[studentId] = rating,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: TeacherToolsPrimaryButton(
            label: _step == 0 ? 'التالي: تقييم الفهم' : 'اعتماد التقييم',
            icon: _step == 0 ? null : Icons.check_circle_outline_rounded,
            onPressed: _loading || _errorMessage != null || _saving
                ? null
                : _step == 0
                    ? _selectedIds.isEmpty
                        ? null
                        : _saveSelection
                    : _ratings.length != _selectedIds.length
                        ? null
                        : _saveRatings,
          ),
        ),
      ),
    );
  }
}

class _QuestionProgress extends StatelessWidget {
  const _QuestionProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProgressStep(
          number: '١',
          label: 'اختيار الطلاب',
          active: currentStep == 0,
          complete: currentStep > 0,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep > 0
                ? AppColors.primaryColor
                : const Color(0xFFE3E3E3),
          ),
        ),
        _ProgressStep(
          number: '٢',
          label: 'تقييم الفهم',
          active: currentStep == 1,
          complete: false,
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.number,
    required this.label,
    required this.active,
    required this.complete,
  });

  final String number;
  final String label;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final highlighted = active || complete;
    return SizedBox(
      width: 105,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlighted ? AppColors.primaryColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: highlighted
                    ? AppColors.primaryColor
                    : const Color(0xFFD5D5D5),
              ),
            ),
            child: complete
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 19)
                : Text(
                    number,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF777777),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: highlighted
                  ? AppColors.secondryColor
                  : const Color(0xFF777777),
              fontSize: 12,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSelectionStep extends StatelessWidget {
  const _StudentSelectionStep({
    super.key,
    required this.selectedIds,
    required this.students,
    required this.questionController,
    required this.noteController,
    required this.onToggle,
    required this.onRandomSelect,
  });

  final Set<int> selectedIds;
  final List<TeacherToolStudent> students;
  final TextEditingController questionController;
  final TextEditingController noteController;
  final ValueChanged<int> onToggle;
  final VoidCallback onRandomSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
      children: [
        PresentStudentsNotice(count: students.length),
        const SizedBox(height: 17),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TeacherToolSectionTitle(
              title: 'من تريد أن تسأل؟',
              subtitle: 'تم اختيار ${selectedIds.length} طلاب',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRandomSelect,
              icon: const Icon(Icons.casino_outlined, size: 18),
              label: const Text('اختيار عشوائي'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth >= 650 ? 5 : 3,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
              mainAxisExtent: 116,
            ),
            itemBuilder: (_, index) {
              final student = students[index];
              final selectedIndex = selectedIds.toList().indexOf(student.id);
              return _SelectableStudentCard(
                student: student,
                selected: selectedIndex >= 0,
                selectionOrder: selectedIndex >= 0 ? selectedIndex + 1 : null,
                onTap: () => onToggle(student.id),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const TeacherToolSectionTitle(
          title: 'تفاصيل السؤال',
          subtitle: 'اختياري — يمكنك كتابتها الآن أو الاكتفاء بالتقييم',
        ),
        const SizedBox(height: 10),
        TextField(
          controller: questionController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'نص السؤال',
            hintText: 'مثال: ما الفكرة الرئيسة في الدرس؟',
            prefixIcon: const Icon(Icons.help_outline_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'ملاحظة للمعلم',
            prefixIcon: const Icon(Icons.sticky_note_2_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectableStudentCard extends StatelessWidget {
  const _SelectableStudentCard({
    required this.student,
    required this.selected,
    required this.selectionOrder,
    required this.onTap,
  });

  final TeacherToolStudent student;
  final bool selected;
  final int? selectionOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('quick-question-student-${student.id}'),
      color: selected ? const Color(0xFFE9FAFA) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 10, 7, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? AppColors.primaryColor : const Color(0xFFE5E5E5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TeacherToolsStudentAvatar(name: student.name, radius: 22),
                    const SizedBox(height: 7),
                    Text(
                      compactStudentName(student.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectionOrder != null)
                PositionedDirectional(
                  top: 0,
                  start: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$selectionOrder',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingStep extends StatelessWidget {
  const _RatingStep({
    super.key,
    required this.students,
    required this.ratings,
    required this.onRated,
  });

  final List<TeacherToolStudent> students;
  final Map<int, QuickQuestionRating> ratings;
  final void Function(int studentId, QuickQuestionRating rating) onRated;

  @override
  Widget build(BuildContext context) {
    final understood = ratings.values
        .where((rating) => rating == QuickQuestionRating.understood)
        .length;
    final partial = ratings.values
        .where((rating) => rating == QuickQuestionRating.partial)
        .length;
    final notUnderstood = ratings.values
        .where((rating) => rating == QuickQuestionRating.notUnderstood)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
      children: [
        Row(
          children: [
            Expanded(
              child: _RatingCount(
                count: understood,
                label: 'فهم',
                color: teacherToolsGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingCount(
                count: partial,
                label: 'فهم جزئي',
                color: teacherToolsAmber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RatingCount(
                count: notUnderstood,
                label: 'لم يفهم',
                color: teacherToolsRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const TeacherToolSectionTitle(
          title: 'قيّم إجابة كل طالب',
          subtitle: 'اختر مستوى الفهم بعد سماع الإجابة',
        ),
        const SizedBox(height: 10),
        ...students.map(
          (student) => _StudentRatingCard(
            student: student,
            rating: ratings[student.id],
            onRated: (rating) => onRated(student.id, rating),
          ),
        ),
      ],
    );
  }
}

class _RatingCount extends StatelessWidget {
  const _RatingCount({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StudentRatingCard extends StatelessWidget {
  const _StudentRatingCard({
    required this.student,
    required this.rating,
    required this.onRated,
  });

  final TeacherToolStudent student;
  final QuickQuestionRating? rating;
  final ValueChanged<QuickQuestionRating> onRated;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              TeacherToolsStudentAvatar(name: student.name, radius: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  compactStudentName(student.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RatingChoice(
                  label: 'فهم',
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  color: teacherToolsGreen,
                  selected: rating == QuickQuestionRating.understood,
                  onTap: () => onRated(QuickQuestionRating.understood),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RatingChoice(
                  label: 'جزئي',
                  icon: Icons.sentiment_neutral_rounded,
                  color: teacherToolsAmber,
                  selected: rating == QuickQuestionRating.partial,
                  onTap: () => onRated(QuickQuestionRating.partial),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RatingChoice(
                  label: 'لم يفهم',
                  icon: Icons.sentiment_dissatisfied_rounded,
                  color: teacherToolsRed,
                  selected: rating == QuickQuestionRating.notUnderstood,
                  onTap: () => onRated(QuickQuestionRating.notUnderstood),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingChoice extends StatelessWidget {
  const _RatingChoice({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
