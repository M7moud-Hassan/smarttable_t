import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';

const Color attendanceGreen = Color(0xFF39B83F);
const Color attendanceRed = Color(0xFFF04444);
const Color attendanceAmber = Color(0xFFFFB400);
const Color attendanceNavy = Color(0xFF243680);
const Color behaviorOrange = Color(0xFFFF6F0F);
const Color panelBackground = Color(0xFFF7F5F5);

Color attendanceStatusColor(AttendanceStatus status) => switch (status) {
      AttendanceStatus.present => attendanceGreen,
      AttendanceStatus.absent => attendanceRed,
      AttendanceStatus.late => attendanceAmber,
      AttendanceStatus.excused => attendanceNavy,
      AttendanceStatus.notRecorded => const Color(0xFF7A7A7A),
    };

IconData behaviorIcon(String key) => switch (key) {
      'smile' => Icons.sentiment_satisfied_alt_rounded,
      'sad' => Icons.sentiment_dissatisfied_rounded,
      'star' => Icons.star_outline_rounded,
      'like' => Icons.thumb_up_alt_outlined,
      'warning' => Icons.warning_amber_rounded,
      _ => Icons.emoji_emotions_outlined,
    };

Color behaviorNoteColor(BehaviorNoteModel note) {
  if (note.type == BehaviorNoteType.needsImprovement) {
    return attendanceAmber;
  }
  return note.iconKey == 'like' ? attendanceNavy : attendanceGreen;
}

class FeatureTitleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FeatureTitleAppBar({
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

class FeatureSegmentedControl extends StatelessWidget {
  const FeatureSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor, width: 1.4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              key: ValueKey('feature-segment-$index'),
              borderRadius: BorderRadius.circular(24),
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.secondryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LessonContextHeader extends StatelessWidget {
  const LessonContextHeader({
    super.key,
    required this.date,
    required this.session,
    required this.className,
  });

  final String date;
  final String session;
  final String className;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FCFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ContextItem(
              label: 'التاريخ',
              value: date,
              icon: Icons.calendar_month_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ContextItem(
              label: 'الحصة',
              value: session,
              icon: Icons.schedule_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ContextItem(
              label: 'الفصل',
              value: className,
              icon: Icons.groups_2_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextItem extends StatelessWidget {
  const _ContextItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF686868), fontSize: 11),
        ),
        Text(
          value,
          maxLines: 1,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({super.key, required this.name, this.radius = 27});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    final initials = parts.take(2).map((part) => part[0]).join();
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

class StudentSummaryCard extends StatelessWidget {
  const StudentSummaryCard({
    super.key,
    required this.student,
    this.trailing,
    this.subtitle,
  });

  final AttendanceBehaviorStudent student;
  final Widget? trailing;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            StudentAvatar(name: student.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  subtitle ??
                      Text(
                        student.className,
                        style: const TextStyle(
                          color: Color(0xFF747474),
                          fontSize: 12,
                        ),
                      ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class AttendanceStatusBadge extends StatelessWidget {
  const AttendanceStatusBadge({super.key, required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = attendanceStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class BehaviorNoteBadge extends StatelessWidget {
  const BehaviorNoteBadge({super.key, required this.note});

  final BehaviorNoteModel note;

  @override
  Widget build(BuildContext context) {
    final color = behaviorNoteColor(note);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(behaviorIcon(note.iconKey), color: color, size: 22),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            note.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: .55)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentDetailHeader extends StatelessWidget {
  const StudentDetailHeader({super.key, required this.student});

  final AttendanceBehaviorStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          StudentAvatar(name: student.name, radius: 35),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'الفصل: ${student.className}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'ابحث باسم الطالب',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: const Color(0xFFF6F6F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
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
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
