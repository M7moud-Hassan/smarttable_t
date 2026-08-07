import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';
import 'package:smart_table_app/features/school_table/providers/days_provider.dart';
import 'package:smart_table_app/features/waiting_classes/presentation/views/secure_class_view.dart';
import '../../../../core/constants/constants.dart';

void showLessonDetailsBottomSheet(
    BuildContext context, WidgetRef ref, LessonModel lesson, String teacherName,
    {String? teacherImageUrl}) {
  final daysAsync = ref.read(daysProvider);
  final String dayName = daysAsync.maybeWhen(
        data: (days) => days
            .firstWhere((d) => d.dayId == lesson.dayId,
                orElse: () => days.first)
            .dayName,
        orElse: () => "اليوم",
      ) ??
      "اليوم";
  final originalTeacherName =
      lesson.originalTeacherName?.trim().isNotEmpty == true
          ? lesson.originalTeacherName!.trim()
          : null;
  final displayedTeacherName = lesson.isWaitingSlot
      ? originalTeacherName ?? ""
      : originalTeacherName ?? teacherName;
  final subjectName = lesson.subjectName;
  final classroomName = lesson.classroomName;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Close button and Title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      lesson.isWaitingSlot
                          ? "تفاصيل حصة الانتظار"
                          : "تفاصيل الحصة",
                      style: context.textTheme.titleLarge!.copyWith(
                        color: AppColors.secondryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: AppColors.secondryColor, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Teacher Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _TeacherAvatar(
                    imageUrl: lesson.isWaitingSlot
                        ? lesson.teacherImageUrl
                        : lesson.teacherImageUrl ?? teacherImageUrl,
                    size: 65,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.isWaitingSlot ? "المعلم الأساسي" : "المعلم",
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: AppColors.secondryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayedTeacherName.isEmpty
                              ? "غير محدد"
                              : displayedTeacherName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium!.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 85,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: context.textTheme.titleMedium!.copyWith(
                              color: AppColors.secondryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "الموافق : ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: AppColors.secondryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lesson.classNumberText,
                            style: context.textTheme.bodyLarge!.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          if (subjectName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _DetailLine(label: "المادة", value: subjectName),
                          ],
                          if (classroomName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _DetailLine(label: "الفصل", value: classroomName),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Bottom Buttons
              if (lesson.canBeSecured) ...[
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(SecureClassView(
                        lesson: lesson,
                        fromTeacherTable: true,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "تأمين الحصة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lesson.canBeSecured
                        ? Colors.grey[200]
                        : AppColors.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    "حسناً",
                    style: TextStyle(
                      color: lesson.canBeSecured
                          ? AppColors.secondryColor
                          : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TeacherAvatar extends StatelessWidget {
  const _TeacherAvatar({required this.imageUrl, required this.size});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppColors.primaryColor.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        color: AppColors.secondryColor,
        size: size * 0.56,
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.trim().isNotEmpty == true
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "$label: "),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppColors.secondryColor),
          ),
        ],
      ),
      style: context.textTheme.bodyLarge!.copyWith(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
