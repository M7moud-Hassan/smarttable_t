import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/waiting_classes/data/models/substitute_model.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_notifier.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_provider.dart';

import '../../../../core/widgets/custom_error_widget.dart';
import 'secure_class_success_view.dart';

class SecureClassView extends ConsumerStatefulWidget {
  final LessonModel lesson;
  final bool fromTeacherTable;

  const SecureClassView({
    super.key,
    required this.lesson,
    this.fromTeacherTable = false,
  });

  @override
  ConsumerState<SecureClassView> createState() => _SecureClassViewState();
}

class _SecureClassViewState extends ConsumerState<SecureClassView> {
  SubstituteModel? _selectedTeacher;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showTeacherSelectionBottomSheet(
      BuildContext context, List<SubstituteModel> substitutes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: context.screenSize.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    "اختر معلماً بديلاً",
                    style: context.textTheme.titleLarge!.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: substitutes.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final teacher = substitutes[index];
                        final bool isSelected =
                            _selectedTeacher?.id == teacher.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          onTap: () {
                            setState(() {
                              _selectedTeacher = teacher;
                            });
                            Navigator.pop(context);
                          },
                          leading: CircleAvatar(
                            backgroundColor: teacher.available
                                ? AppColors.primaryColor.withValues(alpha: 0.1)
                                : Colors.grey[200],
                            child: Icon(
                              Icons.person_rounded,
                              color: teacher.available
                                  ? AppColors.primaryColor
                                  : Colors.grey[500],
                            ),
                          ),
                          title: Text(
                            teacher.name,
                            style: context.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: teacher.available
                                  ? const Color(0xFF1E3A5F)
                                  : Colors.grey[600],
                            ),
                          ),
                          subtitle: teacher.available
                              ? null
                              : Text(
                                  teacher.busyReason ??
                                      "المعلم غير متاح في هذه الحصة",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryColor,
                                  size: 26,
                                )
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? cellNumber = widget.lesson.cellNumber;

    // Fallback if cellNumber couldn't be extracted
    if (cellNumber == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("تأمين الحصة"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "عذراً، لم نتمكن من تحديد رقم الحصة لتأمينها.",
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium!.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    final substitutesAsync = ref.watch(substitutesProvider(cellNumber));

    // Determine states based on selection
    final bool isSelected = _selectedTeacher != null;
    final bool hasError = isSelected && !_selectedTeacher!.available;
    final bool isButtonActive = isSelected && _selectedTeacher!.available;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: AppColors.primaryColor,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "تأمين الحصة",
          style: context.textTheme.titleLarge!.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 1.5),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.secondryColor,
              ),
            ),
          ),
        ],
      ),
      body: substitutesAsync.when(
        data: (substitutes) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  // Headline Text
                  Text(
                    "اختر زميلاً متاحاً لتغطية الحصة المختارة في جدولك",
                    textAlign: TextAlign.right,
                    style: context.textTheme.titleLarge!.copyWith(
                      color: const Color(0xFF1E2F38),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Colleague Selector Card / Dropdown
                  GestureDetector(
                    onTap: () =>
                        _showTeacherSelectionBottomSheet(context, substitutes),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasError
                              ? Colors.red
                              : isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[300]!,
                          width: hasError || isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color:
                                hasError ? Colors.red : AppColors.primaryColor,
                            size: 26,
                          ),
                          Expanded(
                            child: Text(
                              isSelected
                                  ? _selectedTeacher!.name
                                  : "اختر معلماً...",
                              textAlign: TextAlign.right,
                              style: context.textTheme.titleMedium!.copyWith(
                                color: isSelected
                                    ? (hasError ? Colors.red : Colors.black87)
                                    : Colors.grey[400],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Error Text below selector if applicable
                  if (hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      _selectedTeacher?.busyReason ?? "المعلم لديه حصة أخرى",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Custom Note Field
                  Text(
                    "ملاحظة إضافية (اختياري)",
                    textAlign: TextAlign.right,
                    style: context.textTheme.titleMedium!.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "اكتب ملاحظة أو توجيه للمعلم البديل...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 1.5),
                      ),
                    ),
                    maxLines: 3,
                  ),

                  const Spacer(),

                  // Bottom action button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isButtonActive
                          ? () async {
                              final navigator = Navigator.of(context);
                              final success = await ref
                                  .read(waitingClassNotifierProvider.notifier)
                                  .secureClassWithSubstitute(
                                    cellNumber,
                                    _selectedTeacher!.id,
                                    _noteController.text,
                                    fromTeacherTable: widget.fromTeacherTable,
                                  );
                              if (success && mounted) {
                                navigator.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SecureClassSuccessView(),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonActive
                            ? AppColors.primaryColor
                            : const Color(0xFF8A8A8A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        "تأكيد الاختيار",
                        style: TextStyle(
                          color: isButtonActive ? Colors.white : Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(
          child: CustomErrorWidget(
            error: error.toString(),
            onTap: () => ref.invalidate(substitutesProvider(cellNumber)),
          ),
        ),
        loading: () => const Center(child: LoadingWidget()),
      ),
    );
  }
}
