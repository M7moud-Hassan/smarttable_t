import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/core/widgets/confirm_dialog_widget.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/teacher_preferences/data/models/teacher_preference_model.dart';
import 'package:smart_table_app/features/teacher_preferences/presentation/views/add_teacher_preference_view.dart';
import 'package:smart_table_app/features/teacher_preferences/presentation/views/teacher_preference_success_view.dart';
import 'package:smart_table_app/features/teacher_preferences/presentation/widgets/teacher_preferences_theme.dart';
import 'package:smart_table_app/features/teacher_preferences/providers/teacher_preferences_provider.dart';

class TeacherPreferencesView extends ConsumerStatefulWidget {
  const TeacherPreferencesView({super.key});

  @override
  ConsumerState<TeacherPreferencesView> createState() =>
      _TeacherPreferencesViewState();
}

class _TeacherPreferencesViewState
    extends ConsumerState<TeacherPreferencesView> {
  final _searchController = TextEditingController();

  int _selectedTab = 0;
  bool _isSearchVisible = false;

  bool get _isListTab => _selectedTab == 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(teacherPreferencesProvider);
    final classOptions = ref.watch(teacherClassOptionsProvider);
    final action = ref.watch(teacherPreferencesActionProvider);
    final query = _searchController.text.trim();

    final visiblePreferences = preferences.whenData(
      (items) => query.isEmpty
          ? items
          : items
              .where(
                (item) =>
                    item.className.contains(query) ||
                    item.subjects.any((subject) => subject.contains(query)),
              )
              .toList(growable: false),
    );
    final visibleClasses = classOptions.whenData(
      (items) => query.isEmpty
          ? items
          : items
              .where((item) => item.name.contains(query))
              .toList(growable: false),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: TeacherPreferencesTheme(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _TeacherPreferencesAppBar(
            title: _isListTab ? 'قائمة الرغبات' : 'تسجيل الرغبات',
          ),
          body: Stack(
            children: [
              Positioned.fill(
                bottom: 86,
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: !_isSearchVisible
                          ? const SizedBox.shrink()
                          : Padding(
                              key: const ValueKey('preference-search'),
                              padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: _isListTab
                                        ? 'ابحث في الرغبات'
                                        : 'ابحث عن فصل',
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      color: AppColors.primaryColor,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: 'إغلاق البحث',
                                      onPressed: _closeSearch,
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 19,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.grayColor,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _isListTab
                            ? visiblePreferences.when(
                                data: (items) => _PreferencesList(
                                  key: const ValueKey('preferences-list'),
                                  preferences: items,
                                  isSearching: query.isNotEmpty,
                                  onEdit: _editPreference,
                                  onDelete: _confirmDeletePreference,
                                ),
                                loading: () => const Center(
                                  key: ValueKey('preferences-loading'),
                                  child: LoadingWidget(),
                                ),
                                error: (error, _) => CustomErrorWidget(
                                  key: const ValueKey('preferences-error'),
                                  error: _errorMessage(error),
                                  onTap: () => ref
                                      .invalidate(teacherPreferencesProvider),
                                ),
                              )
                            : visibleClasses.when(
                                data: (items) => _ClassRegistrationList(
                                  key: const ValueKey('registration-list'),
                                  classOptions: items,
                                  isSearching: query.isNotEmpty,
                                  onClassSelected: _openClass,
                                ),
                                loading: () => const Center(
                                  key: ValueKey('classrooms-loading'),
                                  child: LoadingWidget(),
                                ),
                                error: (error, _) => CustomErrorWidget(
                                  key: const ValueKey('classrooms-error'),
                                  error: _errorMessage(error),
                                  onTap: () => ref
                                      .invalidate(teacherClassOptionsProvider),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                left: 18,
                bottom: 12,
                child: Row(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: FloatingActionButton(
                        heroTag: 'teacher-preferences-search',
                        tooltip: 'بحث',
                        elevation: 2,
                        shape: const CircleBorder(),
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        onPressed: () {
                          setState(
                            () => _isSearchVisible = !_isSearchVisible,
                          );
                          if (!_isSearchVisible) _searchController.clear();
                        },
                        child: const Icon(Icons.search_rounded, size: 29),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 280,
                      child: _PreferencesBottomNavigation(
                        selectedTab: _selectedTab,
                        onChanged: _selectTab,
                      ),
                    ),
                  ],
                ),
              ),
              if (action.isLoading)
                const Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: Color(0x33FFFFFF),
                      child: Center(child: LoadingWidget()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
      _isSearchVisible = false;
      _searchController.clear();
    });
  }

  void _closeSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSearchVisible = false;
      _searchController.clear();
    });
  }

  Future<void> _openClass(TeacherClassOption classOption) async {
    final preferences =
        ref.read(teacherPreferencesProvider).asData?.value ?? const [];
    final existing =
        preferences.where((item) => item.classId == classOption.id).firstOrNull;
    await _openEditor(classOption, existing);
  }

  Future<void> _editPreference(TeacherPreference preference) async {
    final options =
        ref.read(teacherClassOptionsProvider).asData?.value ?? const [];
    final classOption =
        options.where((item) => item.id == preference.classId).firstOrNull ??
            TeacherClassOption(
              id: preference.classId,
              name: preference.className,
              coursesCount: preference.courses.length,
              wishId: preference.id,
              selectedCoursesCount: preference.courses.length,
            );
    await _openEditor(classOption, preference);
  }

  Future<void> _openEditor(
    TeacherClassOption classOption,
    TeacherPreference? existing,
  ) async {
    final result = await Navigator.of(context).push<TeacherPreferenceDraft>(
      MaterialPageRoute(
        builder: (_) => AddTeacherPreferenceView(
          classOption: classOption,
          existingPreference: existing,
        ),
      ),
    );

    if (!mounted || result == null) return;
    final saved =
        await ref.read(teacherPreferencesActionProvider.notifier).save(
              draft: result,
              wishId: existing?.id ?? classOption.wishId,
            );
    if (!mounted) return;
    if (!saved) {
      _showActionError();
      return;
    }
    setState(() => _selectedTab = 0);

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const TeacherPreferenceSuccessView(),
      ),
    );
  }

  void _confirmDeletePreference(TeacherPreference preference) {
    showDialog<void>(
      context: context,
      builder: (_) => ConfirmDialogWidget(
        title: 'هل تريد حذف هذه الرغبة؟',
        onConfirm: () => _deletePreference(preference),
      ),
    );
  }

  Future<void> _deletePreference(TeacherPreference preference) async {
    final deleted = await ref
        .read(teacherPreferencesActionProvider.notifier)
        .delete(preference);
    if (!mounted) return;
    if (!deleted) {
      _showActionError();
      return;
    }
    context.showSnackbarSuccess('تم حذف الرغبة بنجاح');
  }

  String? _errorMessage(Object error) {
    return error is Exception
        ? exceptionHandler(context: context, exception: error)
        : null;
  }

  void _showActionError() {
    final error = ref.read(teacherPreferencesActionProvider).error;
    context.showSnackbarError(
      _errorMessage(error ?? Exception()) ?? context.locale.errorMessage,
    );
  }
}

