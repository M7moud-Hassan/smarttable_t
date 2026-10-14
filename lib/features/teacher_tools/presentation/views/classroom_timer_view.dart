import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class ClassroomTimerView extends StatefulWidget {
  const ClassroomTimerView({super.key});

  @override
  State<ClassroomTimerView> createState() => _ClassroomTimerViewState();
}

class _ClassroomTimerViewState extends State<ClassroomTimerView>
    with WidgetsBindingObserver {
  static const _defaultDuration = Duration(minutes: 5);
  static const _presets = <int>[1, 3, 5, 10];

  Duration _duration = _defaultDuration;
  Duration _remaining = _defaultDuration;
  DateTime? _deadline;
  Timer? _ticker;
  bool _isRunning = false;

  int get _remainingSeconds => (_remaining.inMilliseconds / 1000).ceil();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      _updateRemaining();
    }
  }

  void _selectMinutes(int minutes) {
    if (_isRunning) return;
    final duration = Duration(minutes: minutes);
    setState(() {
      _duration = duration;
      _remaining = duration;
    });
  }

  void _adjustMinute(int change) {
    if (_isRunning) return;
    final minutes = (_remaining.inMinutes + change).clamp(1, 60);
    final duration = Duration(minutes: minutes);
    setState(() {
      _duration = duration;
      _remaining = duration;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
      return;
    }

    if (_remaining == Duration.zero) {
      _remaining = _duration;
    }
    _deadline = DateTime.now().add(_remaining);
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _updateRemaining(),
    );
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _setRemainingFromDeadline();
    _ticker?.cancel();
    _deadline = null;
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
      _deadline = null;
      _remaining = _duration;
    });
  }

  void _setRemainingFromDeadline() {
    final deadline = _deadline;
    if (deadline == null) return;
    final remaining = deadline.difference(DateTime.now());
    _remaining = remaining.isNegative ? Duration.zero : remaining;
  }

  void _updateRemaining() {
    if (!mounted || !_isRunning) return;
    _setRemainingFromDeadline();
    if (_remaining == Duration.zero) {
      _ticker?.cancel();
      _deadline = null;
      setState(() => _isRunning = false);
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('انتهى الوقت'),
          ),
        );
      return;
    }
    setState(() {});
  }

  String get _formattedTime {
    final seconds = _remainingSeconds;
    final minutesPart = seconds ~/ 60;
    final secondsPart = seconds % 60;
    return '${minutesPart.toString().padLeft(2, '0')}:'
        '${secondsPart.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_remaining.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0);
    final isFinished = _remaining == Duration.zero;
    final timerColor = isFinished ? teacherToolsRed : AppColors.primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const TeacherToolsAppBar(title: 'مؤقت الحصة'),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FCFC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.phonelink_off_outlined,
                      color: AppColors.primaryColor,
                      size: 21,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'يعمل المؤقت على هذا الجهاز فقط ولا يرسل أي بيانات',
                        style: TextStyle(
                          color: Color(0xFF4F6969),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: SizedBox.square(
                  dimension: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 13,
                          strokeCap: StrokeCap.round,
                          color: timerColor,
                          backgroundColor: timerColor.withValues(alpha: .12),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFinished
                                ? Icons.notifications_active_outlined
                                : Icons.timer_outlined,
                            color: timerColor,
                            size: 34,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formattedTime,
                            key: const ValueKey('classroom-timer-time'),
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isFinished
                                ? 'انتهى الوقت'
                                : _isRunning
                                    ? 'المؤقت يعمل الآن'
                                    : 'جاهز للبدء',
                            style: TextStyle(
                              color: timerColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const TeacherToolSectionTitle(
                title: 'مدة سريعة',
                subtitle: 'اختر مدة أو عدّلها دقيقة بدقيقة',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets
                    .map(
                      (minutes) => ChoiceChip(
                        key: ValueKey('timer-preset-$minutes'),
                        label: Text(
                            '$minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}'),
                        selected: !_isRunning &&
                            _duration == Duration(minutes: minutes),
                        onSelected:
                            _isRunning ? null : (_) => _selectMinutes(minutes),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('timer-remove-minute'),
                      onPressed: _isRunning ? null : () => _adjustMinute(-1),
                      icon: const Icon(Icons.remove_rounded),
                      label: const Text('دقيقة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('timer-add-minute'),
                      onPressed: _isRunning ? null : () => _adjustMinute(1),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('دقيقة'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TeacherToolsPrimaryButton(
                label: _isRunning
                    ? 'إيقاف مؤقت'
                    : isFinished
                        ? 'بدء من جديد'
                        : 'بدء المؤقت',
                icon:
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onPressed: _toggleTimer,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text(
                    'إعادة ضبط',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
