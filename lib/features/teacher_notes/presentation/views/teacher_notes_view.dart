import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';

import '../../../../core/widgets/custom_expansion_widget.dart';
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
            itemBuilder: (teacherNote, index) => CustomExpansionWidget(
                  titleWidget: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${teacherNote.title} ',
                          style: context.textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        if (teacherNote.comment != null &&
                            teacherNote.comment!.isNotEmpty)
                          TextSpan(
                            text: '${teacherNote.comment} ',
                            style: context.textTheme.titleLarge!.copyWith(
                              fontSize: 16,
                              color: teacherNote.typeNoteText == 'n'
                                  ? AppColors.pinkColor
                                  : AppColors.greenColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  contentWidget: [
                    Text(
                      '${context.locale.date} : ${teacherNote.dateHijri}',
                      style: context.textTheme.titleLarge!
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      teacherNote.details,
                      style: context.textTheme.titleLarge!
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
            noItemWidget: Center(
              child: Text(context.locale.noData),
            )));
  }
}
