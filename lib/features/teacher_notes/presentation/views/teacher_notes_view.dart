import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';

import '../../providers/teacher_notes_provider.dart';

class TeacherNotesView extends ConsumerWidget {
  const TeacherNotesView({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PaginationListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        getList: (page) => ref.read(teacherNotesProvider(page).future),
        itemBuilder: (teacherNote, index) => _buildNoteCard(context, ref, teacherNote),
        noItemWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF5EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD67389),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD67389),
                      size: 44, // Adjusted for scale
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'لا يوجد بيانات للعرض',
                style: context.textTheme.titleLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, dynamic teacherNote) {
    final bool isNegative = teacherNote.typeNoteText == 'n';
    final Color noteColor = isNegative ? const Color(0xFFC6553B) : AppColors.secondryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The thick colored border strictly on the right side in RTL mode
              Container(
                width: 6,
                color: noteColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              teacherNote.title ?? '',
                              style: context.textTheme.titleMedium!.copyWith(
                                color: noteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (teacherNote.comment != null && teacherNote.comment!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: noteColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                teacherNote.comment!,
                                style: context.textTheme.titleSmall!.copyWith(
                                  color: noteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            teacherNote.dateHijri ?? '',
                            style: context.textTheme.titleSmall!.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        teacherNote.details ?? '',
                        style: context.textTheme.titleMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
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
