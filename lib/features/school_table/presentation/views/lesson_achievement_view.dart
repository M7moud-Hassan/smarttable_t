import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_achievement_model.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/providers/lesson_achievement_provider.dart';

class LessonAchievementView extends ConsumerStatefulWidget {
  const LessonAchievementView({
    super.key,
    required this.lesson,
    this.initialDate,
  });

  final LessonModel lesson;
  final DateTime? initialDate;

  @override
  ConsumerState<LessonAchievementView> createState() =>
      _LessonAchievementViewState();
}

class _LessonAchievementViewState extends ConsumerState<LessonAchievementView> {
  final _formKey = GlobalKey<FormState>();
  final _achievementController = TextEditingController();
  final _homeworkController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;
  LessonAchievement? _existingAchievement;
  Object? _loadError;
  bool _isLoadingAchievement = false;
  int _loadRevision = 0;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.initialDate ?? DateTime.now();
    _selectedDate = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );
    Future.microtask(_loadExistingAchievement);
  }

  @override
  void dispose() {
    _achievementController.dispose();
    _homeworkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(lessonAchievementSubmitProvider);
    final isBusy = submitState.isLoading || _isLoadingAchievement;
    final canEdit = !isBusy && _loadError == null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.secondryColor),
          title: const Text(
            'إنجاز الحصة',
            style: TextStyle(
              color: AppColors.secondryColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              _LessonSummary(lesson: widget.lesson),
              const SizedBox(height: 22),
              const _FieldLabel('التاريخ'),
              const SizedBox(height: 8),
              InputDecorator(
                key: const Key('lesson-achievement-date'),
                decoration: _inputDecoration().copyWith(
                  filled: true,
                  fillColor: AppColors.grayBordredColor.withValues(alpha: 0.2),
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.textGrayColor,
                  ),
                ),
                child: Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isLoadingAchievement) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primaryColor,
                ),
              ] else if (_loadError != null) ...[
                const SizedBox(height: 12),
                _LoadErrorCard(onRetry: _loadExistingAchievement),
              ] else if (_existingAchievement != null) ...[
                const SizedBox(height: 12),
                const _ExistingAchievementCard(),
              ],
              const SizedBox(height: 18),
              _LessonTextField(
                key: const Key('lesson-achievement-field'),
                label: 'إنجاز الحصة',
                hint: 'اكتب ما تم شرحه وإنجازه في الحصة',
                controller: _achievementController,
                enabled: canEdit,
                requiredMessage: 'يرجى كتابة إنجاز الحصة',
              ),
              const SizedBox(height: 18),
              _LessonTextField(
                key: const Key('lesson-homework-field'),
                label: 'الواجب المنزلي',
                hint: 'اكتب الواجب المطلوب من الطلاب',
                controller: _homeworkController,
                enabled: canEdit,
                requiredMessage: 'يرجى كتابة الواجب المنزلي',
              ),
              const SizedBox(height: 18),
              _LessonTextField(
                key: const Key('lesson-notes-field'),
                label: 'ملاحظات',
                hint: 'أضف أي ملاحظات (اختياري)',
                controller: _notesController,
                enabled: canEdit,
                isRequired: false,
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    height: 54,
                    child: AppButton(
                      onPressed: canEdit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(constraints.maxWidth, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: submitState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _existingAchievement == null
                                  ? 'حفظ إنجاز الحصة'
                                  : 'حفظ التعديلات',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              if (_existingAchievement != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        key: const Key('delete-lesson-achievement'),
                        onPressed: canEdit ? _confirmDelete : null,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('حذف'),
                        style: OutlinedButton.styleFrom(
                          fixedSize: Size(constraints.maxWidth, 54),
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadExistingAchievement() async {
    final cellNumber = widget.lesson.cellNumber;
    if (cellNumber == null) return;

    final revision = ++_loadRevision;
    if (mounted) {
      setState(() {
        _isLoadingAchievement = true;
        _loadError = null;
      });
    }

    try {
      final achievement = await ref.refresh(
        lessonAchievementForCellProvider(
          LessonAchievementLookup(
            cellNumber: cellNumber,
            date: _selectedDate,
          ),
        ).future,
      );
      if (!mounted || revision != _loadRevision) return;
      final achievementDate = achievement?.date;
      if (achievementDate != null) _selectedDate = achievementDate;
      _achievementController.text = achievement?.achievement ?? '';
      _homeworkController.text = achievement?.homework ?? '';
      _notesController.text = achievement?.notes ?? '';
      setState(() {
        _existingAchievement = achievement;
        _isLoadingAchievement = false;
      });
    } catch (error) {
      if (!mounted || revision != _loadRevision) return;
      setState(() {
        _isLoadingAchievement = false;
        _loadError = error;
      });
    }
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() != true) return;

    final cellNumber = widget.lesson.cellNumber;
    if (cellNumber == null) {
      context.showSnackbarError('لا يوجد رقم خلية لهذه الحصة');
      return;
    }

    final success =
        await ref.read(lessonAchievementSubmitProvider.notifier).save(
              draft: LessonAchievementDraft(
                cellNumber: cellNumber,
                date: _selectedDate,
                achievement: _achievementController.text,
                homework: _homeworkController.text,
                notes: _notesController.text,
              ),
              existing: _existingAchievement,
            );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    final error = ref.read(lessonAchievementSubmitProvider).error;
    final message = error is Exception
        ? exceptionHandler(context: context, exception: error)
        : null;
    context.showSnackbarError(message ?? context.locale.errorMessage);
  }

  Future<void> _confirmDelete() async {
    final achievement = _existingAchievement;
    if (achievement == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف إنجاز الحصة'),
        content: const Text('هل تريد حذف إنجاز الحصة لهذا التاريخ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(lessonAchievementSubmitProvider.notifier)
        .delete(achievement.id);
    if (!mounted) return;
    if (success) {
      setState(() => _existingAchievement = null);
      _clearFields();
      context.showSnackbarSuccess('تم حذف إنجاز الحصة بنجاح');
      return;
    }

    final error = ref.read(lessonAchievementSubmitProvider).error;
    final message = error is Exception
        ? exceptionHandler(context: context, exception: error)
        : null;
    context.showSnackbarError(message ?? context.locale.errorMessage);
  }

  void _clearFields() {
    _achievementController.clear();
    _homeworkController.clear();
    _notesController.clear();
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _ExistingAchievementCard extends StatelessWidget {
  const _ExistingAchievementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'يوجد إنجاز مسجل لهذا التاريخ ويمكنك تعديله أو حذفه.',
              style: TextStyle(
                color: AppColors.secondryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadErrorCard extends StatelessWidget {
  const _LoadErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'تعذر التحقق من إنجاز الحصة المسجل.',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _LessonSummary extends StatelessWidget {
  const _LessonSummary({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (lesson.subjectName.isNotEmpty) lesson.subjectName,
      if (lesson.classroomName.isNotEmpty) lesson.classroomName,
      if (lesson.classNumberText.trim().isNotEmpty) lesson.classNumberText,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: AppColors.primaryColor,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              details.join(' • '),
              style: const TextStyle(
                color: AppColors.secondryColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTextField extends StatelessWidget {
  const _LessonTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    this.isRequired = true,
    this.requiredMessage,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final bool isRequired;
  final String? requiredMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          textInputAction: TextInputAction.newline,
          validator: isRequired
              ? (value) =>
                  value == null || value.trim().isEmpty ? requiredMessage : null
              : null,
          decoration: _inputDecoration().copyWith(
            hintText: hint,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.secondryColor,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(
      color: AppColors.textGrayColor,
      fontSize: 13,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.grayBordredColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.grayBordredColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.primaryColor,
        width: 1.2,
      ),
    ),
  );
}