class _TeacherPreferencesAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _TeacherPreferencesAppBar({required this.title});

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

class _PreferencesList extends StatelessWidget {
  const _PreferencesList({
    super.key,
    required this.preferences,
    required this.isSearching,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TeacherPreference> preferences;
  final bool isSearching;
  final ValueChanged<TeacherPreference> onEdit;
  final ValueChanged<TeacherPreference> onDelete;

  @override
  Widget build(BuildContext context) {
    if (preferences.isEmpty) {
      return _EmptyPreferencesState(isSearching: isSearching);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
      itemCount: preferences.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final preference = preferences[index];
        return _PreferenceExpansionCard(
          key: ValueKey(preference.classId),
          preference: preference,
          initiallyExpanded: index == 1 || index == 2,
          onEdit: () => onEdit(preference),
          onDelete: () => onDelete(preference),
        );
      },
    );
  }
}

class _PreferenceExpansionCard extends StatefulWidget {
  const _PreferenceExpansionCard({
    super.key,
    required this.preference,
    required this.initiallyExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  final TeacherPreference preference;
  final bool initiallyExpanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_PreferenceExpansionCard> createState() =>
      _PreferenceExpansionCardState();
}

class _PreferenceExpansionCardState extends State<_PreferenceExpansionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: const Color(0xFFAEE2E2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: AppColors.secondryColor.withValues(alpha: 0.28),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.preference.className,
                          style: const TextStyle(
                            color: Color(0xFF263637),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 180),
                        turns: _isExpanded ? 0.5 : 0,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF263637),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 5),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCFA),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFD5CECB),
                        width: 0.7,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.preference.subjects
                          .map(
                            (subject) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '•  $subject',
                                style: const TextStyle(
                                  color: Color(0xFF303738),
                                  fontSize: 15,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: widget.onDelete,
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(2, 5, 4, 0),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFFF3F59),
                              size: 20,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: widget.onEdit,
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(4, 5, 2, 0),
                            child: Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryColor,
                              size: 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClassRegistrationList extends StatelessWidget {
  const _ClassRegistrationList({
    super.key,
    required this.classOptions,
    required this.isSearching,
    required this.onClassSelected,
  });

  final List<TeacherClassOption> classOptions;
  final bool isSearching;
  final ValueChanged<TeacherClassOption> onClassSelected;

  @override
  Widget build(BuildContext context) {
    if (classOptions.isEmpty) {
      return _EmptyPreferencesState(isSearching: isSearching);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
      itemCount: classOptions.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 12 : 9),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Text(
            'اختر الفصول المفضلة لتدريس موادها',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2E3738),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          );
        }

        final classOption = classOptions[index - 1];
        return InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () => onClassSelected(classOption),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: AppColors.primaryColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.co_present_outlined,
                  color: AppColors.primaryColor,
                  size: 23,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    classOption.name,
                    style: const TextStyle(
                      color: Color(0xFF2E3738),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyPreferencesState extends StatelessWidget {
  const _EmptyPreferencesState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFFCF7F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFE65E78),
                size: 40,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              isSearching ? 'لا توجد نتائج مطابقة' : 'لا يوجد بيانات للعرض',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF292E2F),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesBottomNavigation extends StatelessWidget {
  const _PreferencesBottomNavigation({
    required this.selectedTab,
    required this.onChanged,
  });

  final int selectedTab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primaryColor, width: 1.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: _PreferenceTabButton(
                icon: Icons.star_border_rounded,
                label: 'تسجيل الرغبات',
                isSelected: selectedTab == 1,
                onTap: () => onChanged(1),
              ),
            ),
            Expanded(
              child: _PreferenceTabButton(
                icon: Icons.description_outlined,
                label: 'قائمة الرغبات',
                isSelected: selectedTab == 0,
                onTap: () => onChanged(0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTabButton extends StatelessWidget {
  const _PreferenceTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryColor : AppColors.textGrayColor;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
