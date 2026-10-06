import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';

class StudentMoreMenu extends StatelessWidget {
  const StudentMoreMenu({
    super.key,
    required this.onSelected,
    this.behavior = false,
    this.canModifyBehavior = false,
  });

  final ValueChanged<String> onSelected;
  final bool behavior;
  final bool canModifyBehavior;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      tooltip: 'خيارات الطالب',
      onSelected: onSelected,
      itemBuilder: (_) => [
        if (!behavior)
          const PopupMenuItem(
            value: 'edit-attendance',
            child: Text('تعديل حالة الحضور'),
          ),
        if (behavior && canModifyBehavior)
          const PopupMenuItem(
            value: 'edit-behavior',
            child: Text('تعديل ملاحظة السلوك'),
          ),
        if (behavior && canModifyBehavior)
          const PopupMenuItem(
            value: 'delete-behavior',
            child: Text(
              'حذف ملاحظة السلوك',
              style: TextStyle(color: attendanceRed),
            ),
          ),
        PopupMenuItem(
          value: 'history',
          child: Text(behavior ? 'سجل سلوك الطالب' : 'سجل حضور الطالب'),
        ),
        const PopupMenuItem(
          value: 'take-action',
          child: Text('اتخاذ إجراء'),
        ),
        const PopupMenuItem(
          value: 'actions',
          child: Text('الإجراءات المتخذة'),
        ),
      ],
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}

class NoSearchResults extends StatelessWidget {
  const NoSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 52, color: AppColors.primaryColor),
          SizedBox(height: 10),
          Text('لا توجد نتائج مطابقة'),
        ],
      ),
    );
  }
}

class FeatureLoadError extends StatelessWidget {
  const FeatureLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

class FeatureEmptyState extends StatelessWidget {
  const FeatureEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
