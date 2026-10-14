import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';

const Color teacherToolsGreen = Color(0xFF2FAE63);
const Color teacherToolsAmber = Color(0xFFF2A51A);
const Color teacherToolsRed = Color(0xFFE65353);
const Color teacherToolsBlue = Color(0xFF5178D7);
const Color teacherToolsSurface = Color(0xFFF5FAFA);

class TeacherToolsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TeacherToolsAppBar({
    super.key,
    required this.title,
    this.action,
  });

  final String title;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.secondryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: action == null
          ? null
          : [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: action,
              ),
            ],
    );
  }
}

class TeacherToolsContextCard extends StatelessWidget {
  const TeacherToolsContextCard({
    super.key,
    required this.lessonContext,
    this.compact = false,
  });

  final TeacherToolsContext lessonContext;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy/MM/dd').format(lessonContext.date);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FCFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: .22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lessonContext.subject.isEmpty
                            ? 'الحصة الحالية'
                            : lessonContext.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'كل الأدوات مرتبطة بهذه الحصة',
                        style: TextStyle(
                          color: Color(0xFF6F7777),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: _ContextValue(
                  icon: Icons.groups_2_outlined,
                  label: 'الفصل',
                  value: lessonContext.className,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContextValue(
                  icon: Icons.schedule_rounded,
                  label: 'الحصة',
                  value: lessonContext.sessionLabel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ContextValue(
                  icon: Icons.calendar_month_outlined,
                  label: 'التاريخ',
                  value: date,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextValue extends StatelessWidget {
  const _ContextValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF747474), fontSize: 11),
        ),
        Text(
          value.isEmpty ? '—' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class PresentStudentsNotice extends StatelessWidget {
  const PresentStudentsNotice({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: teacherToolsGreen.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.how_to_reg_rounded,
            size: 21,
            color: teacherToolsGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count طالبًا حاضرًا متاحون للاختيار',
              style: const TextStyle(
                color: Color(0xFF267E4B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Text(
            'الحاضرون فقط',
            style: TextStyle(
              color: teacherToolsGreen,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherToolSectionTitle extends StatelessWidget {
  const TeacherToolSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(color: Color(0xFF777777), fontSize: 13),
          ),
        ],
      ],
    );
  }
}

class TeacherToolsPrimaryButton extends StatelessWidget {
  const TeacherToolsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    );
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: icon == null
          ? ElevatedButton(onPressed: onPressed, child: labelWidget)
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 21),
              label: labelWidget,
            ),
    );
  }
}

class TeacherToolsStudentAvatar extends StatelessWidget {
  const TeacherToolsStudentAvatar({
    super.key,
    required this.name,
    this.radius = 24,
  });

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).take(2);
    final initials = parts.map((part) => part.characters.first).join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE4F7F7),
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.secondryColor,
          fontSize: radius * .58,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

void showTeacherToolsPreviewMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('واجهة تجريبية جاهزة للربط — لم يتم إرسال بيانات'),
      ),
    );
}

class TeacherToolsLoadError extends StatelessWidget {
  const TeacherToolsLoadError({
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
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
