import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';

import '../../../../core/widgets/custom_expansion_widget.dart';
import '../../providers/class_visits_provider.dart';

class ClassVisitsView extends ConsumerWidget {
  const ClassVisitsView({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PaginationListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            getList: (page) => ref.read(classVisitsProvider(page).future),
            itemBuilder: (visit, index) => CustomExpansionWidget(
                  titleWidget: Text(
                    visit.teacherName,
                    style: context.textTheme.titleLarge!.copyWith(fontSize: 18),
                  ),
                  contentWidget: [
                    Text(
                      '${context.locale.visitor} : ${visit.visitorName}',
                      style: context.textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${context.locale.class_} : ${visit.className}',
                      style: context.textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${context.locale.date} : ${visit.dateHijri}',
                      style: context.textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const Divider(
                      thickness: 0.5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${context.locale.session} : ${visit.session}',
                      style: context.textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
            noItemWidget: Center(
              child: Text(
                context.locale.noData,
              ),
            )));
  }
}
