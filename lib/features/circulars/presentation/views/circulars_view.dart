import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/views/pdf_viewer_view.dart';
import 'package:smart_table_app/core/widgets/download_button.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';

import '../../../../core/widgets/custom_expansion_widget.dart';
import '../../providers/teacher_notes_provider.dart';

class CircularsView extends ConsumerWidget {
  const CircularsView({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: PaginationListView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            getList: (page) => ref.read(circularsProvider(page).future),
            itemBuilder: (circular, index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      circular.date,
                      style: const TextStyle(
                          color: AppColors.primaryColor, fontSize: 15),
                    ),
                    for (final task in circular.tasks)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: CustomExpansionWidget(
                          titleWidget: Row(
                            children: [
                              if (task.fileIcon == 'pdf') ...[
                                Image.asset(
                                  PngAssets.pdf,
                                  width: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                )
                              ],
                              Text(
                                task.title,
                                style: context.textTheme.titleLarge!
                                    .copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          contentWidget: [
                            Text(
                              '${context.locale.date} : ${task.dateHijri}',
                              style: context.textTheme.titleLarge!.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const Divider(
                              thickness: 0.5,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              task.details,
                              style: context.textTheme.titleLarge!.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0XFFF4C8A9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.push(PdfViwerView(
                                      title: task.title,
                                      url: task.fileUrl,
                                    )),
                                    child: Text(
                                      context.locale.show,
                                      style: context.textTheme.titleLarge!
                                          .copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  DownloadButtonWidget(
                                    link: task.fileUrl,
                                    fileName: task.fileName,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
            noItemWidget: Center(
              child: Text(context.locale.noData),
            )));
  }
}
