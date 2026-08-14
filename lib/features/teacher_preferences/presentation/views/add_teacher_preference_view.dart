import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/teacher_preferences/data/models/teacher_preference_model.dart';
import 'package:smart_table_app/features/teacher_preferences/presentation/widgets/teacher_preferences_theme.dart';
import 'package:smart_table_app/features/teacher_preferences/providers/teacher_preferences_provider.dart';

class AddTeacherPreferenceView extends ConsumerStatefulWidget {
  const AddTeacherPreferenceView({
    super.key,
    required this.classOption,
    this.existingPreference,
  });

  final TeacherClassOption classOption;
  final TeacherPreference? existingPreference;

  @override
  ConsumerState<AddTeacherPreferenceView> createState() =>
      _AddTeacherPreferenceViewState();
}

class _AddTeacherPreferenceViewState
    extends ConsumerState<AddTeacherPreferenceView> {
  Set<int>? _selectedCourseIds;

  @override
  Widget build(BuildContext context) {
    final courses =
        ref.watch(teacherClassCoursesProvider(widget.classOption.id));
    final selectedCourseIds = _selectedCourseIds ??
        courses.asData?.value
            .where((course) => course.isSelected)
            .map((course) => course.id)
            .toSet() ??
        widget.existingPreference?.courses.map((course) => course.id).toSet() ??
        <int>{};

    return Directionality(
      textDirection: TextDirection.rtl,
      child: TeacherPreferencesTheme(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: const _PreferencesAppBar(title: 'إضافة الرغبات'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.classOption.name,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'المواد المتاحة',
                    style: TextStyle(
                      color: Color(0xFF141752),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: courses.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا يوجد بيانات للعرض',
                          style: TextStyle(fontSize: 17),
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                      children: items
                          .map(
                            (course) => _SubjectTile(
                              course: course,
                              isSelected: selectedCourseIds.contains(course.id),
                              onChanged: () => _toggleCourse(
                                course,
                                selectedCourseIds,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const Center(child: LoadingWidget()),
                  error: (error, _) => CustomErrorWidget(
                    error: error is Exception
                        ? exceptionHandler(context: context, exception: error)
                        : null,
                    onTap: () => ref.invalidate(
                      teacherClassCoursesProvider(widget.classOption.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: SizedBox(
              height: 46,
              child: AppButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(46),
                  textStyle: const TextStyle(fontFamily: 'PingAR'),
                ),
                onPressed: courses.hasValue && selectedCourseIds.isNotEmpty
                    ? () => _save(courses.requireValue, selectedCourseIds)
                    : null,
                child: Text(
                  widget.existingPreference == null &&
                          widget.classOption.wishId == null
                      ? 'إضافة المواد المختارة'
                      : 'حفظ التعديلات',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCourse(
    WishAvailableCourse course,
    Set<int> currentSelection,
  ) {
    if (course.isTaken && !course.isSelected) return;
    setState(() {
      final updated = {...currentSelection};
      if (!updated.add(course.id)) updated.remove(course.id);
      _selectedCourseIds = updated;
    });
  }

  void _save(List<WishAvailableCourse> courses, Set<int> selectedCourseIds) {
    final orderedIds = courses
        .where((course) => selectedCourseIds.contains(course.id))
        .map((course) => course.id)
        .toList(growable: false);

    Navigator.of(context).pop(
      TeacherPreferenceDraft(
        classroomId: widget.classOption.id,
        courseIds: orderedIds,
        note: widget.existingPreference?.note ?? '',
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.course,
    required this.isSelected,
    required this.onChanged,
  });

  final WishAvailableCourse course;
  final bool isSelected;
  final VoidCallback onChanged;

  bool get isUnavailable => course.isTaken && !course.isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUnavailable ? null : onChanged,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primaryColor, width: 0.55),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: TextStyle(
                        color: isUnavailable
                            ? AppColors.textGrayColor
                            : const Color(0xFF2B2B2B),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isUnavailable)
                      Text(
                        course.assignedTeacherName == null
                            ? 'المادة مسندة لمعلم آخر'
                            : 'مسندة إلى ${course.assignedTeacherName}',
                        style: const TextStyle(
                          color: AppColors.textGrayColor,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Checkbox(
              value: isSelected,
              activeColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.textGrayColor),
              visualDensity: VisualDensity.compact,
              onChanged: isUnavailable ? null : (_) => onChanged(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _PreferencesAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 21,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
