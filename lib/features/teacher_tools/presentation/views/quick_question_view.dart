import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/utils/student_name_formatter.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_api_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/repositories/teacher_tools_repository.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class QuickQuestionView extends ConsumerStatefulWidget {
  const QuickQuestionView({super.key, required this.lessonContext});
  final TeacherToolsContext lessonContext;
  @override
  ConsumerState<QuickQuestionView> createState() => _QuickQuestionViewState();
}

class _QuickQuestionViewState extends ConsumerState<QuickQuestionView> {
  List<TeacherToolStudent> _students = const [];
  final Set<int> _selected = {};
  QuickQuestionGame? _game;
  bool _busy = true;
  String? _error;
  int _randomCount = 4;
  TeacherToolsContext get _slot => widget.lessonContext;
  TeacherToolsRepository get _repository =>
      ref.read(teacherToolsRepositoryProvider);
  bool get _started => _game?.players.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final classId = _slot.classId;
      if (classId == null) throw StateError('تعذر تحديد الفصل لهذه الحصة');
      final results = await Future.wait<Object>([
        _repository.getPresentStudents(
            classId: classId, session: _slot.session, date: _slot.apiDate),
        _repository.getQuickQuestionGame(
            classId: classId, session: _slot.session, date: _slot.apiDate),
      ]);
      if (!mounted) return;
      setState(() {
        _students = (results[0] as PresentStudentsData).students;
        _game = results[1] as QuickQuestionGame;
        _selected
            .removeWhere((id) => !_students.any((student) => student.id == id));
      });
    } catch (error) {
      if (mounted) setState(() => _error = perseveranceErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _mutate(
      {String? action, int? studentId, bool finish = false}) async {
    if (_busy || _error != null || _slot.classId == null) return;
    setState(() => _busy = true);
    try {
      final QuickQuestionGame result;
      if (finish) {
        result = await _repository.finishQuickQuestionGame(
            classId: _slot.classId!,
            session: _slot.session,
            date: _slot.apiDate);
      } else if (action != null) {
        result = await _repository.scoreQuickQuestionGame(
            classId: _slot.classId!,
            session: _slot.session,
            date: _slot.apiDate,
            action: action,
            studentId: studentId);
      } else {
        result = await _repository.startQuickQuestionGame(
            classId: _slot.classId!,
            session: _slot.session,
            date: _slot.apiDate,
            studentIds: _selected.toList());
        if (result.players.isEmpty) throw StateError('تعذر استعادة المشاركين');
      }
      if (mounted) setState(() => _game = result);
    } catch (error) {
      // The write may have succeeded. Require a state refresh before another action.
      if (mounted) {
        setState(() => _error =
            'تعذر تأكيد حالة المسابقة. أعد التحميل قبل المتابعة.\n${perseveranceErrorMessage(error)}');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static const _teal = Color(0xFF259CA6);
  static const _ink = Color(0xFF213D46);

  void _toggle(TeacherToolStudent student) {
    if (_started) {
      _mutate(action: 'award', studentId: student.id);
      return;
    }
    if (!_selected.contains(student.id) && _selected.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يمكن اختيار ٦ طلاب كحد أقصى')));
      return;
    }
    setState(() {
      if (!_selected.remove(student.id)) _selected.add(student.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final finished = _game?.finished == true;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FA),
        appBar: const TeacherToolsAppBar(title: 'السؤال السريع'),
        body: _error != null
            ? TeacherToolsLoadError(message: _error!, onRetry: _load)
            : _busy && _game == null
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(slivers: [
                    SliverToBoxAdapter(
                        child: Column(children: [
                      SizedBox(
                          height: 3,
                          child:
                              _busy ? const LinearProgressIndicator() : null),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: _contextStrip()),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _header(finished)),
                      if (!_started)
                        Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                            child: _selectionControls()),
                      if (!_started && _students.isEmpty)
                        const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('لا يوجد طلاب حاضرون لهذه الحصة')),
                    ])),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      sliver:
                          SliverLayoutBuilder(builder: (context, constraints) {
                        final students = _started
                            ? _game!.players.map((p) => p.student).toList()
                            : _students;
                        final columns =
                            constraints.crossAxisExtent >= 600 ? 3 : 2;
                        final textScale =
                            MediaQuery.textScalerOf(context).scale(14) / 14;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisExtent: (_started ? 190 : 116) +
                                      (textScale - 1).clamp(0, 2) * 60,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12),
                          delegate: SliverChildBuilderDelegate(
                              (context, index) => _studentCard(
                                  students[index], index, finished),
                              childCount: students.length),
                        );
                      }),
                    ),
                  ]),
        bottomNavigationBar: _error != null || finished ? null : _footer(),
      ),
    );
  }

  Widget _contextStrip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2ECEE))),
        child: Row(children: [
          const Icon(Icons.school_outlined, color: _teal, size: 19),
          const SizedBox(width: 8),
          Expanded(
              child: Text('${_slot.className} · ${_slot.sessionLabel}',
                  style: const TextStyle(
                      fontSize: 12, color: _ink, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(_slot.apiDate.replaceAll('-', '/'),
              style: const TextStyle(fontSize: 11, color: Color(0xFF73858B))),
        ]),
      );

  Widget _header(bool finished) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: const Color(0xFFE1F2F2),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  finished
                      ? Icons.emoji_events_rounded
                      : _started
                          ? Icons.bolt_rounded
                          : Icons.groups_2_outlined,
                  color: _teal,
                  size: 24)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  finished
                      ? 'نتيجة المسابقة'
                      : _started
                          ? 'من الأسرع؟'
                          : 'اختر المشاركين في المسابقة',
                  style: const TextStyle(
                      fontSize: 19,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                      color: _ink))),
          if (_started && !finished)
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFFE2F4EB),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('جارية',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF27835A),
                        fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 10),
        Text(
            _started
                ? (finished
                    ? 'انتهت المسابقة — النتائج أدناه'
                    : 'اضغط اسم أول طالب يجيب لمنحه نقطة')
                : 'اختر حتى ٦ طلاب، أو دع الاختيار لنا',
            style: const TextStyle(
                fontSize: 12, height: 1.6, color: Color(0xFF73858B))),
        if (finished && _game!.winnerIds.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  'الفائز: ${_game!.players.where((p) => _game!.winnerIds.contains(p.student.id)).map((p) => p.student.name).join('، ')}',
                  style: const TextStyle(
                      color: _ink, fontWeight: FontWeight.bold))),
        if (finished && _game!.message.isNotEmpty) Text(_game!.message),
      ]);

  Widget _selectionControls() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2ECEE))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle_outline, size: 17, color: _teal),
            const SizedBox(width: 6),
            Expanded(
                child: Text('تم اختيار ${_selected.length} طلاب',
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700))),
            Text('${_selected.length} / 6',
                style: const TextStyle(
                    color: _teal, fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          LayoutBuilder(
              builder: (context, constraints) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF2F7F8),
                              borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                            value: _randomCount,
                            isDense: true,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _ink,
                                fontWeight: FontWeight.w700),
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            items: [
                              for (final count in [2, 3, 4, 5, 6])
                                DropdownMenuItem(
                                    value: count, child: Text('$count طلاب'))
                            ],
                            onChanged: _busy
                                ? null
                                : (value) =>
                                    setState(() => _randomCount = value!),
                          )),
                        ),
                        TextButton.icon(
                            style: TextButton.styleFrom(
                                foregroundColor: _teal,
                                textStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: _busy || _students.isEmpty
                                ? null
                                : () {
                                    final shuffled = [..._students]..shuffle();
                                    setState(() {
                                      _selected.clear();
                                      _selected.addAll(shuffled
                                          .take(_randomCount)
                                          .map((s) => s.id));
                                    });
                                  },
                            icon: const Icon(Icons.shuffle_rounded, size: 18),
                            label: const Text('اختيار عشوائي')),
                      ])),
        ]),
      );

  Widget _studentCard(TeacherToolStudent student, int index, bool finished) {
    final selected = !_started && _selected.contains(student.id);
    final winner = finished && _game!.winnerIds.contains(student.id);
    final score = _started ? _game!.players[index].score : 0;
    final highScore = _started
        ? _game!.players
            .fold<int>(0, (best, p) => p.score > best ? p.score : best)
        : 0;
    final leading = !finished && highScore > 0 && score == highScore;
    final accent = winner || leading ? const Color(0xFFB88220) : _teal;
    return Semantics(
      selected: selected,
      button: !finished,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: winner || leading
              ? const Color(0xFFFFF9EB)
              : selected
                  ? const Color(0xFFE7F5F4)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: winner || leading
                  ? const Color(0xFFE9CC88)
                  : selected
                      ? _teal
                      : const Color(0xFFE1EAED),
              width: selected ? 1.6 : 1),
        ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('quick-question-student-${student.id}'),
              borderRadius: BorderRadius.circular(20),
              onTap: _busy || finished ? null : () => _toggle(student),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: accent.withValues(alpha: .09),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(
                                  winner || leading
                                      ? Icons.emoji_events_outlined
                                      : Icons.person_outline_rounded,
                                  color: accent,
                                  size: 22)),
                          const Spacer(),
                          if (!_started)
                            Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color:
                                    selected ? _teal : const Color(0xFFCCDADD),
                                size: 21),
                          if (_started && !finished)
                            Icon(Icons.add_circle_outline_rounded,
                                color: accent.withValues(alpha: .6), size: 21),
                        ]),
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(compactStudentName(student.name),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: _ink,
                                    fontWeight: FontWeight.w700))),
                        if (_started) ...[
                          const Spacer(),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text('$score',
                                        key: ValueKey(score),
                                        semanticsLabel:
                                            '${student.name}: $score نقطة',
                                        style: TextStyle(
                                            fontSize: 38,
                                            height: 1.1,
                                            color: accent,
                                            fontWeight: FontWeight.w800))),
                                const SizedBox(width: 6),
                                const Text('نقطة',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF73858B))),
                              ]),
                          if (winner || leading)
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text(winner ? 'الفائز' : 'في الصدارة',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: accent,
                                        fontWeight: FontWeight.w700))),
                        ],
                      ])),
            )),
      ),
    );
  }

  Widget _footer() => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2ECEE)))),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_started) ...[
              Row(children: [
                Expanded(
                    child: _secondaryAction('تراجع', Icons.undo_rounded,
                        () => _mutate(action: 'undo'))),
                const SizedBox(width: 10),
                Expanded(
                    child: _secondaryAction(
                        'تخطي السؤال',
                        Icons.skip_next_rounded,
                        () => _mutate(action: 'skip'))),
              ]),
              const SizedBox(height: 12),
            ],
            SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFDBE7E9),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  onPressed: _busy || (!_started && _selected.isEmpty)
                      ? null
                      : () => _mutate(finish: _started),
                  icon: Icon(
                      _started ? Icons.flag_outlined : Icons.play_arrow_rounded,
                      size: 21),
                  label: Text(_started ? 'إنهاء المسابقة' : 'بدء المسابقة'),
                )),
          ]),
        ),
      );

  Widget _secondaryAction(String label, IconData icon, VoidCallback onTap) =>
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            backgroundColor: const Color(0xFFF7FAFB),
            side: const BorderSide(color: Color(0xFFE0EAED)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        onPressed: _busy ? null : onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
}
