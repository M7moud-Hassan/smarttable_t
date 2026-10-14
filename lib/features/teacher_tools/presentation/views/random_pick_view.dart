import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_api_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/repositories/teacher_tools_repository.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class RandomPickView extends ConsumerStatefulWidget {
  const RandomPickView({
    super.key,
    required this.lessonContext,
  });

  final TeacherToolsContext lessonContext;

  @override
  ConsumerState<RandomPickView> createState() => _RandomPickViewState();
}

class _RandomPickViewState extends ConsumerState<RandomPickView> {
  int _count = 1;
  bool _cycleReset = false;
  List<TeacherToolStudent> _picked = const [];
  List<TeacherToolStudent> _alreadyPicked = const [];
  List<TeacherToolStudent> _students = const [];
  bool _loading = true;
  bool _picking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _students = widget.lessonContext.availableStudents;
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
        repository.getPresentStudents(
          classId: classId,
          session: widget.lessonContext.session,
          date: widget.lessonContext.apiDate,
        ),
        repository.getRandomPick(
          classId: classId,
          session: widget.lessonContext.session,
          date: widget.lessonContext.apiDate,
        ),
      ]);
      final roster = results[0] as PresentStudentsData;
      final state = results[1] as RandomPickResult;
      if (!mounted) return;
      setState(() {
        _students = roster.students;
        _picked = state.picked;
        _alreadyPicked = state.alreadyPickedToday;
        _cycleReset = state.cycleReset;
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

  Future<void> _pickStudents() async {
    final classId = widget.lessonContext.classId;
    if (classId == null || _picking || _students.isEmpty) return;
    setState(() => _picking = true);
    try {
      final result =
          await ref.read(teacherToolsRepositoryProvider).pickRandomStudents(
                classId: classId,
                session: widget.lessonContext.session,
                date: widget.lessonContext.apiDate,
                count: _count,
              );
      if (!mounted) return;
      setState(() {
        _picked = result.picked;
        _alreadyPicked = result.alreadyPickedToday;
        _cycleReset = result.cycleReset;
        _picking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _picking = false);
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
        appBar: const TeacherToolsAppBar(title: 'الاختيار العشوائي'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? TeacherToolsLoadError(
                    message: _errorMessage!,
                    onRetry: _load,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    children: [
                      TeacherToolsContextCard(
                        lessonContext: widget.lessonContext,
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                      PresentStudentsNotice(count: _students.length),
                      const SizedBox(height: 20),
                      const TeacherToolSectionTitle(
                        title: 'كم طالبًا تريد؟',
                        subtitle: 'يمكن اختيار من طالب واحد إلى ٦ طلاب',
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: List.generate(6, (index) {
                          final value = index + 1;
                          final selected = value == _count;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                end: index == 5 ? 0 : 7,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(13),
                                onTap: value > _students.length
                                    ? null
                                    : () => setState(() => _count = value),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  height: 46,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: value > _students.length
                                        ? const Color(0xFFF1F1F1)
                                        : selected
                                            ? AppColors.primaryColor
                                            : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primaryColor
                                          : const Color(0xFFE5E5E5),
                                    ),
                                  ),
                                  child: Text(
                                    '$value',
                                    style: TextStyle(
                                      color: value > _students.length
                                          ? const Color(0xFFBDBDBD)
                                          : selected
                                              ? Colors.white
                                              : Colors.black87,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _picking ? null : _pickStudents,
                          child: Container(
                            width: 142,
                            height: 142,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.secondryColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: .28),
                                  blurRadius: 20,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_picking)
                                  const SizedBox(
                                    width: 34,
                                    height: 34,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.casino_rounded,
                                    color: Colors.white,
                                    size: 43,
                                  ),
                                const SizedBox(height: 5),
                                Text(
                                  _picking
                                      ? 'جارٍ الاختيار...'
                                      : 'ابدأ الاختيار',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_picked.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            const Expanded(
                              child: TeacherToolSectionTitle(
                                title: 'تم الاختيار',
                                subtitle:
                                    'اسألهم الآن ثم يمكنك الاختيار مرة أخرى',
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'اختيار مرة أخرى',
                              onPressed: _picking ? null : _pickStudents,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_cycleReset)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: teacherToolsAmber.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.autorenew_rounded,
                                  color: teacherToolsAmber,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'اكتملت دورة الفصل وبدأت دورة اختيار جديدة.',
                                    style: TextStyle(
                                      color: Color(0xFF8A6512),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: Column(
                            key: ValueKey(
                                _picked.map((student) => student.id).join('-')),
                            children: _picked
                                .map((student) =>
                                    _PickedStudentCard(student: student))
                                .toList(growable: false),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TeacherToolSectionTitle(
                        title: 'اختيروا اليوم',
                        subtitle:
                            '${_alreadyPicked.length} من الطلاب أخذوا دورهم',
                      ),
                      const SizedBox(height: 10),
                      if (_alreadyPicked.isEmpty)
                        const _EmptyPreviousPicks()
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _alreadyPicked
                              .map(
                                (student) => Chip(
                                  avatar: TeacherToolsStudentAvatar(
                                    name: student.name,
                                    radius: 14,
                                  ),
                                  label: Text(
                                    student.name.split(' ').take(2).join(' '),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  side: BorderSide.none,
                                  backgroundColor: const Color(0xFFF3F6F6),
                                ),
                              )
                              .toList(growable: false),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _PickedStudentCard extends StatelessWidget {
  const _PickedStudentCard({required this.student});

  final TeacherToolStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FCFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          TeacherToolsStudentAvatar(name: student.name),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              student.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              student.number,
              style: const TextStyle(
                color: AppColors.secondryColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPreviousPicks extends StatelessWidget {
  const _EmptyPreviousPicks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'لم يتم اختيار أي طالب بعد',
        style: TextStyle(color: Color(0xFF777777)),
      ),
    );
  }
}
