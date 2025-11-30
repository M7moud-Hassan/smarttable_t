import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/custom_expansion_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';

import '../../providers/health_cases_provider.dart';

class SocialCaseDetailsView extends ConsumerWidget {
  const SocialCaseDetailsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSocialCase = ref.read(currentSocialCaseProvider);
    final socialCaseDetails = ref.watch(socialCasesDetailsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(currentSocialCase.name),
      ),
      body: socialCaseDetails.when(
          data: (data) {
            return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemBuilder: (_, index) {
                  final item = data[index];
                  return CustomExpansionWidget(
                      titleWidget: Text(
                        item.name,
                        style: context.textTheme.titleMedium!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      contentWidget: [
                        Text(
                          '${context.locale.studentGuardian} : ${item.studentGuardian}',
                          style: context.textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const Divider(
                          thickness: 0.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            '${context.locale.kinshipWithStudent} : ${item.kinshipWithStudent}',
                            style: context.textTheme.titleMedium!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 0.5,
                        ),
                        Text(
                          '${context.locale.liveWithWho} : ${item.withLiveText}',
                          style: context.textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const Divider(
                          thickness: 0.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            '${context.locale.fatherIsAlive} : ${item.fatherIsAlive ? context.locale.yes : context.locale.no}',
                            style: context.textTheme.titleMedium!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 0.5,
                        ),
                        Text(
                          '${context.locale.motherIsAlive} : ${item.motherIsAlive ? context.locale.yes : context.locale.no}',
                          style: context.textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ]);
                },
                separatorBuilder: (_, __) => const SizedBox(
                      height: 10,
                    ),
                itemCount: data.length);
          },
          error: (_, __) => Center(
                  child: CustomErrorWidget(
                onTap: () => ref.invalidate(socialCasesDetailsProvider),
              )),
          loading: () => const Center(child: LoadingWidget())),
    );
  }
}
